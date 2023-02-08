#include "motor.h"
#include "can.h"
#include <QDebug>

#define LIMIT_MIN_MAX(x,min,max) (x) = (((x)<=(min))?(min):(((x)>=(max))?(max):(x)))

extern myCan can;

//每次开始新运动前调用，赋初始值
void myMotor::Motor_Start(){
    this->SendControlCmd(CMD_MOTOR_MODE);
    this->SendControlCmd(CMD_ZERO_POSITION);    //delay
    this->SendControlPara(0.0,0.0,0.0,0.0,0.0); //delay
}

//发送电机控制命令
void myMotor::SendControlCmd(uint8_t cmd){
    QString buf = "FFFFFFFFFFFFFF";
    switch(cmd){
        case CMD_MOTOR_MODE:
            buf.append("FC");
            break;
        case CMD_RESET_MODE:
            buf.append("FD");
        break;
        case CMD_ZERO_POSITION:
            buf.append("FE");//0.15748
        break;
        default:
        return; /* 直接退出函数 */
    }
    QByteArray sendbuf = QByteArray::fromHex(buf.toLatin1());
    can.SendData(sendbuf);
}
//发送电机控制参数
void myMotor::SendControlPara(float f_p, float f_v, float f_kp, float f_kd, float f_t){
    uint16_t p, v, kp, kd, t;
    uint8_t buf[8];

    /* 限制输入的参数在定义的范围内 */
    LIMIT_MIN_MAX(f_p,  P_MIN,  P_MAX);
    LIMIT_MIN_MAX(f_v,  V_MIN,  V_MAX);
    LIMIT_MIN_MAX(f_kp, KP_MIN, KP_MAX);
    LIMIT_MIN_MAX(f_kd, KD_MIN, KD_MAX);
    LIMIT_MIN_MAX(f_t,  T_MIN,  T_MAX);

    /* 根据协议，对float参数进行转换 */
    p = this->float_to_uint(f_p,      P_MIN,  P_MAX,  16);
    v = this->float_to_uint(f_v,      V_MIN,  V_MAX,  12);
    kp = this->float_to_uint(f_kp,    KP_MIN, KP_MAX, 12);
    kd = this->float_to_uint(f_kd,    KD_MIN, KD_MAX, 12);
    t = this->float_to_uint(f_t,      T_MIN,  T_MAX,  12);

    /* 根据传输协议，把数据转换为CAN命令数据字段 */
    buf[0] = p>>8;
    buf[1] = p&0xFF;
    buf[2] = v>>4;
    buf[3] = ((v&0xF)<<4)|(kp>>8);
    buf[4] = kp&0xFF;
    buf[5] = kd>>4;
    buf[6] = ((kd&0xF)<<4)|(t>>8);
    buf[7] = t&0xff;

    /*unit8转Qstring,不能直接一个QString转化，否则会出现00 00变为QBytearray中的*/
    QString buf2;    QByteArray sendbuf;
    for(int i=0;i<8;i++){
        buf2=QString::number(buf[i],16);
        sendbuf.append(QByteArray::fromHex(buf2.toLatin1()));
    }
    can.SendData(sendbuf);
}
//解析电机控制参数
void myMotor::ReadMotorPara(QByteArray recbuf){
    uint8_t buf[6];float oldp=0;
    for(int i=0;i<=5;i++){
        QByteArray tmp=recbuf.mid(i,1);
        QString hexstr = tmp.toHex();
        buf[i] = uint8_t( hexstr.toInt(NULL,16)); //表示以16进制方式读取字符串
    }
    uint16_t p = (buf[1]<<8)|(buf[2]);
    uint16_t v = (buf[3]<<4)|(buf[4]>>4);
    uint16_t t = ((buf[4]<<8)|(buf[5]))&0xfff;
    //qDebug()<<p;qDebug()<<v;qDebug()<<t;
    oldp=this->motor_postion;
    this->motor_postion = uint_to_float(p, P_MIN, P_MAX, 16)*180/M_PI;
    this->motor_speed2=(this->motor_postion-oldp)/0.05;//
    this->motor_speed=uint_to_float(v, V_MIN, V_MAX, 12)*180/M_PI;
    this->motor_accel = uint_to_float(t, T_MIN, T_MAX, 12);
}

//计算电机通信中的的运动参数
uint16_t myMotor::  float_to_uint(float x, float x_min, float x_max, uint8_t bits)
{
    float span = x_max - x_min;
    float offset = x_min;
    return (uint16_t) ((x-offset)*((float)((1<<bits)-1))/span);
}

//计算电机通信中的的运动参数
float myMotor:: uint_to_float(int x_int, float x_min, float x_max, int bits)
{
    float span = x_max - x_min;
    float offset = x_min;
    return ((float)x_int)*span/((float)((1<<bits)-1)) + offset;
}
