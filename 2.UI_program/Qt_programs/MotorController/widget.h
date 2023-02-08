#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include <qdir.h>
#include <qtextstream.h>
#include <string.h>
#include <iostream>
#include <QMainWindow>
#include <QDebug>
#include <QTextStream>
#include <QtMath>


namespace Ui {
class Widget;
}

class Widget : public QWidget
{
    Q_OBJECT

public:
    explicit Widget(QWidget *parent = 0);
    ~Widget();
    Ui::Widget *ui;
private:
    /* 用来记录速度和位置 ,待删除*/
    float pos_old=0.0;    float pos_new=0.0;    float vel_real=0.0;

private slots:
    /*内部槽函数*/
    void read_emit();                       //定时器服务函数
    void read_addComboBox(QString portName);
    void read_showMotorPara();
    void read_showSensorPara();
    /*按钮服务函数*/
    void on_SerialButton1_clicked();        //按钮——打开电机串口
    void on_SerialButton2_clicked();        //按钮——打开力传感器串口
    void on_MotorButton_clicked();          //按钮——改变电机在线状态
    void on_MoveStartButton_clicked();      //按钮——开始参考运动
    void on_DataStartButton_clicked();      //按钮——开始录入数据
    void on_DataEndButton_clicked();        //按钮——结束录入数据，停止参考运动
    void on_NextTorqueButton_clicked();     //下一组torque数据
};

#endif // WIDGET_H
