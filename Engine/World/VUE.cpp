#include "Math.h"
#include <math.h>
#include <string.h>

#include "VUE.h"
#include "Map.h"
#include "Object.h"

extern char m_Cache[4*1024*1024];
vector<VUE *> VUE_Mgr::m_VueList;
hash_map<string, VUE *> VUE_Mgr::m_VueMap;
float VUE_Mgr::m_fFrameDelay;

/////////////////////////////////////////////////////
//	VUE
/////////////////////////////////////////////////////
VUE::VUE(void)
{
}

VUE::~VUE(void)
{
	vector<Transforms_t *>::iterator iter = m_ObjXforms.begin();
	vector<Transforms_t *>::iterator end  = m_ObjXforms.end();
	for (; iter != end; ++iter)
	{
		Transforms_t *pXform = *iter;
		vector<D3DXMATRIX *>::iterator iterMtx = pXform->mXforms.begin();
		vector<D3DXMATRIX *>::iterator endMtx  = pXform->mXforms.end();
		for (; iterMtx != endMtx; ++iterMtx)
		{
			D3DXMATRIX *pMtx = *iterMtx;
			if ( pMtx )
			{
				delete pMtx;
			}
		}
		pXform->mXforms.clear();
		delete pXform;
	}
	m_ObjXforms.clear();
}

void VUE::VUE_ParseLine(const char *pszLine)
{
	if ( _strnicmp(pszLine, "transform", 9) != 0 ) { return; }

	int l = (int)strlen(pszLine), i, idx;
	int nStart=-1, nEnd=-1;
	//1st look for quotes for the name.
	bool bStart=false;
	char szName[32];
	for (i=0, idx=0; i<l; i++)
	{
		if ( pszLine[i] == '"' )
		{
			if ( bStart == false ) { bStart = true; }
							  else { szName[idx] = 0; break; }
		}
		else if ( bStart )
		{
			szName[idx] = pszLine[i]; idx++;
		}
	}
	i++;
	//now parse all the parameters.
	int nCurParam = 0;
	char szValue[256];
	char *pszTmp;
	float afParam[12];
	while (nCurParam < 12 )
	{
		bStart = false;
		while (pszLine[i] == ' ' || pszLine[i] == '\r' || pszLine[i] == '\n') { i++; }
		nStart = i;
		while (pszLine[i] != ' ' && pszLine[i] != '\r' && pszLine[i] != '\n' && pszLine[i] != 0)
		{
			szValue[i-nStart] = pszLine[i];
			i++;
		};
		szValue[i-nStart] = 0;
		afParam[nCurParam] = (float)strtod(szValue, &pszTmp);

		nCurParam++;
	};

	//find object in VUE and add transform...
	Transforms_t *pFinalObjXform=NULL;
	vector<Transforms_t *>::iterator iObjXformIter = m_ObjXforms.begin();
	vector<Transforms_t *>::iterator iObjXformEnd  = m_ObjXforms.end();
	for (; iObjXformIter != iObjXformEnd; ++iObjXformIter)
	{
		Transforms_t *pObjXform = *iObjXformIter;

		if ( _stricmp(pObjXform->szVueObj, szName) == 0 )
		{
			pFinalObjXform = pObjXform;
			break;
		}
	}

	if ( pFinalObjXform == NULL )
	{
		pFinalObjXform = new Transforms_t;
		pFinalObjXform->bPaused = false;
		pFinalObjXform->bPlayOnce = false;
		pFinalObjXform->fCurFrameDelay = 0.0f;
		pFinalObjXform->nCurFrame = 0;
		pFinalObjXform->pObject = NULL;
		pFinalObjXform->pAppend = NULL;

		strcpy(pFinalObjXform->szVueObj, szName);

		m_ObjXforms.push_back( pFinalObjXform );
	}

	if ( pFinalObjXform )
	{
		D3DXMATRIX *pXform = new D3DXMATRIX;
		D3DXMatrixIdentity(pXform);
		
		pXform->m[0][0] =  afParam[0]; pXform->m[0][1] =  afParam[ 1]; pXform->m[0][2] =  afParam[ 2];
		pXform->m[1][0] = -afParam[3]; pXform->m[1][1] = -afParam[ 4]; pXform->m[1][2] = -afParam[ 5];
		pXform->m[2][0] = -afParam[6]; pXform->m[2][1] = -afParam[ 7]; pXform->m[2][2] = -afParam[ 8];
		pXform->m[3][0] =  afParam[9]; pXform->m[3][1] =  afParam[10]; pXform->m[3][2] =  afParam[11];

		pFinalObjXform->mXforms.push_back( pXform );
	}
}

bool VUE::Load(Map *pMap, char *pData, int len)
{
	bool bSuccess = true;

	//now parse each line...
	char *pszCur = pData;
	char szLine[256];
	int lineIdx = 0;
	int sl = (int)strlen(pszCur);
	for (int l=0; l<sl; l++)
	{
		if ( pszCur[l] == '\r' || pszCur[l] == '\n' )
		{
			szLine[lineIdx] = 0;
			if ( lineIdx > 0 )
			{
				VUE_ParseLine(szLine);
			}

			lineIdx = 0;
			szLine[lineIdx] = 0;
		}
		else
		{
			szLine[lineIdx] = pszCur[l];
			lineIdx++;
		}
	}

	return bSuccess;
}

void VUE::Append_VUE(VUE *pVUE_Append, Object *pObj, const char *pszVueObj, bool bPause/*=true*/)
{
	vector<Transforms_t *>::iterator iObjXformIter = m_ObjXforms.begin();
	vector<Transforms_t *>::iterator iObjXformEnd  = m_ObjXforms.end();
	for (; iObjXformIter != iObjXformEnd; ++iObjXformIter)
	{
		Transforms_t *pObjXform = *iObjXformIter;

		if ( pObjXform->pObject == pObj && _stricmp(pObjXform->szVueObj, pszVueObj) == 0 )
		{
			pObjXform->pAppend = pVUE_Append;
			strcpy(pObjXform->szAppendVueObj, pszVueObj);
			pObjXform->bAppendPause = bPause;
		}
	}
}

void VUE::AttachObject(Object *pObj, const char *pszVueObj, bool bPause/*=false*/, bool bPlayOnce/*=false*/, bool b3D/*=true*/)
{
	Obj3D *pObj3D = NULL;
	if ( b3D )
	{
		pObj3D = (Obj3D *)pObj;
		pObj3D->m_bUpdateOrient = false;
	}

	vector<Transforms_t *>::iterator iObjXformIter = m_ObjXforms.begin();
	vector<Transforms_t *>::iterator iObjXformEnd  = m_ObjXforms.end();
	for (; iObjXformIter != iObjXformEnd; ++iObjXformIter)
	{
		Transforms_t *pObjXform = *iObjXformIter;

		if ( _stricmp(pObjXform->szVueObj, pszVueObj) == 0 )
		{
			pObjXform->bPaused   = bPause;
			pObjXform->bPlayOnce = bPlayOnce;
			pObjXform->pObject   = pObj;
			pObjXform->fCurFrameDelay = VUE_Mgr::m_fFrameDelay;
			pObjXform->nCurFrame = 0;
			pObjXform->pAppend = NULL;
			pObjXform->b3D = b3D;

			//set the initial orientation, if this VUE isn't paused...
			if ( !bPause )
			{
				if ( pObjXform->b3D ) { pObj3D->m_worldMtx = *pObjXform->mXforms[0]; }
				pObjXform->pObject->m_vLoc.Set( pObjXform->mXforms[0]->m[3][0], pObjXform->mXforms[0]->m[3][1], pObjXform->mXforms[0]->m[3][2] );
			}

			break;
		}
	}
}

//return false when done.
bool VUE::Update(float fDeltaTime, Map *pMap)
{
	vector<Transforms_t *>::iterator iObjXformIter = m_ObjXforms.begin();
	vector<Transforms_t *>::iterator iObjXformEnd  = m_ObjXforms.end();
	for (; iObjXformIter != iObjXformEnd; ++iObjXformIter)
	{
		Transforms_t *pObjXform = *iObjXformIter;
		if ( pObjXform->pObject && (!pObjXform->bPaused) )
		{
			pObjXform->fCurFrameDelay -= fDeltaTime;
			if ( pObjXform->fCurFrameDelay <= 0.0f )
			{
				pObjXform->nCurFrame++;
				pObjXform->fCurFrameDelay += VUE_Mgr::m_fFrameDelay;
			}

			Obj3D *pObj3D = NULL;
			if (pObjXform->b3D ) { pObj3D = (Obj3D *)pObjXform->pObject; }

			Vector3 vPrevLoc;
			pObjXform->pObject->GetLoc(&vPrevLoc);

			//are we done?
			if ( pObjXform->nCurFrame >= (int)pObjXform->mXforms.size()-1 )
			{
				if ( pObjXform->mXforms.size() > 0 )
				{
					D3DXMATRIX *xform = pObjXform->mXforms[pObjXform->mXforms.size()-1];
					if ( pObjXform->b3D ) { pObj3D->m_worldMtx = *xform; }
					pObjXform->pObject->m_vLoc.Set( xform->m[3][0], xform->m[3][1], xform->m[3][2] );

					if ( pObjXform->bPlayOnce )
					{
						//do we now start the appended VUE?
						if ( pObjXform->pAppend )
						{
							pObjXform->pAppend->AttachObject( pObjXform->pObject, pObjXform->szAppendVueObj, pObjXform->bAppendPause, true, pObjXform->b3D);
						}

						pObjXform->pObject = NULL;
						return false;
					}
					else
					{
						pObjXform->nCurFrame = 0;
					}
				}
				else
				{
					pObjXform->pObject = NULL;
					pObjXform->nCurFrame = 0;
					return false;
				}
			}
			else
			{
				//interpolation...
				int fA = pObjXform->nCurFrame;
				int fB = pObjXform->nCurFrame+1;
				float s = (VUE_Mgr::m_fFrameDelay - pObjXform->fCurFrameDelay) / VUE_Mgr::m_fFrameDelay;

				Vector3 vXa, vYa, vZa, vPa, vXb, vYb, vZb, vPb;
				
				D3DXVECTOR3 scaleA, transA, scaleB, transB;
				D3DXQUATERNION quatA, quatB, quatF;
				D3DXMatrixDecompose(&scaleA, &quatA, &transA, pObjXform->mXforms[fA]);
				D3DXMatrixDecompose(&scaleB, &quatB, &transB, pObjXform->mXforms[fB]);

				D3DXQuaternionSlerp(&quatF, &quatA, &quatB, s);

				vPa.Set(transA.x, transA.y, transA.z);
				vPb.Set(transB.x, transB.y, transB.z);
	
				Vector3 vSa, vSb;
				vSa.Set(scaleA.x, scaleA.y, scaleA.z);
				vSb.Set(scaleB.x, scaleB.y, scaleB.z);
				Vector3 vP = vPa*(1.0f - s) + vPb*s;
				Vector3 vS = vSa*(1.0f - s) + vSb*s;
		
				//now build the final matrix...
				if ( pObjXform->b3D )
				{
					D3DXMATRIX scaleMtx, rotMtx;
					D3DXMatrixScaling(&scaleMtx, vS.x, vS.y, vS.z);
					D3DXMatrixRotationQuaternion(&rotMtx, &quatF);
					D3DXMatrixMultiply(&pObj3D->m_worldMtx, &rotMtx, &scaleMtx);

					pObj3D->m_worldMtx.m[3][0] = vP.x; pObj3D->m_worldMtx.m[3][1] = vP.y; pObj3D->m_worldMtx.m[3][2] = vP.z;
				}
				else
				{
					pObjXform->pObject->m_fScale = vS.x;
				}
				pObjXform->pObject->m_vLoc.Set( vP.x, vP.y, vP.z );
			}

			//need to keep track of the proper sector, uses simple collision for this.
			int nSector = pObjXform->pObject->GetSector();
			bool bCont = pMap->MoveThruSectors_NoCollide(&vPrevLoc, &pObjXform->pObject->m_vLoc, &nSector);
			int iIter = 0;
			while (bCont && iIter < 25)
			{
				bCont = pMap->MoveThruSectors_NoCollide(&vPrevLoc, &pObjXform->pObject->m_vLoc, &nSector);
				iIter++;
			};
			if ( nSector != pObjXform->pObject->m_nSector )
			{
				pMap->RemoveObject(pObjXform->pObject, pObjXform->pObject->m_nSector);
				pMap->AddObjToSector(pObjXform->pObject, nSector);

				pObjXform->pObject->SetSector( nSector );
			}
		}
	}
	return true;
}

void VUE::Unpause(int nSector)
{
	vector<Transforms_t *>::iterator iObjXformIter = m_ObjXforms.begin();
	vector<Transforms_t *>::iterator iObjXformEnd  = m_ObjXforms.end();
	for (; iObjXformIter != iObjXformEnd; ++iObjXformIter)
	{
		Transforms_t *pObjXform = *iObjXformIter;
		if ( pObjXform->pObject && pObjXform->pObject->GetSector() == nSector )
		{
			pObjXform->bPaused = false;
			pObjXform->fCurFrameDelay = VUE_Mgr::m_fFrameDelay;
			pObjXform->nCurFrame = 0;
		}
	}
}


/////////////////////////////////////////////////////
//	VUE_Mgr
/////////////////////////////////////////////////////
//destroy all loaded VUEs
void VUE_Mgr::DestroyVUEs()
{
	vector<VUE *>::iterator iter = m_VueList.begin();
	vector<VUE *>::iterator end  = m_VueList.end();

	for (; iter != end; ++iter)
	{
		VUE *pVUE = *iter;
		delete pVUE;
	}
	m_VueList.clear();
	m_VueMap.clear();
}

//load a VUE if it doesn't exist.
VUE *VUE_Mgr::LoadVUE(const char *pszFileName, Map *pMap)
{
	//Is this VUE already loaded?
	hash_map<string, VUE *>::iterator iVUE = m_VueMap.find(pszFileName);
	if ( iVUE != m_VueMap.end() )
	{
		return iVUE->second;
	}

	//If not then load it now.
	long len = 0;
	char *pData = m_Cache;
	if ( pMap->m_pOptGOB && pMap->m_pOptGOB->OpenFile(pszFileName) )
	{
		len = pMap->m_pOptGOB->GetFileLen();
		pMap->m_pOptGOB->ReadFile(pData);
		pMap->m_pOptGOB->CloseFile();
	}
	else if ( pMap->m_pDarkGOB->OpenFile(pszFileName) )
	{
		len = pMap->m_pDarkGOB->GetFileLen();
		pMap->m_pDarkGOB->ReadFile(pData);
		pMap->m_pDarkGOB->CloseFile();
	}
	else
	{
		return NULL;
	}

	//save parse settings...
	char *pCurFileData = Map::m_pFileData;
	int nCurFileSize   = Map::m_nFileSize;
	int nCurFilePtr    = Map::m_nFilePtr;
	int nCurSeqRange0  = Map::m_SeqRange[0];
	int nCurSeqRange1  = Map::m_SeqRange[1];

	//load VUE.
	Map::m_pFileData = pData;
	Map::m_nFileSize = len;
	Map::m_nFilePtr  = 0;
	Map::m_SeqRange[0] = 0;
	Map::m_SeqRange[1] = 0;

	VUE *pNewVUE = new VUE();
	m_VueList.push_back( pNewVUE );
	m_VueMap[pszFileName] = pNewVUE;

	pNewVUE->Load(pMap, pData, len);

	//restore parse settings...
	Map::m_pFileData = pCurFileData;
	Map::m_nFileSize = nCurFileSize;
	Map::m_nFilePtr  = nCurFilePtr;
	Map::m_SeqRange[0] = nCurSeqRange0;
	Map::m_SeqRange[1] = nCurSeqRange1;

	return pNewVUE;
}	

//update all the VUEs
void VUE_Mgr::Update(float fDeltaTime, Map *pMap)
{
	vector<VUE *>::iterator iter = m_VueList.begin();
	vector<VUE *>::iterator end  = m_VueList.end();

	if ( fDeltaTime > m_fFrameDelay ) { fDeltaTime = m_fFrameDelay; }

	for (; iter != end; ++iter)
	{
		(*iter)->Update(fDeltaTime, pMap);
	}
}

//unpause all VUE transforms, where their object is in sector nSector.
void VUE_Mgr::UnpauseVUE(int nSector)
{
	vector<VUE *>::iterator iter = m_VueList.begin();
	vector<VUE *>::iterator end  = m_VueList.end();

	for (; iter != end; ++iter)
	{
		(*iter)->Unpause(nSector);
	}
}

void VUE_Mgr::SetFPS(int fps)
{
	m_fFrameDelay = 1.0f / (float)fps;
}
