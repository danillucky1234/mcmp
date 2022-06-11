#include "static.h"

QByteArray Static::readFromFile(const QString &fileName)
{
    QByteArray data;
    QFile file(fileName);
    if(!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Error while opening the file: " + fileName;
        qDebug() << file.errorString();
        return data;
    }

    data = file.readAll();
    file.close();
    return data;
}

bool Static::fileCopy(const QString &source, const QString &destination)
{
    bool result = true;
    QFile sourceFile(source);
    QFile destinationFile(destination);
    if (sourceFile.open(QIODevice::ReadOnly) && destinationFile.open(QIODevice::WriteOnly)) {
        destinationFile.write(sourceFile.readAll());
        sourceFile.close();
        destinationFile.close();
    } else {
        result = false;
    }
    return result;
}

bool Static::writeToFile(const QString &text, const QString &filePath)
{
    bool result = true;
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(text.toUtf8());
        file.close();
    } else {
        qDebug() << "Can not write to file " << filePath;
        result = false;
    }
    return result;
}

bool Static::fileDelete(const QString &fileName)
{
    return QFile::remove(QDir::toNativeSeparators(fileName));
}

bool Static::modifyValueInJson(const QString &filePath, const QString &key, const QString &value)
{
    // 1. read the whole file
    QByteArray data = readFromFile(filePath);

    // 2. parse json
    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(data, &jsonParseError);
    if (jsonDocument.isNull()) {
        qDebug() << "While parsing json document was occured error: " << jsonParseError.errorString();
        return false;
    }

    // 3. change value
    QJsonObject settings = jsonDocument.object();
    QString previousValue = settings[key].toString();
    settings[key] = value;

    // 4. rewrite whole file
    writeToFile(QJsonDocument(settings).toJson(), filePath);

    qDebug() << "Changes in " << filePath << ". Key: " << key << ". " << previousValue << " -> " << value;
    return true;
}

QStringList Static::getMusicFilesFromDirectory(const QString &directoryPath)
{
    QDir dir(directoryPath);
    if (!dir.exists()) {
        qDebug() << "Invalid directory path. " + directoryPath + " is not exists";
        return QStringList();
    }
    QStringList allowedFileTypes {"*.mp3", "*.MP3", "*.wav", "*.WAV", "*.mp4", "*.MP4"};
    return dir.entryList(allowedFileTypes, QDir::Files);
}

QString Static::getBaseNameFromPath(const QString &filepath)
{
    QString result{""};
    QString relativePathPrefix {"file:///"};
    QString relativeQmlPrefix  {"qrc:"};
    QFile file;
    file.setFileName( filepath.startsWith(relativePathPrefix) ?
                        filepath.mid(relativePathPrefix.length() - 1)
                    : (filepath.startsWith(relativeQmlPrefix) ? filepath.mid(relativeQmlPrefix.length() - 1) :
                                                                filepath)
                     );
    if (file.exists()) {
        result = QFileInfo(file.fileName()).baseName();
    } else {
        qDebug() << "file " << file.fileName() << " doesn't exists!";
    }
    return result;
}
