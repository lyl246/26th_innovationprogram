//本文件用来管理参考运动的相关变量与函数 2 ~7 62
#ifndef REF_H
#define REF_H

#define Move_ConstVel 1
#define Move_Sin 2
#define Move_Cos 3
#define Force_const 4

#define MAX_ConstvVel 35*M_PI/180
class myRef
{
private:
public:
    int Reftype=0;float xref_new[3]; float xref_old[3];  float u_ref=0.0;
    float time_ref=0.0;
    myRef(int Movetype);//构造函数不需要返回类型
    float u[10]={0.8,1.0,1.2,1.5,1.7,2.0,2.2,2.4,2.6,2.8};
    int U_num=0;float Max_Torque=this->u[0];
    void Ref_Init();//参考运动的初始化
    void Ref_Update(float time_ref,float dt);
    bool Ref_IfStart=false;
    int  Ref_ifEnd();       //在定时器函数中调用，用来判断参考运动什么时候停止
};

#endif // REF_H
