#include "VideoPlaybackService.h"
#include <QDir>
#include <QRandomGenerator>

VideoPlaybackService::VideoPlaybackService(IVideoPlayerPort *playerPort, ISystemStatePort *systemStatePort, QObject *parent)
    : QObject(parent), m_playerPort(playerPort), m_systemStatePort(systemStatePort)
{
    m_updateTimer = new QTimer(this);
    m_updateTimer->setSingleShot(true);
    m_updateTimer->setInterval(100);
    connect(m_updateTimer, &QTimer::timeout, this, &VideoPlaybackService::doUpdatePlaylist);

    m_systemStatePort->onSuspensionStateChanged([this](bool suspended) {
        setSuspended(suspended);
    });
    m_systemStatePort->startListening();
}

void VideoPlaybackService::setSource(const QUrl &source)
{
    if (m_source == source) return;
    m_source = source;
    updatePlaylist();
}

QUrl VideoPlaybackService::source() const
{
    return m_source;
}

void VideoPlaybackService::setSourceType(int type)
{
    if (m_sourceType == type) return;
    m_sourceType = type;
    updatePlaylist();
}

int VideoPlaybackService::sourceType() const
{
    return m_sourceType;
}

void VideoPlaybackService::setLoopMode(int mode)
{
    if (m_loopMode == mode) return;
    m_loopMode = mode;
    
    // Ajustar internamente el modo de bucle (loop mode) según la selección en el puerto multimedia.
    m_playerPort->setInfiniteLoop(m_loopMode == 0);
}

int VideoPlaybackService::loopMode() const
{
    return m_loopMode;
}

void VideoPlaybackService::setPlaylistOrder(int order)
{
    if (m_playlistOrder == order) return;
    m_playlistOrder = order;
    updatePlaylist();
}

int VideoPlaybackService::playlistOrder() const
{
    return m_playlistOrder;
}

void VideoPlaybackService::setSuspended(bool suspended)
{
    if (m_isSystemSuspended == suspended) return;
    m_isSystemSuspended = suspended;
    applyPlaybackState();
    emit stateChanged();
}

bool VideoPlaybackService::isSuspended() const
{
    return m_isSystemSuspended || m_isUserPaused;
}

void VideoPlaybackService::setPauseOnBattery(bool enabled)
{
    m_systemStatePort->setPauseOnBattery(enabled);
}

bool VideoPlaybackService::pauseOnBattery() const
{
    return m_systemStatePort->pauseOnBattery();
}

void VideoPlaybackService::setUserPaused(bool paused)
{
    if (m_isUserPaused == paused) return;
    m_isUserPaused = paused;
    applyPlaybackState();
    emit stateChanged();
}

bool VideoPlaybackService::isUserPaused() const
{
    return m_isUserPaused;
}

void VideoPlaybackService::applyPlaybackState()
{
    if (isSuspended()) {
        m_playerPort->pause();
    } else if (!m_playlist.isEmpty() && m_playlistIndex >= 0 && m_playlistIndex < m_playlist.size()) {
        m_playerPort->play();
    }
}

QString VideoPlaybackService::currentFileName() const
{
    if (m_playlistIndex >= 0 && m_playlistIndex < m_playlist.size()) {
        return m_playlist.at(m_playlistIndex).fileName();
    }
    return QString();
}

int VideoPlaybackService::playlistCount() const
{
    return m_playlist.size();
}

int VideoPlaybackService::currentIndex() const
{
    return m_playlistIndex;
}

void VideoPlaybackService::playNext()
{
    if (m_playlist.isEmpty()) return;

    m_playlistIndex++;
    if (m_playlistIndex >= m_playlist.size()) {
        if (m_loopMode == 2 || m_loopMode == 0) { 
            // Reiniciar la lista completa (loop full list)
            if (m_playlistOrder == 1 && m_playlist.size() > 1) {
                // Aleatorizar el orden (shuffle)
                for (int i = m_playlist.size() - 1; i > 0; --i) {
                    int j = QRandomGenerator::global()->bounded(i + 1);
                    m_playlist.swapItemsAt(i, j);
                }
            }
            m_playlistIndex = 0;
            loadIndex(m_playlistIndex);
        } else {
            m_playerPort->stop();
        }
    } else {
        loadIndex(m_playlistIndex);
    }
}

void VideoPlaybackService::playPrevious()
{
    if (m_playlist.isEmpty()) return;

    m_playlistIndex--;
    if (m_playlistIndex < 0) {
        m_playlistIndex = m_playlist.size() - 1;
    }
    loadIndex(m_playlistIndex);
}

void VideoPlaybackService::updatePlaylist()
{
    m_updateTimer->start();
}

void VideoPlaybackService::doUpdatePlaylist()
{
    m_playlist.clear();
    m_playlistIndex = -1;

    if (m_source.isEmpty()) {
        m_playerPort->stop();
        return;
    }

    if (m_sourceType == 0) {
        m_playlist.append(m_source);
    } else if (m_sourceType == 1) {
        QString localPath = m_source.toLocalFile();
        QDir dir(localPath);
        if (dir.exists()) {
            QStringList filters;
            filters << QStringLiteral("*.mp4") << QStringLiteral("*.mkv") 
                    << QStringLiteral("*.avi") << QStringLiteral("*.mov") 
                    << QStringLiteral("*.webm") << QStringLiteral("*.ogv");
            dir.setNameFilters(filters);
            dir.setFilter(QDir::Files | QDir::Readable | QDir::NoSymLinks);
            QFileInfoList fileList = dir.entryInfoList();
            for (const QFileInfo &fileInfo : fileList) {
                m_playlist.append(QUrl::fromLocalFile(fileInfo.absoluteFilePath()));
            }
        }
    } else if (m_sourceType == 2) {
        QString rawString = m_source.toString();
        QStringList parts = rawString.split(QStringLiteral(";"), Qt::SkipEmptyParts);
        for (const QString &part : parts) {
            m_playlist.append(QUrl(part.trimmed()));
        }
    }

    if (m_playlist.isEmpty()) {
        m_playerPort->stop();
        return;
    }

    if (m_playlistOrder == 1 && m_playlist.size() > 1) {
        for (int i = m_playlist.size() - 1; i > 0; --i) {
            int j = QRandomGenerator::global()->bounded(i + 1);
            m_playlist.swapItemsAt(i, j);
        }
    }

    m_playlistIndex = 0;
    emit playlistUpdated();
    loadIndex(m_playlistIndex);
}

void VideoPlaybackService::loadIndex(int index)
{
    if (index < 0 || index >= m_playlist.size()) {
        m_playerPort->stop();
        return;
    }

    // Asegurar que el modo de bucle nativo esté sincronizado al cambiar la fuente
    m_playerPort->setInfiniteLoop(m_loopMode == 0);
    m_playerPort->setSource(m_playlist.at(index));
    emit currentTrackChanged();

    if (!isSuspended()) {
        m_playerPort->play();
    }
}
