#include "backend.h"

#include <QLibrary>
#include <QSettings>
#include <QString>
#include <QTimer>

typedef void * ( * JpcGetHandleFunction)();
typedef bool   ( * JpcOpenFunction)        (void * );
typedef bool   ( * JpcCloseFunction)       (void * );
typedef bool   ( * JpcOpenPortFunction)    (void * , char *);
typedef bool   ( * JpcDeductValueFunction) (void *, const double);
typedef bool   ( * JpcAddValueFunction)    (void *, const double);
typedef bool   ( * JpcReturnValueFunction) (void *);
typedef void   ( * JpcSetOptionsFunction)  (void*, const bool, const bool, const bool, const bool);
typedef int    ( * JpcGetErrorFunction)    (void * );
typedef double ( * JpcReadValueFunction)   (void * );

BackEnd::BackEnd(QObject * parent): QObject(parent) {
    qDebug() << "Backend::Backend()";

//  settings.setIniCodec("UTF-8");

    m_jamexBalance = 0.00;

    jamexIsConnected = false;

    if (QLibrary::isLibrary("JPClibs.dll")) {
//      qDebug() << "JAMEX LIBRARY FOUND!";
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
    jpc_deduct_value_func = (JpcDeductValueFunction) jamexLib.resolve("jpc_deduct_value");
    jpc_add_value_func = (JpcAddValueFunction) jamexLib.resolve("jpc_add_value");
    jpc_return_value_func = (JpcReturnValueFunction) jamexLib.resolve("jpc_return_value");
    jpc_set_options_func = (JpcSetOptionsFunction) jamexLib.resolve("jpc_set_options");

    if (jamexLib.load()) {
//      qDebug() << "Jamex library loaded!";
    } else {
        qDebug() << "Failed to load Jamex library!";
    }
}

void BackEnd::jamexConnect() {
    qDebug() << "JAMEX IS CONNECTED: " << jamexIsConnected;
    if ( ! jamexIsConnected ) {
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
}

// This method just returns the amount we have stored internally
QString BackEnd::jamexBalance() {
    jamexConnect();

    m_jamexBalance = jpc_read_value_func( jpcHandle );
    qDebug() << "JAMEX BALANCE: " << QString::number(m_jamexBalance);

    return QString::number(m_jamexBalance);
}

void BackEnd::jamexDeductValue( const QString & value ) {
    qDebug() << "BackEnd::jamexDeductValue(" << value << ")";

    jamexDeductValueSucceeded = false;

    double amount = value.toDouble();

    jamexDeductValueSucceeded = jpc_deduct_value_func( jpcHandle, amount );
}

QString BackEnd::jamexDeductValueSuccess() {
    return jamexDeductValueSucceeded ? "true" : "false";
}

void BackEnd::jamexAddValue( const QString & value ) {
    qDebug() << "BackEnd::jamexAddValue(" << value << ")";

    jamexAddValueSucceeded = false;

    double amount = value.toDouble();

    jamexAddValueSucceeded = jpc_add_value_func( jpcHandle, amount );
}

QString BackEnd::jamexAddValueSuccess() {
    return jamexAddValueSucceeded ? "true" : "false";
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

bool BackEnd::jamexReturnBalance() {
    jpc_return_value_func( jpcHandle );
    return true;
}

bool BackEnd::jamexEnableChangeCardReturn() {
    jpc_set_options_func(jpcHandle, true, true, true, true);
    return true;
}

bool BackEnd::jamexDisableChangeCardReturn() {
    jpc_set_options_func(jpcHandle, false, true, true, true);
    return true;
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

// Valid values are "Windowed", "Maximized", or "FullScreen"
QString BackEnd::mainWindowVisibility() {
    QString libkiMainWindowVisibility = settings.value("client/visibility").toString();
    qDebug() << "CLIENT MAIN WINDOW VISIBILITY: " << libkiMainWindowVisibility;
    if ( libkiMainWindowVisibility.length() > 0 ) {
        return libkiMainWindowVisibility;
    } else {
        return "Windowed";
    }
}

QString BackEnd::appPreventExit() {
    QString setting = settings.value("client/prevent_exit").toString();
    qDebug() << "CLIENT APP PREVENT EXIT: " << setting;
    if ( setting == "yes" ) {
        return "yes";
    } else {
        return "no";
    }
}

QString BackEnd::appBackdoorUsername() {
    QString setting = settings.value("client/backdoor_username").toString();
    qDebug() << "CLIENT BACKDOOR USERNAME: " << setting;
    return setting;
}

QString BackEnd::appBackdoorPassword() {
    QString setting = settings.value("client/backdoor_password").toString();
    qDebug() << "CLIENT BACKDOOR PASSWORD: " << setting;
    return setting;
}
