#ifndef BACKEND_H
#define BACKEND_H

#include <QLibrary>
#include <QObject>
#include <QSettings>
#include <QString>

#include <qqml.h>

typedef void * ( * JpcGetHandleFunction)();
typedef bool( * JpcOpenFunction)(void * );
typedef bool( * JpcOpenPortFunction)(void * , char * );
typedef int( * JpcGetErrorFunction)(void * );
typedef double( * JpcReadValueFunction)(void * );

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

    JpcGetHandleFunction jpc_get_handle_func;
    JpcOpenFunction jpc_open_func;
    JpcOpenPortFunction jpc_open_port_func;
    JpcGetErrorFunction jpc_get_error_func;
    JpcReadValueFunction jpc_read_value_func;

    void * jpcHandle;

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
    double jamexBalance;

private slots:
    void fetchJamexBalance();
};

#endif // BACKEND_H
