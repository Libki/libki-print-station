QT += quick

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

CONFIG += qmltypes
QML_IMPORT_NAME = io.qt.libki_jamex.backend
QML_IMPORT_MAJOR_VERSION = 1

SOURCES += \
        backend.cpp \
        logutils.cpp \
        main.cpp

RESOURCES += qml.qrc

TRANSLATIONS += \
    LibkiPrintStation_en_US.ts

RC_FILE += LibkiPrintStation.rc
RC_ICONS = libki_print.ico

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    backend.h \
    jamex/JPClibs.h \
    logutils.h

INCLUDEPATH += 3rdparty/JPClibs/include

DISTFILES += \
    libki_print.ico
