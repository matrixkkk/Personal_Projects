#include "AI.h"
#include <windows.h>

CAi::CAi()
{
	x=0;	//�̵��ؾ��� x��ǥ
	y=0;	//�̵��ؾ��� y��ǥ
	action=0;
}

void CAi::AIaction(CBall *ball,CPlayer *user,CPlayer *com)
{
	CPoint3 BallPos;	//���� ��ġ ����
	CPoint3 Original_spot;
	CPoint3 tmp_v;
	SDL_Rect ComPos;	//com�� ��ġ ����.
	ball_physics tmp;

	BallPos=ball->GetBallPos();		//���� ��ġ ��� ��
	if(ball->GetBallDir()==1) //������ ģ ����
	{
		//x=BallPos.x;
		tmp=ball->GetBallPhysics();
		Original_spot=ball->Getoriginal_spot();
		tmp_v.y=tmp.v*cos(R(tmp.height_degree))*3.3f;
		tmp_v.x=tmp_v.y/tan(R(-tmp.width_degree));
		x=Original_spot.x+tmp_v.x*FPM;
	}
	else //com�� ģ ����
	{
		x=0;
	}
	ComPos=com->getRect();	//com�� ��ġ�� ��� ��

	if( check_collision( com->getBoundingBox(), ball->GetBallShadowBounceBox() ) )
	{
	    com->Swing(BallPos.x);
	}
	else
        com->Stand();


	if(ComPos.x+10>x)	//���� ��ġ�� �ڱ� ���� ���� ���.
	{
		action=1;	//1 �� ���� �̵�
		com->SetLeft(true);
		com->LeftWalk();
		com->SetRight(false);
	}
	else if(ComPos.x+90<x)
	{
		action=2;
		com->SetRight(true);
		com->RightWalk();
		com->SetLeft(false);
	}
	else
	{
		com->SetLeft(false);
		com->SetRight(false);
	}
}