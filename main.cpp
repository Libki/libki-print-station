#include "logutils.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);

    LogUtils::initLogging();

    QCoreApplication::setOrganizationName("Libki");
    QCoreApplication::setOrganizationDomain("libki.org");
    QCoreApplication::setApplicationName("Libki Print Station");

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings settings;
//  settings.setIniCodec("UTF-8");

    QQmlApplicationEngine engine("qrc:/main.qml");
    return app.exec();
}
