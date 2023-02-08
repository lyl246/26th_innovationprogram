#ifndef MOTOR_H
#define MOTOR_H
#include<stdint.h>
#include <QDebug>
//弹簧阻尼运动特征
#define Damper 10
#define Spring 10
#define Mass   10
#define CMD_MOTOR_MODE      0x01
#define CMD_RESET_MODE      0x02
#define CMD_ZERO_POSITION   0x03

#define P_MIN -95.5f    // Radians
#define P_MAX 95.5f
#define V_MIN -45.0f    // Rad/s
#define V_MAX 45.0f
#define KP_MIN 0.0f     // N-m/rad
#define KP_MAX 500.0f
#define KD_MIN 0.0f     // N-m/rad/s
#define KD_MAX 5.0f
#define T_MIN -18.0f
#define T_MAX 18.0f
class myMotor
{
private:
    void ZeroPosition();
    uint16_t  float_to_uint(float x, float x_min, float x_max, uint8_t bits);
public:
   float motor_accel=0;
   float motor_speed=0;float motor_speed2=0;
   float motor_postion=0;
   bool  motor_status=false;

   float Wanted_force=0;
   float Wanted_accel=0;
   float Wanted_speed=0;
   float Wanted_postion=0;

   void Motor_Start();      // 在发送电机位置零前，需要把电机的所有控制参数设置为0
   void SendControlCmd(uint8_t cmd);
   void SendControlPara(float f_p, float f_v, float f_kp, float f_kd, float f_t);
   void ReadMotorPara(QByteArray buf);
   float uint_to_float(int x_int, float x_min, float x_max, int bits);
};

#endif // MOTOR_H
