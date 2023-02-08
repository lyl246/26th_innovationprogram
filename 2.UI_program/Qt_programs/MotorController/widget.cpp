#include "widget.h"
#include "ui_widget.h"
#include <stdio.h>
#include "can.h"
#include "motor.h"
#include "ref.h"
#include "timer.h"
#include "sensor.h"

myMotor motor;
myRef ref(Force_const);//Move_Sin,Move_Cos,Force_const
myCan can;
myTimer timer(0.01f);//定时器启动，开始计数0.01s
mySensor sensor;

Widget::Widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Widget)
{
    ui->setupUi(this);
    //更新UI界面的说明
    switch (ref.Reftype) {
    case Move_ConstVel:
        ui->label_1->setText("测试说明：当前测试为跟踪运动的恒速模式。参考运动指示条会从零开始做恒速运动，请保持关节角度跟随参考条运动");
        break;
    case Move_Sin:
        ui->label_1->setText("测试说明：当前测试为跟踪运动的Sin振荡模式。参考运动指示条会从零开始做Sin振荡运动，请保持关节角度跟随参考条运动");
        break;
    case Move_Cos:
        ui->label_1->setText("测试说明：当前测试为跟踪运动的Cos振荡模式。参考运动指示条会从零开始做Cos振荡运动，请保持关节角度跟随参考条运动");
        break;
    case Force_const:
        ui->label_1->setText("测试说明：当前测试为恒力模式。力矩指示条会从零上升至期望值，请保持关节角度不变");
        break;
    }
    QObject::connect(&can, SIGNAL(start_addComboBox(QString)), this, SLOT(read_addComboBox(QString)));
    QObject::connect(&timer, SIGNAL(start_emit()), this, SLOT(read_emit()));
    QObject::connect(&can, SIGNAL(start_showMotorPara()), this, SLOT(read_showMotorPara()));    
    QObject::connect(&can, SIGNAL(start_showSensorPara()), this, SLOT(read_showSensorPara()));
    can.SearchSerial();//查找可用串口
    qDebug()<<sin(30);
    qDebug()<<sin(30.0/180*M_PI);
}

Widget::~Widget()
{
    delete ui;
}
//int timernum=0;
//定时器的信号槽函数
void Widget::read_emit(){
    //timernum=timer.TimeCNT;
    //更新滑块的参考位置和速度,

    ui->T_Ref->setValue(motor.Wanted_force*10);//滑动条分辨率只有1，放大比例系数=10
    ui->V_Ref->setValue(-ref.xref_new[2]);
    if(ref.Reftype==Move_Sin){
        ui->P_Ref->setValue(-ref.xref_new[1]/M_PI*180);
        ui->V_Ref->setValue(-ref.xref_new[2]/M_PI*180);
    }
    else if(ref.Reftype==Force_const)
    {
        ui->P_Ref->setValue(-ref.xref_new[1]/M_PI*180);
    }

    //更新测试组数的进度条
    ui->progressBar->setValue(can.filenum);
}

//串口的搜索串口名的槽函数
void Widget::read_addComboBox(QString portName){
    ui->comboBox->addItem(portName);
}
//串口中收到电机数据更新,更新在UI界面上
void Widget::read_showMotorPara(){
//更新进度条
    ui->T_Real->setValue(motor.motor_accel*10); //滑动条分辨率只有1，放大比例系数=10倍
    //ui->V_Real->setValue(motor.motor_speed);
    ui->V_Real->setValue(motor.motor_speed2);
    ui->P_Real->setValue(motor.motor_postion);
//更新textlable
    ui->label_4->setText("当前位置为"+QString::number(motor.motor_postion)+"°");
    ui->label_5->setText("当前速度为"+QString::number(motor.motor_speed2)+"°/s");
    ui->label_6->setText("当前时间为"+QString::number(ref.time_ref)+"s");
    //ui->label_6->setText("当前电流为"+QString::number(motor.motor_accel)+" ");
}

//串口中收到力传感器数据,更新在UI界面上
void Widget::read_showSensorPara(){
    ui->label_7->setText("当前力矩为"+QString::number(sensor.force)+"N");
}

//按钮的信号槽函数——打开电机串口
void Widget::on_SerialButton1_clicked()
{
   can.OpenClose_Serial(SerialMotor);//打开选中串口

   if (can.ifSerialOpen[SerialMotor]==true){
       ui->SerialButton1->setText(tr("MotorOpened"));       
       timer.TimerStart();
   }
   else{
       ui->SerialButton1->setText(tr("MotorClosed"));
       timer.TimerStop();
   }
   ui->label_3->setText("当前力矩值为"+QString::number(ref.Max_Torque,'f',1)+"NM，本组测试将进行15次");
}
//按钮的信号槽函数——打开力传感器串口
void Widget::on_SerialButton2_clicked()
{
    can.OpenClose_Serial(Forcesensor);//打开选中串口
    if (can.ifSerialOpen[Forcesensor]==true){
        ui->SerialButton2->setText(tr("SensorOpened"));
    }
    else{
        ui->SerialButton2->setText(tr("SensorClosed"));
    }
}

//按钮的信号槽函数——改变电机在线状态
void Widget::on_MotorButton_clicked(){
    if(motor.motor_status==false){
        motor.Motor_Start();
        ui->MotorButton->setText(tr("Motor: Online"));
    }
    else{
        motor.SendControlCmd(CMD_RESET_MODE);
        ui->MotorButton->setText(tr("Motor: Offline"));
    }
    motor.motor_status=!(motor.motor_status);
}

//按钮的信号槽函数——开始参考运动
void Widget::on_MoveStartButton_clicked(){
    ref.Ref_IfStart=true;
    ref.Ref_Init();
    can.StartSave();
}



//按钮的信号槽函数——开始录入数据
void Widget::on_DataStartButton_clicked(){
    can.StartSave();
}

//按钮的信号槽函数——结束录入数据，停止参考运动
void Widget::on_DataEndButton_clicked(){
    timer.TimerStop();
    can.StopSave();
//    ui->Ref_Slider->setValue(0);
//    ui->Ref_Slider_2->setValue(0);
    //ui->label_3->setText(QString::number(timernum));
    ui->label_2->setText("当前状态：当前数据已完成保存，可以开始下组测试");
}

void Widget::on_NextTorqueButton_clicked(){
    ref.U_num++;
    ref.Max_Torque=ref.u[ref.U_num];
    can.filenum=1;
    ui->label_3->setText("当前力矩值为"+QString::number(ref.Max_Torque,'f',1)+"NM，本组测试将进行15次");
    //显示当前的torque值
}
