#pragma once
#include <math.h>
#include <string>
#include <vector>
#include <hash_map>
#include "Driver3D_DX9.h"

using namespace std;
using namespace stdext;

class Map;
class Object;

class VUE
{
public:
	VUE(void);
	~VUE(void);

	bool Load(Map *pMap, char *pData, int len);
	void AttachObject(Object *pObj, const char *pszVueObj, bool bPause=false, bool bPlayOnce=false, bool b3D=true);
	void Append_VUE(VUE *pVUE_Append, Object *pObj, const char *pszVueObj, bool bPause=true);

	//return false when done.
	bool Update(float fDeltaTime, Map *pMap);
	void Unpause(int nSector);
private:
	typedef struct
	{
		char szVueObj[32];
		Object *pObject;
		int nCurFrame;
		float fCurFrameDelay;
		bool bPaused;
		bool bPlayOnce;
		bool b3D;

		VUE *pAppend;
		char szAppendVueObj[32];
		bool bAppendPause;

		vector<D3DXMATRIX *> mXforms;
	} Transforms_t;

	vector<Transforms_t *> m_ObjXforms;
private:
	void VUE_ParseLine(const char *pszLine);
};

class VUE_Mgr
{
public:
	//destroy all loaded VUEs
	static void DestroyVUEs();
	//load a VUE if it doesn't exist.
	static VUE *LoadVUE(const char *pszFileName, Map *pMap);
	//update all the VUEs
	static void Update(float fDeltaTime, Map *pMap);
	//unpause all VUE transforms, where their object is in sector nSector.
	static void UnpauseVUE(int nSector);
	//set overall FPS for VUE playback.
	static void SetFPS(int fps);
public:
	static float m_fFrameDelay;
private:
	static vector<VUE *> m_VueList;
	static hash_map<string, VUE *> m_VueMap;
};
