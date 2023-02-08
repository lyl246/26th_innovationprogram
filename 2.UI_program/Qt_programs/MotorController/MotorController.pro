#-------------------------------------------------
#
# Project created by QtCreator 2022-06-19T16:56:10
#
#-------------------------------------------------

QT       += core gui
QT       += serialport
QT       += serialbus widgets
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = MotorController
TEMPLATE = app

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


SOURCES += \
        main.cpp \
        widget.cpp \
    can.cpp \
    motor.cpp \
    ref.cpp \
    timer.cpp \
    sensor.cpp \
    controller.cpp

HEADERS += \
        widget.h \
    can.h \
    motor.h \
    ref.h \
    timer.h \
    sensor.h \
    controller.h

FORMS += \
        widget.ui
