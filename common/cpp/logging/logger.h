#ifndef LOGGER_H
#define LOGGER_H

#include <QtMessageHandler>
#include <QString>
#include <QDateTime>
#include <QFile>
#include <QTextStream>

#define __LOG_FILE_MAX_SIZE__ (4000 * 1024)  // Max log-file size
#define __LOG_FILE_CUT_SIZE__ (2000 * 1024)  // The size of the "trimmed" part of the log file

static QtMessageHandler QT_DEFAULT_MESSAGE_HANDLER;

QString __DEBUG_FILE_PATH__ = "";

void myMessageOutput(QtMsgType type, const QMessageLogContext &context,
                     const QString &msg) {
    QFile file(__DEBUG_FILE_PATH__ + "debug.log");
    if(!file.open(QIODevice::Append | QIODevice::WriteOnly)) { return; }
    if (file.size() > __LOG_FILE_MAX_SIZE__) {
        QFile tmpFile(__DEBUG_FILE_PATH__ + "tmp.log");
        if (tmpFile.open(QIODevice::WriteOnly)) {
            file.close();
            if (file.open(QIODevice::ReadOnly) && file.seek(__LOG_FILE_CUT_SIZE__)) {
                tmpFile.write(file.read(file.size() - __LOG_FILE_CUT_SIZE__));
                file.remove();
                tmpFile.rename(__DEBUG_FILE_PATH__ + "debug.log");
            }
        }
        tmpFile.close();
        file.close();
        if (!file.open(QIODevice::Append | QIODevice::Text)) {
            return;
        }
    }

    QString sCurrDateTime = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QTextStream tsTextStream(&file);
    switch(type){
        case QtDebugMsg:
            tsTextStream << QString("Debug [%1]: %2\n").arg(sCurrDateTime).arg(msg);
            break;
        case QtWarningMsg:
            // do nothing
            break;
        case QtCriticalMsg:
            tsTextStream << QString("Critical [%1]: %2\n").arg(sCurrDateTime).arg(msg);
            break;
        case QtFatalMsg:
            tsTextStream << QString("Fatal [%1]: %2\n").arg(sCurrDateTime).arg(msg);
            break;
        default:
            tsTextStream << "Unrecognized qt message type";
            break;
    }
    tsTextStream.flush();
    file.flush();
    file.close();
    // Print logs in console and in the log-file
    (*QT_DEFAULT_MESSAGE_HANDLER)(type, context, msg);
}

#endif // LOGGER_H
