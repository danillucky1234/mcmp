#include "DatabaseConnector.h"

DatabaseConnector::DatabaseConnector(QObject *parent)
    : QObject(parent)
{
}

DatabaseConnector::~DatabaseConnector()
{
}

QVariantList DatabaseConnector::executeQuery(const QString &sqlString)
{
    if (!m_database.isOpen()) {
        this->openDataBase();
    }
    qDebug() << "query: " + sqlString;

    QSqlQuery query(m_database);
    query.prepare(sqlString);
    return this->executeQuery(query);
}

QVariantList DatabaseConnector::executeQuery(QSqlQuery query)
{
    if (!m_database.isOpen()) {
        this->openDataBase();
    }
    QVariantList result;
    bool sqlExecuteResult = query.exec();
    if (!sqlExecuteResult) {
        qDebug() << "database query execution error: " << query.lastError().text();
    } else {
        result = this->dataSetToJsonObject(query);
    }
    qDebug() << "query execution result: " << this->dataSetToString(query);
    return result;
}

QString DatabaseConnector::getDatabasePath() const
{
    return m_databasePath;
}

void DatabaseConnector::setDatabasePath(QString databasePath)
{
    if (m_databasePath != databasePath) {
        qDebug() << "database path was update from " << m_databasePath << " to: " << databasePath;
        m_databasePath = databasePath;
        emit databaseChanged();
    }
}

void DatabaseConnector::openDataBase()
{
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setHostName("dbHostName");
    m_database.setDatabaseName(getDatabasePath());
    if(m_database.open()) {
        qDebug() << "database was successfully opened!";
    } else {
        qDebug() << "database open error: " << m_database.lastError().text();
    }
}

void DatabaseConnector::closeDataBase()
{
    m_database.close();
}

QString DatabaseConnector::dataSetToString(QSqlQuery query)
{
    QString result = "[";
    query.first();
    do {
        result += "{";
        for (int i = 0; i < query.record().count(); i++) {
            QString fieldName = query.record().fieldName(i);
            result += "\"" + fieldName + "\": \"" + query.value(fieldName).toString() + "\",";
        }
        result = result.replace(result.length()-1, 2, "},");
    } while (query.next());
    result = result.replace(result.length()-1, 1, "]");
    return result;
}

QVariantList DatabaseConnector::dataSetToJsonObject(QSqlQuery query)
{
    QVariantList dataSet;
    query.first();
    if (query.isValid()) {
        do {
            QVariantMap row;
            for (int i = 0; i < query.record().count(); i++) {
                QString fieldName = query.record().fieldName(i);
                row.insert(fieldName, query.value(fieldName));
            }
            dataSet << row;
        } while (query.next());
    }
    return dataSet;
}
