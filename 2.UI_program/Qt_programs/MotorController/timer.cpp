#include "can.h"
#include "motor.h"
#include "ref.h"
#include "sensor.h"
#include "timer.h"
extern myMotor motor;
extern myCan can;
extern myRef ref;
extern mySensor sensor;

//新建以delta_t为间隔的定时器,重复触发，设置超时触发函数
myTimer::myTimer(float delta_t)
{
    this->dt=delta_t;
    m_timer = new QTimer();
    m_timer->setSingleShot(false);
    QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(slotTimeout()));
}

//定时器启动函数
void myTimer::TimerStart(){
    m_timer->start(1000*this->dt);
}

//定时器停止函数
void myTimer::TimerStop(){
    this->time_ref=0.0;
    m_timer->stop();
}

//定时器超时服务函数：更新滑块显示：力矩模式下的参考力矩+真实力矩，跟踪运动下的参考运动和真实运动
void myTimer::slotTimeout(){
    if(motor.motor_status==true){
        //motor.SendControlPara(0.0,0.0,0.0,0.0,motor.Wanted_force);
        motor.SendControlPara(0.0,0.0,0.0,0.0,0.0);
    }
    //qDebug()<<motor.Wanted_force;
    this->start_emit();//更新UI界面
    this->time_ref=this->time_ref+this->dt;
    if(ref.Ref_IfStart){
        ref.time_ref=ref.time_ref+this->dt;
        if(ref.Ref_ifEnd()){
            ref.Ref_Update(ref.time_ref,this->dt);
            can.AddSave(motor.motor_postion);//保存数据到文本文件
            can.AddSave(sensor.force);//保存数据到文本文件
            qDebug()<<"still";
        }
        else{
            ref.time_ref=0.0;
            motor.Wanted_force=0;
            ref.Ref_IfStart=false;
            can.StopSave();//this->on_DataEndButton_clicked();          //停止输出
            qDebug()<<"stop";
        }
    }
}



