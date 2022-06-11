#ifndef DATABASECONNECTOR_H
#define DATABASECONNECTOR_H

#include <QObject>
#include <QSql>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlDatabase>
#include <QFile>
#include <QSqlRecord>
#include <QVariantMap>
#include <QVariantList>
#include <QDebug>

class DatabaseConnector : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseConnector(QObject *parent = nullptr);
    ~DatabaseConnector();

    QVariantList executeQuery(const QString &sqlString);
    QVariantList executeQuery(QSqlQuery query);

    Q_PROPERTY(QString databasePath READ getDatabasePath WRITE setDatabasePath NOTIFY databaseChanged);

    QString getDatabasePath() const;

signals:
    void databaseChanged();

public slots:
    void setDatabasePath(QString databasePath);
    void closeDataBase();

private:
    QSqlDatabase m_database;
    QString m_databasePath;

    void            openDataBase();
    QString         dataSetToString(QSqlQuery query);
    QVariantList    dataSetToJsonObject(QSqlQuery query);
};

#endif // DATABASECONNECTOR_H
