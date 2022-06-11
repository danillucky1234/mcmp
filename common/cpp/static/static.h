#ifndef STATIC_H
#define STATIC_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValueRef>

class Static : public QObject
{
public:
    Static() {}

    static QByteArray readFromFile(const QString &fileName);
    static bool fileCopy(const QString &source, const QString &destination);
    static bool writeToFile(const QString &text, const QString &filePath);
    static bool fileDelete(const QString &fileName);
    static bool modifyValueInJson(const QString &filePath, const QString &key, const QString &value);

    static QStringList getMusicFilesFromDirectory(const QString &directoryPath);
    static QString getBaseNameFromPath(const QString &filepath);
};

#endif // STATIC_H
