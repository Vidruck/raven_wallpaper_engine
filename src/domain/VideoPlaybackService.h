#ifndef VIDEOPLAYBACKSERVICE_H
#define VIDEOPLAYBACKSERVICE_H

#include <QObject>
#include <QUrl>
#include <QList>
#include <QTimer>
#include "../ports/IVideoPlayerPort.h"
#include "../ports/ISystemStatePort.h"

/**
 * @class VideoPlaybackService
 * @brief Capa de Dominio. Orquesta la lógica de negocio (listas de reproducción, suspensión).
 */
class VideoPlaybackService : public QObject {
    Q_OBJECT
public:
    explicit VideoPlaybackService(IVideoPlayerPort *playerPort, ISystemStatePort *systemStatePort, QObject *parent = nullptr);
    ~VideoPlaybackService() override = default;

    void setSource(const QUrl &source);
    QUrl source() const;

    void setSourceType(int type);
    int sourceType() const;

    void setLoopMode(int mode);
    int loopMode() const;

    void setPlaylistOrder(int order);
    int playlistOrder() const;

    void setSuspended(bool suspended);
    bool isSuspended() const;

    void playNext();

signals:
    void playlistUpdated();
    void stateChanged();

private slots:
    void doUpdatePlaylist();

private:
    void loadIndex(int index);
    void updatePlaylist();

    IVideoPlayerPort *m_playerPort;
    ISystemStatePort *m_systemStatePort;

    QUrl m_source;
    int m_sourceType = 0;
    int m_loopMode = 0;
    int m_playlistOrder = 0;
    bool m_isSuspended = false;

    QList<QUrl> m_playlist;
    int m_playlistIndex = -1;
    QTimer *m_updateTimer;
};

#endif // VIDEOPLAYBACKSERVICE_H
