#ifndef DBUSSYSTEMSTATEADAPTER_H
#define DBUSSYSTEMSTATEADAPTER_H

#include <QObject>
#include "../../ports/ISystemStatePort.h"

/**
 * @class DBusSystemStateAdapter
 * @brief Implementación (Adapter) de ISystemStatePort que usa QDBus para escuchar los eventos del sistema.
 */
class DBusSystemStateAdapter : public QObject, public ISystemStatePort {
    Q_OBJECT
public:
    explicit DBusSystemStateAdapter(QObject *parent = nullptr);
    ~DBusSystemStateAdapter() override = default;

    void startListening() override;
    void onSuspensionStateChanged(SuspendedCallback callback) override;

private slots:
    void onPrepareForSleep(bool sleep);
    void onScreenSaverActiveChanged(bool active);

private:
    SuspendedCallback m_suspensionCallback;
};

#endif // DBUSSYSTEMSTATEADAPTER_H
