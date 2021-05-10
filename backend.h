#ifndef BACKEND_H
#define BACKEND_H

#include <QLibrary>
#include <QObject>
#include <QSettings>
#include <QString>

#include <qqml.h>

class BackEnd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(QString userPassword READ userPassword WRITE setUserPassword NOTIFY userPasswordChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress)
    Q_PROPERTY(QString serverApiKey READ serverApiKey)
    QML_ELEMENT

public:
    explicit BackEnd(QObject *parent = nullptr);

    QSettings settings;

    QString userName();
    void setUserName(const QString &userName);

    QString userPassword();
    void setUserPassword(const QString &userPassword);

    QString serverAddress();

    QString serverApiKey();

signals:
    void userNameChanged();
    void userPasswordChanged();

private:
    QString m_userName;
    QString m_userPassword;
};

#endif // BACKEND_H
