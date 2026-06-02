#include "QtVideoPlayerAdapter.h"

QtVideoPlayerAdapter::QtVideoPlayerAdapter(QObject *parent)
    : QObject(parent), m_player(new QMediaPlayer(this)), m_audioOutput(new QAudioOutput(this))
{
    m_player->setAudioOutput(m_audioOutput);

    connect(m_player, &QMediaPlayer::errorOccurred, this, &QtVideoPlayerAdapter::errorOccurred);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &QtVideoPlayerAdapter::mediaStatusChanged);
}

QtVideoPlayerAdapter::~QtVideoPlayerAdapter()
{
    m_player->stop();
}

void QtVideoPlayerAdapter::play()
{
    m_player->play();
}

void QtVideoPlayerAdapter::pause()
{
    m_player->pause();
}

void QtVideoPlayerAdapter::stop()
{
    m_player->stop();
}

void QtVideoPlayerAdapter::setSource(const QUrl &url)
{
    m_player->setSource(url);
}

QUrl QtVideoPlayerAdapter::source() const
{
    return m_player->source();
}

void QtVideoPlayerAdapter::setVolume(double volume)
{
    m_audioOutput->setVolume(volume);
}

double QtVideoPlayerAdapter::volume() const
{
    return m_audioOutput->volume();
}

void QtVideoPlayerAdapter::setPlaybackRate(double rate)
{
    m_player->setPlaybackRate(rate);
}

double QtVideoPlayerAdapter::playbackRate() const
{
    return m_player->playbackRate();
}

void QtVideoPlayerAdapter::setMuted(bool mute)
{
    m_audioOutput->setMuted(mute);
}

bool QtVideoPlayerAdapter::isMuted() const
{
    return m_audioOutput->isMuted();
}

QObject* QtVideoPlayerAdapter::getUnderlyingPlayer() const
{
    return m_player;
}

void QtVideoPlayerAdapter::setLoops(QMediaPlayer::Loops loops)
{
    m_player->setLoops(loops);
}
