#include "backend.h"

#include <QLibrary>
#include <QSettings>
#include <QString>
#include <QTimer>

typedef void * ( * JpcGetHandleFunction)();
typedef bool( * JpcOpenFunction)(void * );
typedef bool( * JpcCloseFunction)(void * );
typedef bool( * JpcOpenPortFunction)(void * , char * );
typedef int( * JpcGetErrorFunction)(void * );
typedef double( * JpcReadValueFunction)(void * );

BackEnd::BackEnd(QObject * parent): QObject(parent) {
    qDebug() << "Backend::Backend()";

    settings.setIniCodec("UTF-8");

    m_jamexBalance = 0.00;

    jamexIsConnected = false;

    if (QLibrary::isLibrary("JPClibs.dll")) {
        qDebug() << "JAMEX LIBRARY FOUND!";
    } else {
        qDebug() << "JAMEX LIBRARY NOT FOUND!?!";
    }

    QLibrary jamexLib("JPClibs");
    jpc_get_handle_func = (JpcGetHandleFunction) jamexLib.resolve("jpc_get_handle");
    jpc_open_func = (JpcOpenFunction) jamexLib.resolve("jpc_open");
    jpc_close_func = (JpcCloseFunction) jamexLib.resolve("jpc_close");
    jpc_open_port_func = (JpcOpenPortFunction) jamexLib.resolve("jpc_open_port");
    jpc_get_error_func = (JpcGetErrorFunction) jamexLib.resolve("jpc_get_error");
    jpc_read_value_func = (JpcReadValueFunction) jamexLib.resolve("jpc_read_value");

    if (jamexLib.load()) {
        qDebug() << "Jamex library loaded!";
    } else {
        qDebug() << "Failed to load Jamex library!";
    }
}

BackEnd::~BackEnd() {
    qDebug() << "BackEnd::~BackEnd()";
    jamexDisconnect();
}

void BackEnd::jamexConnect() {
    qDebug() << "JAMEX IS CONNECTED: " << jamexIsConnected;
    if ( ! jamexIsConnected ) {
        qDebug() << "I MADE IT IN";
        if (jpc_get_handle_func) {
            jpcHandle = jpc_get_handle_func();
            qDebug() << "HANDLE: " << jpcHandle;

            bool is_open = false;

            if (jpcHandle) {
                is_open = jpc_open_func(jpcHandle);
                qDebug() << "RESULT OF jpc_open: " << is_open;

                if (is_open) {
                    jamexIsConnected = true;
                } else {
                    int error;
                    error = jpc_get_error_func(jpcHandle);
                    qDebug() << "ERRROR CODE: " << error;

                    jamexIsConnected = false;
                }

                //TODO: Add some kind of popup if there is an error connecting?

                //double val = jpc_read_value_func( jpcHandle );
                //qDebug() << "VAL: " << val;

                //QTimer *timer = new QTimer(this);
                //connect(timer, SIGNAL(timeout()), this, SLOT(fetchJamexBalance()));
                //timer->start(500);
            }
        }
    }
}

void BackEnd::jamexDisconnect() {
    jpc_close_func(jpcHandle);
    jamexIsConnected = false;
}

// This method fetches the balance from the machine and updates the amount we have stored internally
void BackEnd::fetchJamexBalance() {
    jamexConnect();

    double newBalance = jpc_read_value_func( jpcHandle );
    if ( newBalance != m_jamexBalance ) {
        m_jamexBalance = newBalance;
        emit jamexBalanceChanged();
        qDebug() << "BackEnd::fetchJamexBalance: BALANCE CHANGED";
    }

    //jamexDisconnect();
}

// This method just returns the amount we have stored internally
QString BackEnd::jamexBalance() {
    jamexConnect();

    m_jamexBalance = jpc_read_value_func( jpcHandle );
    qDebug() << "JAMEX BALANCE: " << QString::number(m_jamexBalance);

    //jamexDisconnect();

    return QString::number(m_jamexBalance);
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
