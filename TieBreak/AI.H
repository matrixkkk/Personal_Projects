#ifndef _AI_H_
#define _AI_H_

#include "common.h"
#include "ball.h"
#include "Player.h"

class CAi
{
private:
	int x;	//�̵��ؾ��� x��ǥ
	int y;	//�̵��ؾ��� y��ǥ
	int action;		//0 :stand 1:left �̵� 2:right �̵�
public:
	CAi();
	void AIaction(CBall *ball,CPlayer *user,CPlayer *com);
};

#endif