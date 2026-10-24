#include "DBusSystemStateAdapter.h"
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QDBusVariant>

DBusSystemStateAdapter::DBusSystemStateAdapter(QObject *parent)
    : QObject(parent)
{
    // Temporizador de estabilización al reanudar: evita inyectar texturas de video mientras
    // KWin/DRM aún está restaurando los modos de pantalla tras el desbloqueo o suspensión.
    m_resumeDebounceTimer = new QTimer(this);
    m_resumeDebounceTimer->setSingleShot(true);
    m_resumeDebounceTimer->setInterval(350);
    connect(m_resumeDebounceTimer, &QTimer::timeout, this, [this]() {
        const bool shouldSuspend = m_isSleeping || m_isScreenLocked || (m_pauseOnBattery && (m_isOnBattery || m_isPowerSaverProfile));
        if (!shouldSuspend && m_lastNotifiedSuspended) {
            m_lastNotifiedSuspended = false;
            if (m_suspensionCallback) {
                m_suspensionCallback(false);
            }
        }
    });
}

void DBusSystemStateAdapter::startListening()
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    if (systemBus.isConnected()) {
        // Escuchar eventos de suspensión e hibernación del sistema (systemd-logind)
        systemBus.connect(
            QStringLiteral("org.freedesktop.login1"),
            QStringLiteral("/org/freedesktop/login1"),
            QStringLiteral("org.freedesktop.login1.Manager"),
            QStringLiteral("PrepareForSleep"),
            this,
            SLOT(onPrepareForSleep(bool))
        );

        // Escuchar cambios de batería/alimentación en UPower
        systemBus.connect(
            QStringLiteral("org.freedesktop.UPower"),
            QStringLiteral("/org/freedesktop/UPower"),
            QStringLiteral("org.freedesktop.DBus.Properties"),
            QStringLiteral("PropertiesChanged"),
            this,
            SLOT(onUPowerPropertiesChanged(QString,QVariantMap,QStringList))
        );

        // Escuchar cambios en perfiles de energía (power-profiles-daemon)
        systemBus.connect(
            QStringLiteral("net.hadess.PowerProfiles"),
            QStringLiteral("/net/hadess/PowerProfiles"),
            QStringLiteral("org.freedesktop.DBus.Properties"),
            QStringLiteral("PropertiesChanged"),
            this,
            SLOT(onPowerProfilesPropertiesChanged(QString,QVariantMap,QStringList))
        );
    }

    QDBusConnection sessionBus = QDBusConnection::sessionBus();
    if (sessionBus.isConnected()) {
        // Escuchar bloqueo de pantalla y protector de pantalla en KDE Plasma
        sessionBus.connect(
            QStringLiteral("org.freedesktop.ScreenSaver"),
            QStringLiteral("/ScreenSaver"),
            QStringLiteral("org.freedesktop.ScreenSaver"),
            QStringLiteral("ActiveChanged"),
            this,
            SLOT(onScreenSaverActiveChanged(bool))
        );
    }

    queryInitialPowerState();
}

void DBusSystemStateAdapter::onSuspensionStateChanged(SuspendedCallback callback)
{
    m_suspensionCallback = callback;
}

void DBusSystemStateAdapter::setPauseOnBattery(bool enabled)
{
    if (m_pauseOnBattery == enabled) return;
    m_pauseOnBattery = enabled;
    if (m_pauseOnBattery) {
        queryInitialPowerState();
    }
    evaluateState();
}

bool DBusSystemStateAdapter::pauseOnBattery() const
{
    return m_pauseOnBattery;
}

void DBusSystemStateAdapter::queryInitialPowerState()
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    if (!systemBus.isConnected()) return;

    QDBusMessage upowerMsg = QDBusMessage::createMethodCall(
        QStringLiteral("org.freedesktop.UPower"),
        QStringLiteral("/org/freedesktop/UPower"),
        QStringLiteral("org.freedesktop.DBus.Properties"),
        QStringLiteral("Get")
    );
    upowerMsg << QStringLiteral("org.freedesktop.UPower") << QStringLiteral("OnBattery");
    QDBusReply<QDBusVariant> upowerReply = systemBus.call(upowerMsg, QDBus::Block, 150);
    if (upowerReply.isValid()) {
        m_isOnBattery = upowerReply.value().variant().toBool();
    }
}

void DBusSystemStateAdapter::onPrepareForSleep(bool sleep)
{
    m_isSleeping = sleep;
    evaluateState();
}

void DBusSystemStateAdapter::onScreenSaverActiveChanged(bool active)
{
    m_isScreenLocked = active;
    evaluateState();
}

void DBusSystemStateAdapter::onUPowerPropertiesChanged(const QString &interfaceName, const QVariantMap &changedProperties, const QStringList &invalidatedProperties)
{
    Q_UNUSED(interfaceName);
    Q_UNUSED(invalidatedProperties);
    if (changedProperties.contains(QStringLiteral("OnBattery"))) {
        m_isOnBattery = changedProperties.value(QStringLiteral("OnBattery")).toBool();
        evaluateState();
    }
}

void DBusSystemStateAdapter::onPowerProfilesPropertiesChanged(const QString &interfaceName, const QVariantMap &changedProperties, const QStringList &invalidatedProperties)
{
    Q_UNUSED(interfaceName);
    Q_UNUSED(invalidatedProperties);
    if (changedProperties.contains(QStringLiteral("ActiveProfile"))) {
        const QString profile = changedProperties.value(QStringLiteral("ActiveProfile")).toString();
        m_isPowerSaverProfile = (profile == QStringLiteral("power-saver"));
        evaluateState();
    }
}

void DBusSystemStateAdapter::evaluateState()
{
    const bool shouldSuspend = m_isSleeping || m_isScreenLocked || (m_pauseOnBattery && (m_isOnBattery || m_isPowerSaverProfile));

    if (shouldSuspend) {
        // Suspender inmediatamente para liberar la GPU antes de que el sistema duerma o bloquee la pantalla
        m_resumeDebounceTimer->stop();
        if (!m_lastNotifiedSuspended) {
            m_lastNotifiedSuspended = true;
            if (m_suspensionCallback) {
                m_suspensionCallback(true);
            }
        }
    } else {
        // Reanudar con un breve retardo de seguridad para que KWin/Wayland estabilice las superficies
        if (m_lastNotifiedSuspended) {
            m_resumeDebounceTimer->start();
        }
    }
}
