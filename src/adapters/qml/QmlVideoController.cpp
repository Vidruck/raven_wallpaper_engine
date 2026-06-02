#include "QmlVideoController.h"

QmlVideoController::QmlVideoController(QObject *parent)
    : QObject(parent)
{
    m_playerAdapter = new QtVideoPlayerAdapter(this);
    m_systemStateAdapter = new DBusSystemStateAdapter(this);
    
    m_service = new VideoPlaybackService(m_playerAdapter, m_systemStateAdapter, this);

    // Conectar los eventos del adaptador (Player Adapter)
    connect(m_playerAdapter, &QtVideoPlayerAdapter::errorOccurred, this, [this](QMediaPlayer::Error error, const QString &errorString) {
        Q_UNUSED(error);
        Q_UNUSED(errorString);
        m_hasError = true;
        emit errorStateChanged();
        m_playerAdapter->stop();
    });

    connect(m_playerAdapter, &QtVideoPlayerAdapter::mediaStatusChanged, this, [this](QMediaPlayer::MediaStatus status) {
        if (status == QMediaPlayer::InvalidMedia) {
            m_hasError = true;
            emit errorStateChanged();
            m_playerAdapter->stop();
            return;
        }
        if (status == QMediaPlayer::EndOfMedia) {
            if (m_service->loopMode() != 0) {
                m_service->playNext();
            }
        }
    });

    connect(m_service, &VideoPlaybackService::stateChanged, this, &QmlVideoController::suspensionChanged);
}

QObject* QmlVideoController::mediaPlayer() const
{
    return m_playerAdapter->getUnderlyingPlayer();
}

QUrl QmlVideoController::source() const
{
    return m_service->source();
}

void QmlVideoController::setSource(const QUrl &source)
{
    m_hasError = false;
    emit errorStateChanged();
    m_service->setSource(source);
    emit sourceChanged();
}

int QmlVideoController::sourceType() const
{
    return m_service->sourceType();
}

void QmlVideoController::setSourceType(int type)
{
    m_service->setSourceType(type);
    emit sourceTypeChanged();
}

int QmlVideoController::loopMode() const
{
    return m_service->loopMode();
}

void QmlVideoController::setLoopMode(int mode)
{
    m_service->setLoopMode(mode);
    if (mode == 0) {
        m_playerAdapter->setLoops(QMediaPlayer::Infinite);
    } else {
        m_playerAdapter->setLoops(QMediaPlayer::Once);
    }
    emit loopModeChanged();
}

int QmlVideoController::playlistOrder() const
{
    return m_service->playlistOrder();
}

void QmlVideoController::setPlaylistOrder(int order)
{
    m_service->setPlaylistOrder(order);
    emit playlistOrderChanged();
}

double QmlVideoController::volume() const
{
    return m_playerAdapter->volume();
}

void QmlVideoController::setVolume(double volume)
{
    m_playerAdapter->setVolume(volume);
    emit volumeChanged();
}

double QmlVideoController::playbackRate() const
{
    return m_playerAdapter->playbackRate();
}

void QmlVideoController::setPlaybackRate(double rate)
{
    m_playerAdapter->setPlaybackRate(rate);
    emit playbackRateChanged();
}

bool QmlVideoController::mute() const
{
    return m_playerAdapter->isMuted();
}

void QmlVideoController::setMute(bool mute)
{
    m_playerAdapter->setMuted(mute);
    emit muteChanged();
}

bool QmlVideoController::isSuspended() const
{
    return m_service->isSuspended();
}

bool QmlVideoController::hasError() const
{
    return m_hasError;
}

void QmlVideoController::play()
{
    if (!m_hasError && !m_service->isSuspended()) {
        m_playerAdapter->play();
    }
}

void QmlVideoController::pause()
{
    m_playerAdapter->pause();
}

void QmlVideoController::stop()
{
    m_playerAdapter->stop();
}
