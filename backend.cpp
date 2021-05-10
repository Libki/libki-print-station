#include "backend.h"

#include <QLibrary>
#include <QSettings>

typedef void * ( * JpcGetHandleFunction)();
typedef bool( * JpcOpenFunction)(void * );
typedef bool( * JpcOpenPortFunction)(void * , char * );
typedef int( * JpcGetErrorFunction)(void * );
typedef double( * JpcReadValueFunction)(void * );

BackEnd::BackEnd(QObject * parent): QObject(parent) {
    settings.setIniCodec("UTF-8");

    if (QLibrary::isLibrary("JPClibs.dll")) {
        qDebug() << "JAMEX LIBRARY FOUND!";
    } else {
        qDebug() << "JAMEX LIBRARY NOT FOUND!?!";
    }

    QLibrary jamexLib("JPClibs");
    JpcGetHandleFunction jpc_get_handle_func = (JpcGetHandleFunction) jamexLib.resolve("jpc_get_handle");
    JpcOpenFunction jpc_open_func = (JpcOpenFunction) jamexLib.resolve("jpc_open");
    JpcOpenPortFunction jpc_open_port_func = (JpcOpenPortFunction) jamexLib.resolve("jpc_open_port");
    JpcGetErrorFunction jpc_get_error_func = (JpcGetErrorFunction) jamexLib.resolve("jpc_get_error");
    JpcReadValueFunction jpc_read_value_func = (JpcReadValueFunction) jamexLib.resolve("jpc_read_value");

    if (jamexLib.load()) {
        qDebug() << "Jamex library loaded!";
    } else {
        qDebug() << "Failed to load Jamex library!";
    }

    void * handle;
    if (jpc_get_handle_func) {
        handle = jpc_get_handle_func();
        qDebug() << "HANDLE: " << handle;

        bool is_open = false;

        if (handle) {
            is_open = jpc_open_func(handle);
            qDebug() << "RESULT OF jpc_open: " << is_open;

            if (!is_open) {
            int error;
            error = jpc_get_error_func(handle);
            qDebug() << "ERRROR CODE: " << error;
            }
            //TODO: Add some kind of popup if there is an error connecting

            double val = jpc_read_value_func( handle );
            qDebug() << "VAL: " << val;
        }
    }
}

QString BackEnd::serverAddress() {
    QString libkiServerAddress = settings.value("server/address").toString();
    qDebug() << "LIBKI SERVER ADDRESS: " << libkiServerAddress;
    return libkiServerAddress;
}

QString BackEnd::serverApiKey() {
    QString libkiServerApiKey = settings.value("server/api_key").toString();
    qDebug() << "LIBKI SERVER API KEY: " << libkiServerApiKey;
    return libkiServerApiKey;
}

QString BackEnd::userName() {
    m_userName = settings.value("user/username").toString();
    return m_userName;
}

void BackEnd::setUserName(const QString & userUsername) {
    qDebug() << "BackEnd::setUserName";

    QString username = settings.value("user/username").toString();

    if (userUsername == username)
        return;

    m_userName = userUsername;
    settings.setValue("user/username", userUsername);
    emit userNameChanged();
}

QString BackEnd::userPassword() {
    return m_userPassword;
}

void BackEnd::setUserPassword(const QString & userPassword) {
    qDebug() << "BackEnd::setUserPassword";

    if (userPassword == m_userPassword)
        return;

    m_userPassword = userPassword;
    emit userPasswordChanged();
}
