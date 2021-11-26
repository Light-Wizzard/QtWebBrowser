TEMPLATE = app
TARGET = QtWebBrowser
QT += core gui webenginewidgets

HEADERS += \
    src/browser.h \
    src/browserwindow.h \
    src/downloadmanagerwidget.h \
    src/downloadwidget.h \
    src/tabwidget.h \
    src/webpage.h \
    src/webpopupwindow.h \
    src/webview.h

SOURCES += \
    src/browser.cpp \
    src/browserwindow.cpp \
    src/downloadmanagerwidget.cpp \
    src/downloadwidget.cpp \
    src/main.cpp \
    src/tabwidget.cpp \
    src/webpage.cpp \
    src/webpopupwindow.cpp \
    src/webview.cpp

FORMS += \
    src/certificateerrordialog.ui \
    src/passworddialog.ui \
    src/downloadmanagerwidget.ui \
    src/downloadwidget.ui

RESOURCES += data/QtWebBrowser.qrc

# install
#target.path = $$[QT_INSTALL_EXAMPLES]/webenginewidgets/simplebrowser
#INSTALLS += target

DISTFILES += \
    README.md
