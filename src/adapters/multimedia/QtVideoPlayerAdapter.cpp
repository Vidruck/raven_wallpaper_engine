#include "QtVideoPlayerAdapter.h"
#include <QtGlobal>

namespace {
bool ensureHardwareDecodingEnv()
{
    // Forzar el backend de decodificación por hardware VAAPI en Linux (evita caer en VDPAU no disponible
    // o decodificación por software con múltiples hilos av:h264:df* en videos 4K).
    if (qEnvironmentVariableIsEmpty("QT_FFMPEG_DECODING_HW_DEVICE_TYPES")) {
        qputenv("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", "vaapi");
    }
    return true;
}
} // namespace

QtVideoPlayerAdapter::QtVideoPlayerAdapter(QObject *parent)
    : QObject(parent)
{
    static const bool hwInit = ensureHardwareDecodingEnv();
    Q_UNUSED(hwInit);

    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);
    m_player->setLoops(QMediaPlayer::Infinite);

    connect(m_player, &QMediaPlayer::errorOccurred, this, &QtVideoPlayerAdapter::errorOccurred);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &QtVideoPlayerAdapter::mediaStatusChanged);
}

QtVideoPlayerAdapter::~QtVideoPlayerAdapter()
{
    // Desconectar señales y desvincular el sink de video antes de detener el reproductor
    // para prevenir accesos a memoria liberada en QSGRenderThread (QRhi::newTexture).
    disconnect(m_player, nullptr, this, nullptr);
    m_player->stop();
    m_player->setVideoOutput(nullptr);
    m_player->setAudioOutput(nullptr);
    m_player->setSource(QUrl());
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

void QtVideoPlayerAdapter::setInfiniteLoop(bool infinite)
{
    m_player->setLoops(infinite ? QMediaPlayer::Infinite : QMediaPlayer::Once);
}

QObject* QtVideoPlayerAdapter::getUnderlyingPlayer() const
{
    return m_player;
}

void QtVideoPlayerAdapter::setLoops(QMediaPlayer::Loops loops)
{
    m_player->setLoops(loops);
}

void QtVideoPlayerAdapter::detachVideoOutput()
{
    if (m_player) {
        m_player->stop();
        m_player->setVideoOutput(nullptr);
    }
}
