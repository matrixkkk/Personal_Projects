#include <SDL/SDL.h>
#include "GameApp.h"
#include "gamestate.h"
#include "introstate.h"
#include "playstate.h"
#include "ball.h"



CBall::CBall()
{
    SDL_Surface* temp = SDL_LoadBMP("BMP/ball.bmp");
  image = SDL_DisplayFormat(temp);
  temp=SDL_LoadBMP("BMP/shadow.bmp");
  shadow = SDL_DisplayFormat(temp);
  SDL_FreeSurface(temp);

  Uint32 colorkey = SDL_MapRGB(image->format, 255, 0, 0);  //컬러키 검정
  SDL_SetColorKey(image, SDL_RLEACCEL | SDL_SRCCOLORKEY, colorkey);

  colorkey = SDL_MapRGB(shadow->format, 255, 0, 0);  //컬러키 검정
  SDL_SetColorKey(shadow, SDL_RLEACCEL | SDL_SRCCOLORKEY, colorkey);
  Skill=false;

}

CBall::~CBall()
{
  SDL_FreeSurface(image);
  SDL_FreeSurface(shadow);
}

void CBall::init(int x,int y,int z)
{
	bool Inbound=false;           //바운드 여부�

	serveok=false;      //true : 서브중
	Service=false;
	time=0;				//타임 초기화
	BallDir=0;		//차례 초기화
	original_spot.x=x;  //위치 초기화
	original_spot.y=y;
	original_spot.z=z;
	quant.v=0;			//속도 초기화
	quant.height_degree=0;
	quant.width_degree=0;
	r=7;				// 반지름
	shadow_position=ball_position=original_spot; //그림자와 볼의 위치를 처음 위치로 초기화.
}

void CBall::ball_movement()
{
	float temp;
	time+=0.1f; //시간 변화율


	shadow_vector.y=quant.v*cos(R(quant.height_degree))*time;					 //그림자의 y 벡터
	shadow_position.y=original_spot.y+shadow_vector.y*FPM;		 //y 벡터 만큼 y위치 이동
	shadow_vector.z=(quant.v*sin(R(quant.height_degree))*time)-(0.5f*9.8f*time*time); //그림자의 z 벡터 (사실 그림자는 높이가 없으므로 볼의 높이나 다름없음)
	temp=shadow_position.z;
	shadow_position.z=original_spot.z+shadow_vector.z*5;	     //z
	shadow_vector.x=shadow_vector.y/tan(R(-quant.width_degree));	     //x 벡터
	shadow_position.x=original_spot.x+shadow_vector.x*FPM;		 //벡터 만큼 x의 위치 이동

	///////////////최고 높이점 일때의 높이 z///////////
	if(shadow_position.z-temp<=0)
		serveok=true;          //이때 부터 서브가 가능해짐
    if(Skill) //스킬 발동시
    {
       SkillPos=shadow_position;
       float tmp=shadow_vector.y/tan(R(quant.width_degree));	     //x 벡터
	   SkillPos.x=original_spot.x+tmp*FPM;

    }
	////////////////////////////////////
	///높이 z의 양수값 고정 ///////////
	//////////////////////////////////
	if(shadow_position.z<0)           //높이가 0보다 작을때.
	{

		shadow_position.z=0;		  //1으로 고정
		quant.v=quant.v*0.7;					  // 속도 감소
		original_spot=ball_position;  //식을 다시 세우기 위해 초기 위치를 땅에 닿은 (z=0)일 때로 변경
		time=0.2f;						  //시간의 초기화

		if(quant.height_degree<=10 && quant.v>0)    // 바운딩 각도를 반대로.
		{
			quant.height_degree*=-1;
		}
		else if(quant.height_degree>=10 && quant.v<0)
		{
		    quant.height_degree*=-1;
		}
	}
	ball_position.x=shadow_position.x;				//볼의 위치에 그림자의 위치를 대입
	ball_position.y=shadow_position.y;
	ball_position.z=shadow_position.z;

	//////////// ball 설정 ///////////
	ball.x=ball_position.x-r;
	ball.y=ball_position.y-r;

	ball.w=r;
	ball.h=r;

}

void CBall::draw()
{
  SDL_Surface* screen = SDL_GetVideoSurface();

  CPoint3 temp; //임시 저장 변수
  SDL_Rect ball_rect;   //그리기 위한 변수들
  SDL_Rect shadow_rect;

  temp=transCoordinate(shadow_position.x-r,shadow_position.y-r);
  shadow_rect.x=temp.x;
  shadow_rect.y=temp.y;
  shadow_rect.w=7;
  shadow_rect.h=7;
  ball_Bound=shadow_rect;
  SDL_BlitSurface(shadow, NULL, screen, &shadow_rect); //그림자 그리기

  temp=transCoordinate(ball.x,ball.y); //논리적 ->물리적 좌표 변환

  ball_rect.x=temp.x;
  ball_rect.y=temp.y-(ball_position.z);
  ball_rect.w=7;
  ball_rect.h=7;
  SDL_BlitSurface(image, NULL, screen, &ball_rect);   //볼 그리기
  if(Skill)
  {
      SkillPos=transCoordinate(SkillPos.x,SkillPos.y);
      SDL_Rect skillBall;
      skillBall.x=SkillPos.x;
      skillBall.y=SkillPos.y;
      SDL_BlitSurface(image,NULL,screen,&skillBall);
  }
}
void CBall::get_v(ball_physics fm)
{
	this->quant.v=fm.v;					    	//속도
	this->quant.width_degree=fm.width_degree;    //수평각
	this->quant.height_degree=fm.height_degree;  //수직각
	original_spot=ball_position;
	time=0.2f; //시간 초기화
}

void CBall::Ball_collision(CPlayer *user,CPlayer *com, int state )
{
	ball_physics temp;		//임시로 공의 물리량을 저장하는 변수
	if(serveok==true && ball_position.z<=150)	//공이 힘을 받아 움직이고 있을 경우
	{
		if(check_collision(ball_Bound,user->getBoundingBox()) && BallDir!=1)	//user와우 충돌 check
		{
		    if(user->Getaction()!=0 && user->Getaction()!=1)
		    {
		        if(Skill) Skill=false;
		    }
			if(user->Getaction()==5) //Right�
			{
			    if(state==0 && Service==true && BallDir==2)
			    {
			        Service=false;
			    }
				BallDir=1;
				temp=user->Hit_Ball(USERRIGHTHIT,ball_position); //user 객체로부터 공의 물리량을 받음
				get_v(temp);
				BounceReset();//바운스 초기화.
			}
			else if(user->Getaction()==6) //lefty
			{
			    if(state==0 && Service==true && BallDir==2)
			    {
			        Service=false;
			    }
				BallDir=1;
				temp=user->Hit_Ball(USERLEFTHIT,ball_position); //user 객체로부터 공의 물리량을 받음
				get_v(temp);
				BounceReset();//바운스 초기화.
			}
			else if(user->Getaction()==7) //lefty
			{
			    if(state==0 && Service==true && BallDir==2)
			    {
			        Service=false;
			    }
			    Skill=true;
				BallDir=1;
				temp=user->Hit_Ball(USERLEFTDIVEHIT,ball_position); //user 객체로부터 공의 물리량을 받음
				get_v(temp);
				BounceReset();//바운스 초기화.
			}
			else if(user->Getaction()==8) //lefty
			{
			    if(state==0 && Service==true && BallDir==2)
			    {
			        Service=false;
			    }
			    Skill=true;
				BallDir=1;
				temp=user->Hit_Ball(USERRIGHTDIVEHIT,ball_position); //user 객체로부터 공의 물리량을 받음
				get_v(temp);
				BounceReset();//바운스 초기화.
			}
			else if(user->Getaction()==9) //lefty
			{
			    if(state==0 && Service==true && BallDir==2)
			    {
			        Service=false;
			    }
				BallDir=1;
				temp=user->Hit_Ball(USERSMASH,ball_position); //user 객체로부터 공의 물리량을 받음
				get_v(temp);
				BounceReset();//바운스 초기화.
			}
			else if(user->Getaction()==10 && user->GetbSwing()==false) //lefty
			{
			    if(state==0 && Service==true && BallDir==2)
			    {
			        Service=false;
			    }
				BallDir=1;
				temp=user->Hit_Ball(USERHITSERVE,ball_position); //user 객체로부터 공의 물리량을 받음
				get_v(temp);
				BounceReset();//바운스 초기화.
			}
        }
		else if(check_collision(ball_Bound,com->getBoundingBox()) && BallDir!=2)
		{
		    if(com->Getaction()!=0 && com->Getaction()!=1)
		    {
		        if(Skill) Skill=false;
		    }
			if(com->Getaction()==5) //임시로
			{
			    if(state==0 && Service==true && BallDir==1)
			    {
			        Service=false;
			    }
				BallDir=2;
				temp=com->Hit_Ball(COMRIGHTHIT,ball_position);	// COMHIT은 구분자 com을 나타내는 구분자이다.
				get_v(temp);
				BounceReset();
			}
			else if(com->Getaction()==6) //임시로
			{
			    if(state==0 && Service==true && BallDir==1)
			    {
			        Service=false;
			    }
				BallDir=2;
				temp=com->Hit_Ball(COMLEFTHIT,ball_position);	// COMHIT은 구분자 com을 나타내는 구분자이다.
				get_v(temp);
				BounceReset();
			}
			else if(com->Getaction()==7) //임시로
			{
			    if(state==0 && Service==true && BallDir==1)
			    {
			        Service=false;
			    }
			    Skill=true;
				BallDir=2;
				temp=com->Hit_Ball(COMLEFTDIVEHIT,ball_position);	// COMHIT은 구분자 com을 나타내는 구분자이다.
				get_v(temp);
				BounceReset();
			}
			else if(com->Getaction()==8) //임시로
			{
			    if(state==0 && Service==true && BallDir==1)
			    {
			        Service=false;
			    }
			    Skill=true;
				BallDir=2;
				temp=com->Hit_Ball(COMRIGHTDIVEHIT,ball_position);	// COMHIT은 구분자 com을 나타내는 구분자이다.
				get_v(temp);
				BounceReset();
			}
			else if(com->Getaction()==9) //임시로
			{
			    if(state==0 && Service==true && BallDir==1)
			    {
			        Service=false;
			    }
				BallDir=2;
				temp=com->Hit_Ball(COMSMASH,ball_position);	// COMHIT은 구분자 com을 나타내는 구분자이다.
				get_v(temp);
				BounceReset();
			}
			else if(com->Getaction()==10 && com->GetbSwing()==false) //임시로
			{
			    if(state==0 && Service==true && BallDir==1)
			    {
			        Service=false;
			    }
				BallDir=2;
				temp=com->Hit_Ball(COMHITSERVE,ball_position);	// COMHIT은 구분자 com을 나타내는 구분자이다.
				get_v(temp);
				BounceReset();
			}
		}
	}
}



