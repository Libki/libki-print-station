#ifndef BACKEND_H
#define BACKEND_H

#include <QLibrary>
#include <QObject>
#include <QSettings>
#include <QString>

#include <qqml.h>

typedef void * ( * JpcGetHandleFunction)();
typedef bool   ( * JpcOpenFunction)        (void * );
typedef bool   ( * JpcCloseFunction)       (void * );
typedef bool   ( * JpcOpenPortFunction)    (void * , char *);
typedef bool   ( * JpcDeductValueFunction) (void *, const double);
typedef bool   ( * JpcReturnValueFunction) (void *);
typedef void   ( * JpcSetOptionsFunction)  (void*, const bool, const bool, const bool, const bool);
typedef int    ( * JpcGetErrorFunction)    (void * );
typedef double ( * JpcReadValueFunction)   (void * );

class BackEnd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(QString userPassword READ userPassword WRITE setUserPassword NOTIFY userPasswordChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress)
    Q_PROPERTY(QString serverApiKey READ serverApiKey)
    Q_PROPERTY(QString mainWindowVisibility READ mainWindowVisibility)
    Q_PROPERTY(QString jamexBalance READ jamexBalance NOTIFY jamexBalanceChanged)
    Q_PROPERTY(QString jamexDeductAmount READ jamexDeductValueSuccess WRITE jamexDeductValue)
    Q_PROPERTY(bool jamexReturnBalance READ jamexReturnBalance)
    Q_PROPERTY(bool jamexEnableChangeCardReturn READ jamexEnableChangeCardReturn)
    Q_PROPERTY(bool jamexDisableChangeCardReturn READ jamexDisableChangeCardReturn)
    QML_ELEMENT

public:
    explicit BackEnd(QObject *parent = nullptr);

    QString userName();
    void setUserName(const QString &userName);

    QString userPassword();
    void setUserPassword(const QString &userPassword);

    QString serverAddress();

    QString serverApiKey();

    QString mainWindowVisibility();

    QString jamexBalance();

    bool jamexReturnBalance();

    bool jamexEnableChangeCardReturn();
    bool jamexDisableChangeCardReturn();

    void jamexDeductValue(const QString &value);
    QString jamexDeductValueSuccess();

signals:
    void userNameChanged();
    void userPasswordChanged();
    void jamexBalanceChanged();

private:
    QString m_userName;
    QString m_userPassword;
    double m_jamexBalance;

    bool jamexIsConnected;

    bool jamexDeductValueSucceeded;

    void * jpcHandle;

    QSettings settings;

    void jamexConnect();
    void jamexDisconnect();

    JpcGetHandleFunction jpc_get_handle_func;
    JpcOpenFunction jpc_open_func;
    JpcCloseFunction jpc_close_func;
    JpcOpenPortFunction jpc_open_port_func;
    JpcGetErrorFunction jpc_get_error_func;
    JpcReadValueFunction jpc_read_value_func;
    JpcDeductValueFunction jpc_deduct_value_func;
    JpcReturnValueFunction jpc_return_value_func;
    JpcSetOptionsFunction jpc_set_options_func;

private slots:
    void fetchJamexBalance();
};

#endif // BACKEND_H
