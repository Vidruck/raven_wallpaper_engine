#ifndef QTVIDEOPLAYERADAPTER_H
#define QTVIDEOPLAYERADAPTER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include "../../ports/IVideoPlayerPort.h"

/**
 * @class QtVideoPlayerAdapter
 * @brief Implementación (Adapter) de IVideoPlayerPort usando QMediaPlayer de QtMultimedia.
 */
class QtVideoPlayerAdapter : public QObject, public IVideoPlayerPort {
    Q_OBJECT
public:
    explicit QtVideoPlayerAdapter(QObject *parent = nullptr);
    ~QtVideoPlayerAdapter() override;

    void play() override;
    void pause() override;
    void stop() override;

    void setSource(const QUrl &url) override;
    QUrl source() const override;

    void setVolume(double volume) override;
    double volume() const override;

    void setPlaybackRate(double rate) override;
    double playbackRate() const override;

    void setMuted(bool mute) override;
    bool isMuted() const override;

    QObject* getUnderlyingPlayer() const override;

    // Métodos específicos para Qt
    void setLoops(QMediaPlayer::Loops loops);

signals:
    void errorOccurred(QMediaPlayer::Error error, const QString &errorString);
    void mediaStatusChanged(QMediaPlayer::MediaStatus status);

private:
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
};

#endif // QTVIDEOPLAYERADAPTER_H
