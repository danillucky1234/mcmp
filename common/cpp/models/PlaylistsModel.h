#ifndef PLAYLISTSMODEL_H
#define PLAYLISTSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QModelIndex>
#include <QString>
#include <QList>
#include <QHash>
#include <QByteArray>
#include "Playlist.h"

class PlaylistsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PlaylistsModel(QObject *parent = nullptr);

    void addPlaylist(const Playlist &playlist);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
    void tracksCountChanged(); // When we add new track to playlist, view should be updated

public slots:
    void addNewPlaylist(const QString &title, const QString &icon);
    void addNewTrackToPlaylist(const QString &trackPath, int playlistId);
    void trackDeletedFromPlaylist(const QString &trackPath, int playlistId);
    void setTracksByIndex(const QStringList &tracks, int index);
    QString getTitle(int index) const;
    QStringList getTracks(int index) const;

protected:
    QHash<int, QByteArray> roleNames() const override;
    enum PlaylistRoles {
        TitleRole = Qt::UserRole + 1,
        TracksCountRole,
        PlaylistIconRole,
        TracksRole
    };

private:
    QList<Playlist> m_playlists;
};

#endif // PLAYLISTSMODEL_H
