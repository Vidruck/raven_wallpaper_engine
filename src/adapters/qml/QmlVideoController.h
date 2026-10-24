#ifndef QMLVIDEOCONTROLLER_H
#define QMLVIDEOCONTROLLER_H

#include <QObject>
#include <QUrl>
#include <QMediaPlayer>
#include <QtQml/qqmlregistration.h>
#include "../../domain/VideoPlaybackService.h"
#include "../multimedia/QtVideoPlayerAdapter.h"
#include "../dbus/DBusSystemStateAdapter.h"

/**
 * @class QmlVideoController
 * @brief Adaptador Primario (Driving Adapter). Expone la API a QML y conecta el motor interno.
 */
class QmlVideoController : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(VideoController)
    Q_PROPERTY(QObject* mediaPlayer READ mediaPlayer CONSTANT)
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int sourceType READ sourceType WRITE setSourceType NOTIFY sourceTypeChanged)
    Q_PROPERTY(int loopMode READ loopMode WRITE setLoopMode NOTIFY loopModeChanged)
    Q_PROPERTY(int playlistOrder READ playlistOrder WRITE setPlaylistOrder NOTIFY playlistOrderChanged)
    Q_PROPERTY(double volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(double playbackRate READ playbackRate WRITE setPlaybackRate NOTIFY playbackRateChanged)
    Q_PROPERTY(bool mute READ mute WRITE setMute NOTIFY muteChanged)
    Q_PROPERTY(bool pauseOnBattery READ pauseOnBattery WRITE setPauseOnBattery NOTIFY pauseOnBatteryChanged)
    Q_PROPERTY(bool userPaused READ userPaused WRITE setUserPaused NOTIFY userPausedChanged)
    Q_PROPERTY(QString currentFileName READ currentFileName NOTIFY currentTrackChanged)
    Q_PROPERTY(int playlistCount READ playlistCount NOTIFY playlistUpdated)
    
    Q_PROPERTY(bool isSuspended READ isSuspended NOTIFY suspensionChanged)
    Q_PROPERTY(bool hasError READ hasError NOTIFY errorStateChanged)

public:
    explicit QmlVideoController(QObject *parent = nullptr);
    ~QmlVideoController() override;

    QObject* mediaPlayer() const;

    QUrl source() const;
    void setSource(const QUrl &source);

    int sourceType() const;
    void setSourceType(int type);

    int loopMode() const;
    void setLoopMode(int mode);

    int playlistOrder() const;
    void setPlaylistOrder(int order);

    double volume() const;
    void setVolume(double volume);

    double playbackRate() const;
    void setPlaybackRate(double rate);

    bool mute() const;
    void setMute(bool mute);

    bool pauseOnBattery() const;
    void setPauseOnBattery(bool enabled);

    bool userPaused() const;
    void setUserPaused(bool paused);

    QString currentFileName() const;
    int playlistCount() const;

    bool isSuspended() const;
    bool hasError() const;

signals:
    void sourceChanged();
    void sourceTypeChanged();
    void loopModeChanged();
    void playlistOrderChanged();
    void volumeChanged();
    void playbackRateChanged();
    void muteChanged();
    void pauseOnBatteryChanged();
    void userPausedChanged();
    void currentTrackChanged();
    void playlistUpdated();
    void suspensionChanged();
    void errorStateChanged();

public slots:
    void play();
    void pause();
    void stop();
    void nextTrack();
    void previousTrack();
    void detachVideoOutput();

private:
    QtVideoPlayerAdapter *m_playerAdapter;
    DBusSystemStateAdapter *m_systemStateAdapter;
    VideoPlaybackService *m_service;
    bool m_hasError = false;
};

#endif // QMLVIDEOCONTROLLER_H
