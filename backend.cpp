#include "backend.h"

BackEnd::BackEnd(QObject *parent) :
    QObject(parent)
{
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
