#include "PlaylistsModel.h"

PlaylistsModel::PlaylistsModel(QObject *parent)
{
    Q_UNUSED(parent);
}

int PlaylistsModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid()) { return 0; }

    return m_playlists.size();
}

QVariant PlaylistsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) { return QVariant(); }

    const Playlist &playlist = m_playlists.at(index.row());
    switch (role) {
       case TitleRole:
           return playlist.getTitle();
       break;
       case TracksCountRole:
           return playlist.getTracksCount();
       break;
       case PlaylistIconRole:
           return playlist.getIconPath();
       case TracksRole:
           return playlist.getTracks();
       default:
           return QVariant();
       }
}

void PlaylistsModel::addNewPlaylist(const QString &title, const QString &icon)
{
    beginInsertRows(QModelIndex(), m_playlists.size(), m_playlists.size() + 1);
    Playlist playlist (title, icon);
    m_playlists.append(playlist);
    endInsertRows();
}

void PlaylistsModel::addPlaylist(const Playlist &playlist)
{
    beginInsertRows(QModelIndex(), m_playlists.size(), m_playlists.size() + 1);
    m_playlists.append(playlist);
    endInsertRows();
}

void PlaylistsModel::addNewTrackToPlaylist(const QString &trackPath, int playlistId)
{
    if (playlistId < 0 || playlistId >= m_playlists.size()) {return;}
    m_playlists[playlistId].addTrack(trackPath);
    emit tracksCountChanged();
}

void PlaylistsModel::trackDeletedFromPlaylist(const QString &trackPath, int playlistId)
{
    if (playlistId < 0 || playlistId >= m_playlists.size()) {return;}
    m_playlists[playlistId].deleteByPath(trackPath);
    emit tracksCountChanged();
}

void PlaylistsModel::setTracksByIndex(const QStringList &tracks, int index)
{
    if (index < 0 || index >= m_playlists.size()) {return;}
    m_playlists[index].setTracks(tracks);
}

QString PlaylistsModel::getTitle(int index) const
{
    if (index < 0 || index >= m_playlists.size()) {return QString();}
    return m_playlists[index].getTitle();
}

QStringList PlaylistsModel::getTracks(int index) const
{
    if (index < 0 || index >= m_playlists.size()) {return QStringList();}
    return m_playlists[index].getTracks();
}

QHash<int, QByteArray> PlaylistsModel::roleNames() const
{
    static QHash<int, QByteArray> mapping {
        {TitleRole, "title"},
        {TracksCountRole, "count"},
        {PlaylistIconRole, "playlistIcon"},
        {TracksRole, "tracks"}
    };
    return mapping;
}
