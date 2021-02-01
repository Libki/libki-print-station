#include "backend.h"

#include <QLibrary>

BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
    QLibrary myLib("JPClibs");
    myLib.load();
    if ( myLib.isLoaded() ) {
        qDebug() << "JAMEX LIBRARY LOADED SUCCESSFULLY";
    } else {
        qDebug() << "JAMEX LIBRARY FAILED TO LOAD";
    }

    typedef void* (*JpcGetHandleFunction)();
    JpcGetHandleFunction jpc_get_handle_func = (JpcGetHandleFunction) myLib.resolve("jpc_get_handle");

    void* handle;
    if (sub) {
        qDebug() << "Sub jpc_get_handle exists!";
        //sub(&a, &b, &c);
        handle = sub();
        qDebug() << "HANDLE: " << handle;
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
