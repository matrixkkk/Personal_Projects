#ifndef _COMMON_H_

#define _COMMON_H_

#include <math.h>
#include <SDL/SDL.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include <time.h>
#include <stdlib.h>
#include <functional>
#include <deque>
#include <time.h>
#include <stdlib.h>
#include <winsock2.h>
#include <tchar.h>
#include <windows.h>
#include <math.h>
#include <conio.h>
#include <SDL/SDL_ttf.h>

#define LEFTLINE	18
#define RIGHTLINE	467
#define TOPLINE		133
#define BOTTOMLINE  674


#define BLOCKSIZE 150

using namespace std;

#define R(x) x*3.141592/180


//--------아이템 종류------------
#define LOWBALL		0
#define	LASER		1
#define CONTROL		2
#define HIGHBALL	3
#define HIDEBALL	4
#define SPEEDUP		5
#define SPEEDDOWN	6
#define STOPBALL	7
#define ADDBALL2	8
#define ADDBALL4	9
#define OBSTARCLE	10
#define BONE		11
#define PLUS100		12
#define PLUS200		13

class CPoint2 //3 좌표 체계 
{
public:
	float x; //x좌표
	float y; //y좌표

	CPoint2();
	CPoint2(float _x,float _y) { x=_x; y=_y; }

};


//사각형 틀
struct SRECT 
{
	int left;
	int top;
	int right;
	int bottom;

	SRECT() { }
	SRECT(int _left,int _right,int _top,int _bottom)
	{
		left = _left; right = _right; top = _top; bottom = _bottom;
	}
};	


//클라이언트에서 서버에 데이터를 넘겨줄 때 사용된 아이템의 정보
struct ITEMINFO
{
		int		itemNumber;		//아이템 번호		(기획서 수정)
		int		targetPlayer;	//목표 플레이어		(기획서 수정)
		
		ITEMINFO()
		{
			memset(this,-1,sizeof(*this));
		}
}; 

//게임 플레이 프로세스에서의 서버와 클라이언트 간의 통신을 위한 데이터 정의
struct MYDATA
{
	UINT		numOfPlayer;		//플레이어의 번호
	int			breakenBlock[10];		//파괴될 블록의 인덱스 -1은 없음 (기획서 수정요망)
	int			score;			//현재의 점수
	UINT		numOfBall;		//볼의 개수 (기획서 수정 요망)
	SDL_Rect 	barRect;		//Bar(막대)의 위치 (기획서 수정 요망)
	SDL_Rect	ballPos[5];		//볼의 위치	
	char 		chatMessage[60];	//채팅 메세지 
	struct ITEMINFO itemInfo;		//아이템 정보 구조체 –아래 설명

	MYDATA()
	{
		ZeroMemory(this,sizeof(*this));
		memset(breakenBlock,-1,sizeof(breakenBlock));
		memset(&itemInfo,-1,sizeof(itemInfo));
	}
}; 

//서버에서 묶음으로 받는 packed data
struct  PackedData
{
	bool   emptyPackageIndex[6];
	struct MYDATA packedGameData[6];	//클라이언트에서 받은 데이터 묶음

	PackedData()
	{
		ZeroMemory(emptyPackageIndex,sizeof(emptyPackageIndex));
		memset(packedGameData,-1,sizeof(packedGameData));
	}
};

struct  ClientAddr
{
	SOCKADDR_IN		Addr[6];
};

//아규먼트 구조체
struct Argument
{
	SOCKADDR_IN		serveraddr;		//서버 아이피
	char			mapIndex;		//맵의 종류
	char			numOfUser;		//참여 인원
	char			currPlayerNum; //자기 번호

	char **playIDs;     //유저들.	
};


//공통 사용 함수

void SetSDLRect(SDL_Rect &rect,int x,int y,int w,int h);	//RECT 초기화 함수
bool PointInRect(const SDL_Rect &rect,const CPoint2 &p);	//점과 바운드 박스 충돌 체크 
CPoint2 Reflect_vector(CPoint2 &N,CPoint2 &D_vector);			//반사 벡터 구하는 함수.
bool collision( SDL_Rect &A,SDL_Rect &B);					//바운딩박스 체크

//윈도우 뷰포트 변환 함수
void win_viewTransFrom(SRECT winPort,SRECT viewPort,SDL_Rect sourcePort,SDL_Rect *desPort);

#endif
