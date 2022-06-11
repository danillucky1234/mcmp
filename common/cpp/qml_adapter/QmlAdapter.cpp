#include "QmlAdapter.h"

QmlAdapter::QmlAdapter(QObject *parent)
    : QObject(parent)
{
    int width = QGuiApplication::primaryScreen()->size().width();
    int height = QGuiApplication::primaryScreen()->size().height();

    setScaleFactor(((width > height)?height:width)/320.0);
    qDebug() << "scaleFactor: " << m_scaleFactor;
    m_sqlite = new DatabaseConnector(this);
}

QmlAdapter::~QmlAdapter()
{
    if (m_sqlite) { m_sqlite->deleteLater(); }
}

void QmlAdapter::setTheme(const QString &themeName)
{
    QString urlToTheme = this->getThemesPath(themeName);
    if (m_urlToTheme != urlToTheme) {
        m_urlToTheme = urlToTheme;
        qDebug() << "The app theme was changed to: " << urlToTheme;
        QByteArray data = Static::readFromFile(urlToTheme);
        qDebug() << themeName << ": " << data;
        m_theme = QJsonDocument::fromJson(data).object();

        // Change theme in settings.json
        Static::modifyValueInJson(m_configFilePath, "theme", themeName);
        emit themeChanged();
    }
}


void QmlAdapter::setConfigFile(const QString &filePath)
{
    m_configFilePath = filePath;
}

float QmlAdapter::getScaleFactor() const
{
    return m_scaleFactor;
}

void QmlAdapter::setScaleFactor(const float &scaleFactor)
{
    if (scaleFactor != m_scaleFactor) {
        m_scaleFactor = scaleFactor;
        emit scaleFactorChanged();
    }
}

QJsonObject QmlAdapter::getColors() const
{
    return m_theme;
}

QVariantList QmlAdapter::executeQuery(const QString &query) const
{
    return m_sqlite->executeQuery(query);
}

void QmlAdapter::closeDatabaseConnection() const
{
    m_sqlite->closeDataBase();
}

void QmlAdapter::setDatabasePath(const QString &dbPath) const
{
    m_sqlite->setDatabasePath(dbPath);
    this->initialiseStartDatabaseData();
}

void QmlAdapter::addNewPlaylistToDatabase(const QVariantList &data)
{
    if (playlistAlreadyExists(data)) { return; }
    QSqlQuery query;
    qDebug() << "addNewPlaylistToDatabase: " << data;
    query.prepare("INSERT INTO Playlists (title, icon) VALUES (?, ?)");
    query.addBindValue(data[0].toString());
    query.addBindValue(data[1].toString());

    m_sqlite->executeQuery(query);
    emit addedPlaylistToDatabase(data[0].toString(), data[1].toString());
}

void QmlAdapter::addNewTrackToPlaylist(const QVariantList &data)
{
    if (isTrackAlreadyExistsInPlaylist(data)) { return; }
    QSqlQuery query;
    QString insertQuery {"INSERT INTO Tracks (path, playlistId) VALUES (:path, :playlistId)"};
    qDebug() << QString(insertQuery).replace(":path", data[0].toString()).replace(":playlistId", QString::number(data[1].toInt() + 1));
    query.prepare(insertQuery);
    query.addBindValue(data[0].toString());
    query.addBindValue(data[1].toInt() + 1); // Add "1" because in our database id starts from 1

    m_sqlite->executeQuery(query);
    emit addedTrackToPlaylist(data[0].toString(), data[1].toInt()); // Send signal to Playlist, update tracksCount on the view
}

void QmlAdapter::deleteTrackFromPlaylist(const QVariantList &data)
{
    QSqlQuery query;
    QString deleteQuery = QString("DELETE FROM Tracks WHERE path = ':path' AND playlistId = ':playlistId'").replace(":path", data[0].toString()).replace(":playlistId", QString::number(data[1].toInt() + 1));
    qDebug() << deleteQuery;

    m_sqlite->executeQuery(deleteQuery);
    emit trackDeletedFromPlaylist(data[0].toString(), data[1].toInt()); // Send signal to Playlist, update tracksCount on the view
}

QString QmlAdapter::getBase64FromImage(const QString &path) const
{
    QBuffer buffer;
    buffer.open(QIODevice::WriteOnly);
    QString extension = QFileInfo(path).completeSuffix();
    QByteArray ba;
    QString imagePath {":" + path};
    if (extension == "svg" || extension == "SVG") {
        QFile input(imagePath);
        if(input.open(QIODevice::ReadOnly)) {
            ba = input.readAll();
            input.close();
        }
    } else {
        QImage qp;
        if(!qp.load(imagePath)) {
            return QString();
        }
        qp.save(&buffer, extension.toStdString().c_str());
        ba = buffer.data();
    }

    QString base64Prefix = QString("data:image/%1;base64,").arg(extension);
    return base64Prefix + ba.toBase64();
}

void QmlAdapter::sendBugReport() const
{
    QString debugPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QDir::separator();
    QString filePath {debugPath + "debug.log"};
    QFile *compressedFile = new QFile(filePath);
    if(!compressedFile->open(QIODevice::ReadOnly)) {
        delete compressedFile;
        qDebug() << "error while opnening file: " << compressedFile->errorString();
        return;
    }

    QNetworkAccessManager *manager = new QNetworkAccessManager();

    QString url = "https://api.telegram.org/bot%TOKEN%/sendDocument";
    url.replace("%TOKEN%", __BOT_TOKEN__);
    qDebug() << "CHAT_ID: " << __CHAT_ID__;
    qDebug() << "bot_TOKEN: " << __BOT_TOKEN__;

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart chatIdPart;
    chatIdPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"chat_id\""));
    chatIdPart.setBody(__CHAT_ID__.toUtf8());
    multiPart->append(chatIdPart);

    QHttpPart documentPart;
    documentPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"document\"; filename=\"debug.log\""));

    documentPart.setBody(compressedFile->readAll());
    compressedFile->setParent(multiPart);
    multiPart->append(documentPart);

    QNetworkReply *reply = manager->post(QNetworkRequest(QUrl(url)), multiPart);
    switch(reply->error()) {
    case QNetworkReply::NoError:
        qDebug() << "no errors";
        break;
    case QNetworkReply::UnknownServerError:
        qDebug() << "unknown server error";
        break;
    default:
        qDebug() << "wtf is this error" << reply->errorString();
        break;
    }
    multiPart->setParent(reply); // delete the multiPart with the reply
    delete compressedFile;
}

QString QmlAdapter::getBaseNameFromPath(const QString &filepath) const
{
    return Static::getBaseNameFromPath(filepath);
}

QString QmlAdapter::getImagePath(const QString &imageName) const
{
    return "/images/" + imageName;
}

QString QmlAdapter::getThemesPath(const QString &themePath) const
{
    return ":/themes/" + themePath;
}

void QmlAdapter::initialiseStartDatabaseData() const
{
    QString createTable_1 = "CREATE TABLE IF NOT EXISTS Playlists (id INTEGER PRIMARY KEY, title TEXT, icon BLOB)";
    m_sqlite->executeQuery(createTable_1);
    QString createTable_2 = "CREATE TABLE IF NOT EXISTS Tracks (id INTEGER PRIMARY KEY, path TEXT, playlistId INT)";
    m_sqlite->executeQuery(createTable_2);

    QString ifExistsPlaylist = "SELECT COUNT(1) as count FROM Playlists WHERE title = (?)";
    QSqlQuery query;
    query.prepare(ifExistsPlaylist);
    query.addBindValue("Favorites");
    auto result = m_sqlite->executeQuery(query);
    if (result.at(0).toMap()["count"].toInt() == 0) {
        QString createPlaylist = "INSERT INTO Playlists (title, icon) VALUES (?, ?)";

        const QString title {"Favorites"};
        const QString icon {this->getBase64FromImage(this->getImagePath("heart.svg"))};
        QSqlQuery queryCreatePlaylist;
        queryCreatePlaylist.prepare(createPlaylist);
        queryCreatePlaylist.addBindValue(title);
        queryCreatePlaylist.addBindValue(icon);

        m_sqlite->executeQuery(queryCreatePlaylist);
    }
}

bool QmlAdapter::isTrackAlreadyExistsInPlaylist(const QVariantList &data) const
{
    QSqlQuery query;
    QString checkAlreadyExistance {"SELECT 1 FROM Tracks WHERE path = :path AND playlistId = :playlistId"};
    qDebug() << QString(checkAlreadyExistance).replace(":path", data[0].toString()).replace(":playlistId", QString::number(data[1].toInt() + 1));
    query.prepare(checkAlreadyExistance);
    query.addBindValue(data[0].toString());
    query.addBindValue(data[1].toInt() + 1); // Add "1" because in our database id starts from 1

    auto result = m_sqlite->executeQuery(query);
    return result.size() > 0;
}

bool QmlAdapter::playlistAlreadyExists(const QVariantList &data) const
{
    QSqlQuery query;
    QString checkAlreadyExistance {"SELECT 1 FROM Playlists WHERE title = :title"};
    qDebug() << QString(checkAlreadyExistance).replace(":title", data[0].toString());
    query.prepare(checkAlreadyExistance);
    query.addBindValue(data[0].toString());

    auto result = m_sqlite->executeQuery(query);
    return result.size() > 0;
}
