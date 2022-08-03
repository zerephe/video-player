#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <filedialog.h>
#include <QQuickView>

//void preventAutoLock() {
//    QAndroidJniObject activity = QtAndroid::androidActivity();
//    if (activity.isValid()) {
//        QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

//        if (window.isValid()) {
//            const int FLAG_KEEP_SCREEN_ON = 128;
//            window.callObjectMethod("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
//        }
//    }
//}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);

    qmlRegisterType<FileDialog>("FileDialog", 1, 0, "FileDialog");
    FileDialog w;

//    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);


    return app.exec();
}
