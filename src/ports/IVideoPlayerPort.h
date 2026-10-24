#ifndef IVIDEOPLAYERPORT_H
#define IVIDEOPLAYERPORT_H

#include <QUrl>
#include <QObject>

/**
 * @class IVideoPlayerPort
 * @brief Interfaz (Port) que define las operaciones que debe proveer el adaptador de reproducción de medios.
 */
class IVideoPlayerPort {
public:
    virtual ~IVideoPlayerPort() = default;

    virtual void play() = 0;
    virtual void pause() = 0;
    virtual void stop() = 0;
    
    virtual void setSource(const QUrl &url) = 0;
    virtual QUrl source() const = 0;
    
    virtual void setVolume(double volume) = 0;
    virtual double volume() const = 0;
    
    virtual void setPlaybackRate(double rate) = 0;
    virtual double playbackRate() const = 0;
    
    virtual void setMuted(bool mute) = 0;
    virtual bool isMuted() const = 0;

    // Configura si el reproductor debe repetir el medio actual indefinidamente o reproducirlo una sola vez.
    virtual void setInfiniteLoop(bool infinite) = 0;

    // El adaptador debe proveer el reproductor real (QMediaPlayer) para ser expuesto a QML.
    virtual QObject* getUnderlyingPlayer() const = 0;
};

#endif // IVIDEOPLAYERPORT_H
