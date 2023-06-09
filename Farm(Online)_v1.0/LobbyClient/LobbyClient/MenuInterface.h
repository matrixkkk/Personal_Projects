#pragma once



// MenuInterface 폼 뷰입니다.

class MenuInterface : public CFormView
{
	DECLARE_DYNCREATE(MenuInterface)

public:

	CFont	m_Font;

protected:
	MenuInterface();           // 동적 만들기에 사용되는 protected 생성자입니다.
	virtual ~MenuInterface();

public:
	enum { IDD = IDD_MENUINTERFACE };
#ifdef _DEBUG
	virtual void AssertValid() const;
#ifndef _WIN32_WCE
	virtual void Dump(CDumpContext& dc) const;
#endif
#endif

public:
	virtual void OnInitialUpdate();

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 지원입니다.

	DECLARE_MESSAGE_MAP()
};


