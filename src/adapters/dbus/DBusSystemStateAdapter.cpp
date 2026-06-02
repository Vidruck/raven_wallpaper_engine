#include "DBusSystemStateAdapter.h"
#include <QDBusConnection>
#include <QDBusMessage>

DBusSystemStateAdapter::DBusSystemStateAdapter(QObject *parent)
    : QObject(parent)
{
}

void DBusSystemStateAdapter::startListening()
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    if (systemBus.isConnected()) {
        systemBus.connect(
            QStringLiteral("org.freedesktop.login1"),
            QStringLiteral("/org/freedesktop/login1"),
            QStringLiteral("org.freedesktop.login1.Manager"),
            QStringLiteral("PrepareForSleep"),
            this,
            SLOT(onPrepareForSleep(bool))
        );
    }

    QDBusConnection sessionBus = QDBusConnection::sessionBus();
    if (sessionBus.isConnected()) {
        sessionBus.connect(
            QStringLiteral("org.freedesktop.ScreenSaver"),
            QStringLiteral("/ScreenSaver"),
            QStringLiteral("org.freedesktop.ScreenSaver"),
            QStringLiteral("ActiveChanged"),
            this,
            SLOT(onScreenSaverActiveChanged(bool))
        );
    }
}

void DBusSystemStateAdapter::onSuspensionStateChanged(SuspendedCallback callback)
{
    m_suspensionCallback = callback;
}

void DBusSystemStateAdapter::onPrepareForSleep(bool sleep)
{
    if (m_suspensionCallback) {
        m_suspensionCallback(sleep);
    }
}

void DBusSystemStateAdapter::onScreenSaverActiveChanged(bool active)
{
    if (m_suspensionCallback) {
        m_suspensionCallback(active);
    }
}
