#include "widget.h"
#include <QApplication>
#include "can.h"
#include "motor.h"
#include "ref.h"
#include "timer.h"


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Widget w;

    w.show();

    return a.exec();
}
