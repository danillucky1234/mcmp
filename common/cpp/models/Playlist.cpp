#include "Playlist.h"


Playlist::Playlist() {}

Playlist::Playlist(const QString &title)
    : m_title(title)
{

}

Playlist::Playlist(const QString &title, const QString &iconpath)
    : m_title(title), m_imagePath(iconpath)
{

}

Playlist::Playlist(const QString &title, const QString &iconpath, const QStringList &tracksPaths)
    : m_title(title), m_imagePath(iconpath), m_paths(tracksPaths)
{

}

QString Playlist::getTitle() const{ return m_title; }

QStringList Playlist::getTracks() const{ return m_paths; }

uint Playlist::getTracksCount() const
{
    return m_tracksCount;
}

QString Playlist::getIconPath() const { return m_imagePath; }

void Playlist::setTitle(const QString &newTitle)
{
    m_title = newTitle;
}

void Playlist::addTrack(const QString &filepath)
{
    m_paths.append(filepath);
    ++m_tracksCount;
}

void Playlist::setTracks(const QStringList &paths)
{
    m_paths = paths;
    m_tracksCount = m_paths.size();
}

void Playlist::setImageIcon(const QString &iconpath)
{
    m_imagePath = iconpath;
}

void Playlist::setTracksCount(uint count)
{
    m_tracksCount = count;
}

void Playlist::deleteByPath(const QString &path)
{
    for (int i = 0; i < m_tracksCount; ++i) {
        if (m_paths[i] == path) {
            m_paths.removeAt(i);
            --m_tracksCount;
            break;
        }
    }
}

void Playlist::clear()
{
    m_paths.clear();
}
