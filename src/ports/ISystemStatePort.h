#ifndef ISYSTEMSTATEPORT_H
#define ISYSTEMSTATEPORT_H

#include <functional>

/**
 * @class ISystemStatePort
 * @brief Interfaz (Port) que define cómo el sistema externo notifica sobre estados relevantes (bloqueo de pantalla, suspensión, etc).
 */
class ISystemStatePort {
public:
    virtual ~ISystemStatePort() = default;

    // Callbacks que el dominio puede registrar para escuchar eventos
    using SuspendedCallback = std::function<void(bool)>;

    // Inicializa la escucha de eventos (ej. conexión a D-Bus)
    virtual void startListening() = 0;
    
    // Registra una función a ser llamada cuando el sistema se suspenda o despierte (incluyendo bloqueo de pantalla y ahorro de energía)
    virtual void onSuspensionStateChanged(SuspendedCallback callback) = 0;

    // Activa o desactiva la pausa automática cuando el equipo funciona con batería o perfil de ahorro de energía
    virtual void setPauseOnBattery(bool enabled) = 0;
    virtual bool pauseOnBattery() const = 0;
};

#endif // ISYSTEMSTATEPORT_H
