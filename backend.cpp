#include "backend.h"

#include <QLibrary>

BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    if ( QLibrary::isLibrary("JPClibs.dll") ) {
        qDebug() << "JAMEX LIBRARY FOUND!";
    } else {
        qDebug() << "JAMEX LIBRARY NOT FOUND!?!";
    }

    QLibrary lib("JPClibs");
    lib.load();

    if ( lib.isLoaded() ) {
        qDebug() << "JAMEX LIBRARY LOADED SUCCESSFULLY";
    } else {
        qDebug() << "JAMEX LIBRARY FAILED TO LOAD: " << lib.errorString();
    }

    typedef void* (*JpcGetHandleFunction)();
    //JpcGetHandleFunction jpc_get_handle_func = (JpcGetHandleFunction) lib.resolve("jpc_get_handle");
    auto jpc_get_handle_func = (JpcGetHandleFunction) lib.resolve("jpc_get_handle");
    if ( jpc_get_handle_func ) {
        qDebug() << "SYMBOL jpc_get_handle WAS LOADED!";
    } else {
        qDebug() << "SYMBOL jpc_get_handle WAS NOT LOADED!";
    }

    typedef bool (*JpcOpenFunction)(void*);
    //JpcOpenFunction jpc_open_func = (JpcOpenFunction) lib.resolve("jpc_open");
    auto jpc_open_func = (JpcOpenFunction) lib.resolve("jpc_open");
    if ( jpc_open_func ) {
        qDebug() << "SYMBOL jpc_open WAS LOADED!";
    } else {
        qDebug() << "SYMBOL jpc_open WAS NOT LOADED!";
    }

    typedef bool (*JpcOpenPortFunction)(void*, char*);
    //JpcOpenPortFunction jpc_open_port_func = (JpcOpenPortFunction) lib.resolve("jpc_open_port");
    auto jpc_open_port_func = (JpcOpenPortFunction) lib.resolve("jpc_open_port");
    if ( jpc_open_port_func ) {
        qDebug() << "SYMBOL jpc_open_port WAS LOADED!";
    } else {
        qDebug() << "SYMBOL jpc_open_port WAS NOT LOADED!";
    }

    typedef int (*JpcGetErrorFunction)(void*);
    //JpcGetErrorFunction jpc_get_error_func = (JpcGetErrorFunction) lib.resolve("jpc_get_error");
    auto jpc_get_error_func = (JpcGetErrorFunction) lib.resolve("jpc_get_error");
    if ( jpc_get_error_func ) {
        qDebug() << "SYMBOL jpc_get_error WAS LOADED!";
    } else {
        qDebug() << "SYMBOL jpc_get_error WAS NOT LOADED!";
    }

    void* handle;
    if (jpc_get_handle_func) {
        handle = jpc_get_handle_func();
        qDebug() << "HANDLE: " << handle;

        bool is_open = false;

        if ( handle ) {
            if ( !is_open ) {
                is_open = jpc_open_func( handle );
                qDebug() << "RESULT OF jpc_open: " << is_open;

                if ( !is_open ) {
                    int error;
                    error = jpc_get_error_func(handle);
                    qDebug() << "ERRROR CODE: " << error;
                }
            }

            if ( !is_open ) {
                char* port = strdup("COM4");
                is_open = jpc_open_port_func( handle, port );
                qDebug() << "RESULT OF jpc_open_port: " << is_open;

                if ( !is_open ) {
                    int error;
                    error = jpc_get_error_func(handle);
                    qDebug() << "ERROR CODE: " << error;
                }
            }
        }
    } else {
        qDebug() << "Sub jpc_get_handle does not exist!";
    }
}

QString BackEnd::userName()
{
    return m_userName;
}

void BackEnd::setUserName(const QString &userName)
{
    qDebug() << "BackEnd::setUserName";

    if (userName == m_userName)
        return;

    m_userName = userName;
    emit userNameChanged();
}

QString BackEnd::userPassword()
{
    return m_userPassword;
}

void BackEnd::setUserPassword(const QString &userPassword)
{
    qDebug() << "BackEnd::setUserPassword";

    if (userPassword == m_userPassword)
        return;

    m_userPassword = userPassword;
    emit userPasswordChanged();
}
