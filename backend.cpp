#include "backend.h"

#include <QLibrary>

BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    QLibrary jpcLibs("JPClibs");
    jpcLibs.load();
    if ( jpcLibs.isLoaded() ) {
        qDebug() << "JAMEX LIBRARY LOADED SUCCESSFULLY";
    } else {
        qDebug() << "JAMEX LIBRARY FAILED TO LOAD";
    }

//  typedef void (*MyPrototype)(int*, int*, int*);
//  MyPrototype sub = (MyPrototype) myLib.resolve("sub");
//  if (sub) {
//      sub(&a, &b, &c);
//  }

    typedef void* (*JpcGetHandleFunction)();
    JpcGetHandleFunction jpc_get_handle_func = (JpcGetHandleFunction) jpcLibs.resolve("jpc_get_handle");

    typedef bool (*JpcOpenFunction)(void*);
    JpcOpenFunction jpc_open_func = (JpcOpenFunction) jpcLibs.resolve("jpc_open");

    typedef int (*JpcGetErrorFunction)(void*);
    JpcGetErrorFunction jpc_get_error_func = (JpcGetErrorFunction) jpcLibs.resolve("jpc_get_error");

    void* handle;
    if (jpc_get_handle_func) {
        qDebug() << "Sub jpc_get_handle exists!";
        handle = jpc_get_handle_func();
        qDebug() << "HANDLE: " << handle;

        if ( handle ) {
            bool is_open;
            is_open = jpc_open_func( handle );
            qDebug() << "IS OPENED: " << is_open;

            if ( is_open ) {
                qDebug() << "HANDLE IS OPEN!";
            } else {
                qDebug() << "HANDLE FAILED TO OPEN!";
                int error;
                error = jpc_get_error_func(handle);
                qDebug() << "ERRROR CODE: " << error;
            }
        }
        //jpc_get_handle_func(&a, &b, &c);
        //handle = jpc_get_handle_func();
        //qDebug() << "HANDLE: " << handle;
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
