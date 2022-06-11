#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include "logger.h"
#include "QmlAdapter.h"
#include "TracksModel.h"
#include "PlaylistsModel.h"

const QString DEFAULT_CONFIG = "{\"theme\":\"default.json\"}";

#ifdef Q_OS_ANDROID
#include <QtAndroid>

bool requestStoragePermission() {
    using namespace QtAndroid;

    QString permission = QStringLiteral("android.permission.WRITE_EXTERNAL_STORAGE");
    const QHash<QString, PermissionResult> results = requestPermissionsSync(QStringList({permission}));
    if (!results.contains(permission) || results[permission] == PermissionResult::Denied) {
        qWarning() << "Couldn't get permission: " << permission;
        return false;
    }

    return true;
}
#endif

void fillTracksModel(TracksModel *tracksModel, const QString &directoryPath);
void fillPlaylistsModel(PlaylistsModel *playlistsModel, const QmlAdapter &qmlAdapter);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QT_DEFAULT_MESSAGE_HANDLER = qInstallMessageHandler(myMessageOutput);
    qDebug() << "------------------------ PROJECT STARTED ------------------------";

#ifdef Q_OS_ANDROID
    if (!requestStoragePermission())
        return -1;
#endif

    QQmlApplicationEngine engine;

    // Read data from settings file and get previous saved data. For example, user theme
    QString configFilesLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QDir::separator();
    QString configFilePath = configFilesLocation + "config.json";
    QByteArray data = Static::readFromFile(configFilePath);
    if (data.isEmpty()) {
        qDebug() << "Config file is empty. Trying to create default config file";

        // Copy default settings.json to config folder
        if(!Static::writeToFile(DEFAULT_CONFIG, configFilePath)) {
            qDebug() << "Error while writing default config to configFile!";
            return -1;
        }
        data = DEFAULT_CONFIG.toUtf8();
    }
    QJsonObject config = QJsonDocument::fromJson(data).object();


    QmlAdapter qmlAdapter(&app);
    qmlAdapter.setConfigFile(configFilePath);
    qmlAdapter.setDatabasePath(configFilesLocation + "database.db");
    qmlAdapter.setTheme(config["theme"].toString());

    // Fill models
    TracksModel tracksModel;
    PlaylistsModel playlistsModel;
    // When user add new track to playlist a view will be updated
    QObject::connect(&qmlAdapter, &QmlAdapter::addedPlaylistToDatabase,
                     &playlistsModel, &PlaylistsModel::addNewPlaylist);
    QObject::connect(&qmlAdapter, &QmlAdapter::addedTrackToPlaylist,
                     &playlistsModel, &PlaylistsModel::addNewTrackToPlaylist);
    QObject::connect(&qmlAdapter, &QmlAdapter::trackDeletedFromPlaylist,
                     &playlistsModel, &PlaylistsModel::trackDeletedFromPlaylist);

    QString musicDirectory = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + QDir::separator();
    fillTracksModel(&tracksModel, QDir(musicDirectory).absolutePath());
    fillPlaylistsModel(&playlistsModel, qmlAdapter);

    engine.rootContext()->setContextProperty("QmlAdapter", &qmlAdapter);
    engine.rootContext()->setContextProperty("TracksModel", &tracksModel);
    engine.rootContext()->setContextProperty("PlaylistsModel", &playlistsModel);

    engine.load("qrc:/main.qml");

    return app.exec();
}

void fillTracksModel(TracksModel *tracksModel, const QString &directoryPath) {
    qDebug() << "direcotryPath: " << directoryPath;
    QStringList files = Static::getMusicFilesFromDirectory(directoryPath);
    QString relativePathPrefix{"file://"};
    QString filepath;

    foreach(const QString &filename, files) {
        filepath = relativePathPrefix + directoryPath + "/" + filename;
        qDebug() << filepath;
        tracksModel->addTrack(filepath);
    }
}

void fillPlaylistsModel(PlaylistsModel *playlistsModel, const QmlAdapter &qmlAdapter) {
    QString query {"SELECT id, title, icon FROM Playlists"};

    // Get all available playlists from database
    QVariantList playlists = qmlAdapter.executeQuery(query);

    QStringList tracksPaths;
    QVariantList executionResult;

    Playlist playlist;
    for (const auto &item : playlists) {
        qDebug() << "Playlist info: ";
        qDebug() << "id: " << item.toMap()["id"].toInt();
        qDebug() << "title: " << item.toMap()["title"].toString();
        qDebug() << "icon: " << item.toMap()["icon"].toString();

        playlist.setTitle(item.toMap()["title"].toString());
        playlist.setImageIcon(item.toMap()["icon"].toString());

        // While user don't tap on the playlist we don't load files to playlistModel, only shows count of tracks in playlist
        query = "SELECT COUNT(1) as count FROM Tracks WHERE playlistId = " + item.toMap()["id"].toString();
        executionResult = qmlAdapter.executeQuery(query);
        qDebug() << "executionResult: " << executionResult;
        playlist.setTracksCount(executionResult.at(0).toMap()["count"].toInt());

        playlistsModel->addPlaylist(playlist);
        playlist.clear();
    }
}
