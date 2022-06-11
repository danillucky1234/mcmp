#ifndef QML_ADAPTER_H
#define QML_ADAPTER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QGuiApplication>
#include <QScreen>
#include <QFile>
#include <QBuffer>
#include <QImage>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QUrl>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QStandardPaths>

#include "static.h"
#include "DatabaseConnector.h"

static const QString __CHAT_ID__   {""};
static const QString __BOT_TOKEN__ {""};

class QmlAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(float scalefactor READ getScaleFactor WRITE setScaleFactor NOTIFY scaleFactorChanged);
    Q_PROPERTY(QJsonObject colors READ getColors NOTIFY themeChanged);
    Q_PROPERTY(QString unknownTitle READ unknownTitle CONSTANT);
    Q_PROPERTY(QString unknownAuthor READ unknownAuthor CONSTANT);

public:
    explicit QmlAdapter(QObject *parent = nullptr);
    ~QmlAdapter();

    void setConfigFile(const QString &filePath);

    float getScaleFactor() const;

    QString unknownTitle() const { return "Unknown title"; }

    QString unknownAuthor() const { return "Unknown author"; }

    void setScaleFactor(const float &scaleFactor);

    QJsonObject getColors() const;

    void closeDatabaseConnection() const;

    void setDatabasePath(const QString &dbPath) const;

public slots:
    QString getImagePath(const QString &imageName) const;
    QString getBaseNameFromPath(const QString &filepath) const;
    void addNewPlaylistToDatabase(const QVariantList &data);
    void addNewTrackToPlaylist(const QVariantList &data);
    void deleteTrackFromPlaylist(const QVariantList &data);
    QVariantList executeQuery(const QString &query) const;
    QString getBase64FromImage(const QString &image) const;
    void sendBugReport() const;

    /*
     * @{param} themeName - For example: default.json
     */
    void setTheme(const QString &themeName);

signals:
    void addedPlaylistToDatabase(const QString &title, const QString &icon);
    void addedTrackToPlaylist(const QString &trackPath, int playlistId);
    void trackDeletedFromPlaylist(const QString &trackPath, int playlistId);
    void themeChanged();  // When user change theme signal is emitted and view refreshes
    void scaleFactorChanged();

private:
    QString     m_urlToTheme;
    QJsonObject m_theme;
    QString     m_configFilePath;
    float       m_scaleFactor;

    DatabaseConnector *m_sqlite;

private:
    QString getThemesPath(const QString &themePath = "") const;
    void initialiseStartDatabaseData() const;
    bool isTrackAlreadyExistsInPlaylist(const QVariantList &data) const;
    bool playlistAlreadyExists(const QVariantList &data) const;
};

#endif // QML_ADAPTER_H
