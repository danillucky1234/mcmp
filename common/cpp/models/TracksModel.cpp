#include "TracksModel.h"

int TracksModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid()) { return 0; }

    return m_trackPaths.size();
}

QVariant TracksModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) { return QVariant(); }

    switch (role) {
        case PathRole:
            return m_trackPaths.at(index.row());
        break;
        default:
            return QVariant();
    }
}

QHash<int, QByteArray> TracksModel::roleNames() const
{
    static QHash<int, QByteArray> mapping {
        {PathRole, "path"}
    };
    return mapping;
}

TracksModel::TracksModel(QObject *parent)
{
    Q_UNUSED(parent);
}

void TracksModel::addTrack(const QString &filePath)
{
    beginInsertRows(QModelIndex(), m_trackPaths.size(), m_trackPaths.size() + 1);
    m_trackPaths.append(filePath);
    endInsertRows();
}

QStringList TracksModel::getTracks() const
{
    return m_trackPaths;
}
