QT += quick core sql svg multimedia
android: qtHaveModule(androidextras) {
    QT += androidextras

    DISTFILES += \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/gradle.properties \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew \
        android/gradlew.bat \
        android/res/values/libs.xml

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

CONFIG += c++14

SOURCES += \
        ../main.cpp \

RESOURCES += \
        ../common/qml/qml.qrc \
        ../common/themes/themes.qrc \
        ../common/images/images.qrc \

# include .pri files
include($$PWD/../common/cpp/logging/logging.pri)
include($$PWD/../common/cpp/databaseConnector/databaseConnector.pri)
include($$PWD/../common/cpp/qml_adapter/QmlAdapter.pri)
include($$PWD/../common/cpp/static/static.pri)
include($$PWD/../common/cpp/ssl/ssl.pri)
include($$PWD/../common/cpp/models/models.pri)
