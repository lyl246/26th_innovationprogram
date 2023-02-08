#include "ref.h"
#include "timer.h"
#include "motor.h"
extern myTimer timer;
extern myMotor motor;
myRef::myRef(int Reftype){
    this->Reftype = Reftype;
}

void myRef::Ref_Init(){
    /*清空ref信息，准备新生成一组参考数据*/
    this->time_ref=0;motor.Wanted_force=0;
    memset(this->xref_old,0,sizeof(this->xref_old));
    memset(this->xref_new,0,sizeof(this->xref_new));
    //修改初始值
    switch(this->Reftype){
        case Move_ConstVel:
        case Force_const:
            this->xref_old[2]=MAX_ConstvVel;
            break;
        case Move_Sin:
            this->xref_old[1]=0;this->xref_old[2]=-0.5;
            break;
        case Move_Cos:
            this->xref_old[1]=0;this->xref_old[2]=0.05;
            break;

    }
}

//每次运动中更新目标值
//矩阵运算待重写
void myRef::Ref_Update(float time_ref,float dt){
    double u_ref_han;
    switch(this->Reftype){
        case Move_ConstVel:
            this->xref_new[1]=this->xref_old[1]+dt*this->xref_old[2];
            this->xref_new[2]=this->xref_old[2];
            break;
        case Move_Sin:
            u_ref_han=0.01*sin(M_PI*time_ref/2);
            this->xref_new[1]=this->xref_old[1]+dt*this->xref_old[2]+0.0038*u_ref_han;
            this->xref_new[2]=this->xref_old[2]+0.7689*u_ref_han;
            break;
        case Move_Cos:
            u_ref_han=0.01*cos(M_PI*time_ref/2);
            this->xref_new[1]=this->xref_old[1]+dt*this->xref_old[2]+0.0038*u_ref_han;
            this->xref_new[2]=this->xref_old[2]+0.7689*u_ref_han;
            break;
        case Force_const:
            if(motor.Wanted_force<(Max_Torque-0.0001)){//条件为if<0.3，会变成0.315（可能是浮点数的精度问题）
                motor.Wanted_force=motor.Wanted_force+0.01;
            }
            else{
                this->xref_old[2]=MAX_ConstvVel;//要再给old赋值，否则下面的new会洗掉old的初值
                this->xref_new[1]=this->xref_old[1]+dt*this->xref_old[2];
                this->xref_new[2]=this->xref_old[2];
            }
            break;
    }
    this->xref_old[1]=this->xref_new[1];
    this->xref_old[2]=this->xref_new[2];
}

//在定时器函数中调用，用来判断参考运动什么时候停止
int myRef::Ref_ifEnd(){
    int stop_value=0;
    switch(this->Reftype){
        case Move_ConstVel:
        case Force_const:
        //if(this->xref_new[1]<=90*M_PI/180)
        if(this->time_ref<=500)
                stop_value=1;
        break;
        case Move_Sin:
        case Move_Cos:
            if(this->time_ref<=6)
                stop_value=1;
        break;
    }
    qDebug()<<this->xref_new[1];
    return stop_value;
}
