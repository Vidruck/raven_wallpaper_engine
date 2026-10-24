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
    connect(m_service, &VideoPlaybackService::currentTrackChanged, this, &QmlVideoController::currentTrackChanged);
    connect(m_service, &VideoPlaybackService::playlistUpdated, this, &QmlVideoController::playlistUpdated);
}

QmlVideoController::~QmlVideoController()
{
    if (m_playerAdapter) {
        m_playerAdapter->detachVideoOutput();
    }
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

bool QmlVideoController::pauseOnBattery() const
{
    return m_service->pauseOnBattery();
}

void QmlVideoController::setPauseOnBattery(bool enabled)
{
    if (m_service->pauseOnBattery() == enabled) return;
    m_service->setPauseOnBattery(enabled);
    emit pauseOnBatteryChanged();
}

bool QmlVideoController::userPaused() const
{
    return m_service->isUserPaused();
}

void QmlVideoController::setUserPaused(bool paused)
{
    if (m_service->isUserPaused() == paused) return;
    m_service->setUserPaused(paused);
    emit userPausedChanged();
}

QString QmlVideoController::currentFileName() const
{
    return m_service->currentFileName();
}

int QmlVideoController::playlistCount() const
{
    return m_service->playlistCount();
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

void QmlVideoController::nextTrack()
{
    m_service->playNext();
}

void QmlVideoController::previousTrack()
{
    m_service->playPrevious();
}

void QmlVideoController::detachVideoOutput()
{
    if (m_playerAdapter) {
        m_playerAdapter->detachVideoOutput();
    }
}
