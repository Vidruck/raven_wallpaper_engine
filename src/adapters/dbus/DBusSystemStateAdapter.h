#ifndef DBUSSYSTEMSTATEADAPTER_H
#define DBUSSYSTEMSTATEADAPTER_H

#include <QObject>
#include <QTimer>
#include <QVariantMap>
#include "../../ports/ISystemStatePort.h"

/**
 * @class DBusSystemStateAdapter
 * @brief Implementación (Adapter) de ISystemStatePort que usa QDBus para escuchar los eventos del sistema.
 *
 * Combina de forma segura los estados de suspensión (login1), bloqueo de pantalla (ScreenSaver)
 * y ahorro de energía/batería (UPower / PowerProfiles) con un temporizador de estabilización (debounce)
 * al despertar para evitar condiciones de carrera con el hilo de renderizado QRhi/Wayland.
 */
class DBusSystemStateAdapter : public QObject, public ISystemStatePort {
    Q_OBJECT
public:
    explicit DBusSystemStateAdapter(QObject *parent = nullptr);
    ~DBusSystemStateAdapter() override = default;

    void startListening() override;
    void onSuspensionStateChanged(SuspendedCallback callback) override;

    void setPauseOnBattery(bool enabled) override;
    bool pauseOnBattery() const override;

private slots:
    void onPrepareForSleep(bool sleep);
    void onScreenSaverActiveChanged(bool active);
    void onUPowerPropertiesChanged(const QString &interfaceName, const QVariantMap &changedProperties, const QStringList &invalidatedProperties);
    void onPowerProfilesPropertiesChanged(const QString &interfaceName, const QVariantMap &changedProperties, const QStringList &invalidatedProperties);

private:
    void evaluateState();
    void queryInitialPowerState();

    SuspendedCallback m_suspensionCallback;
    QTimer *m_resumeDebounceTimer;

    bool m_isSleeping = false;
    bool m_isScreenLocked = false;
    bool m_isOnBattery = false;
    bool m_isPowerSaverProfile = false;
    bool m_pauseOnBattery = false;
    bool m_lastNotifiedSuspended = false;
};

#endif // DBUSSYSTEMSTATEADAPTER_H
