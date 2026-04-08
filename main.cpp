#include "logutils.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQuickStyle>
#include <QFont>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);

    LogUtils::initLogging();

    QQuickStyle::setStyle("Basic");

    QCoreApplication::setOrganizationName("Libki");
    QCoreApplication::setOrganizationDomain("libki.org");
    QCoreApplication::setApplicationName("Libki Print Station");

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings settings;
//  settings.setIniCodec("UTF-8");

    QFont _font(settings.value("font/font_family","Arial").toString(), settings.value("font/font_size",14).toInt());
    app.setFont(_font);

    QQmlApplicationEngine engine("qrc:/main.qml");
    return app.exec();
}
