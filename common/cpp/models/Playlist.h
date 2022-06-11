#ifndef PLAYLISTL_H
#define PLAYLISTL_H

#include <QString>
#include <QList>

class Playlist
{
public:
    Playlist();
    Playlist(const QString &title);
    Playlist(const QString &title, const QString &iconpath);
    Playlist(const QString &title, const QString &iconpath, const QStringList &tracksPaths);

    QString getTitle() const;
    QStringList getTracks() const;
    uint getTracksCount() const;
    QString getIconPath() const;

    void setTitle(const QString &newTitle);
    void addTrack(const QString &filepath);
    void setTracks(const QStringList &paths);
    void setImageIcon(const QString &iconpath);
    void setTracksCount(uint count);
    void deleteByPath(const QString &path);

    void clear();
private:
    QString m_title;
    QString m_imagePath;
    QStringList m_paths;
    int m_tracksCount {0}; // We add this variable because before stringlist with path's will be loaded we should get info about count of tracks in our playlist. For dynamic loading of tracks when playlist is opening
};

#endif // PLAYLISTL_H
