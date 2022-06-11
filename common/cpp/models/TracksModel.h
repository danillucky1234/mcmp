#ifndef TRACKSMODEL_H
#define TRACKSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QModelIndex>
#include <QString>
#include <QList>
#include <QHash>
#include <QByteArray>

class TracksModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit TracksModel(QObject *parent = nullptr);

    void addTrack(const QString &filePath);

    // QAbstractItemModel interface
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;
    enum TrackRoles {
        PathRole = Qt::UserRole + 1
    };

public slots:
    QStringList getTracks() const;

private:
    QStringList m_trackPaths;
};

#endif // TRACKSMODEL_H
