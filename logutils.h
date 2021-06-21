#ifndef LOGUTILS_H
#define LOGUTILS_H

#define LOGSIZE 1024 * 100 //log size in bytes
#define LOGFILES 20

#include <QDate>
#include <QDebug>
#include <QObject>
#include <QStandardPaths>
#include <QString>
#include <QTime>

namespace LogUtils
{
    const QString logFolderDir = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    const QString logFolderName = logFolderDir + "/libki-jamex";

    bool initLogging();
    void myMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString& msg);
}

#endif // LOGUTILS_H
