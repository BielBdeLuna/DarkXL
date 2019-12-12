#pragma once

#include <al.h>
#include <alc.h>
#include <string>
#include <hash_map>
#include <vector>
#include "SoundLoader.h"
#include "Vector3.h"
#include "GOB_Reader.h"

using namespace std;
using namespace stdext;

class SoundSystem
{
public:
	static bool Init(bool bNoSound, int numBuffers);
	static void Destroy();
	static void Update();

	static int  FindNextFreeSource(bool bForce);
	static void AttachBufferToSource(int bufferIdx, int sourceIdx);
	static void SetSourceLoc(int sourceIdx, Vector3 *pvLoc);
	static void SetSourceLoc(int sourceIdx, const Vector3 *pvLoc);
	static int  PlayOneShot(const char *pszSound, Vector3 *pvLoc=NULL, float volume=1.0f);
	static int  PlayOneShotSoundSrc(int source, Vector3 *pvLoc=NULL, float volume=1.0f);
	static int  PlayLoopingSound(const char *pszSound, Vector3 *pvLoc=NULL, float volume=1.0f);
	static void SetPan(int source, float pan);
	//play a looping sound given a source index, used for cutscenes.
	static int  PlayLoopingSoundSrc(int source, Vector3 *pvLoc=NULL, float volume=1.0f);
	static void PlaySoundSource(int sourceIdx, bool bOneShot, float volume=1.0f);
	static void StopSound(int sourceIdx);
	static bool IsSoundPlaying(int soundIdx);
	static void PauseSound(int sourceIdx);
	static void UnpauseSound(int sourceIdx);
	static void UnpauseAllSounds();
	static void SetSoundVolume(int sourceIdx, float volume);

	static void RegisterSoundLoader(const char *pszLoaderExt, ISoundLoader *pLoader);
	//get sound index if loaded, else load first.
	static int GetSoundIdx(const char *pszFile);
	static int LoadSound(void *pData, int len, char *pszName);
	//returns a source, this func. pre-binds the sound buffer to a sound source. Used for cutscenes...
	static int LoadAndPrepareSound(void *pData, int len, char *pszName);
	static int FindSound(char *pszName);

	static void SetListenerLoc(Vector3 *pvLoc);
	static void SetListenerOrient(Vector3 *pvAt, const Vector3 *pvUp);
	static void SetListenerVel(Vector3 *pvVel);

	static void StopAllSounds();

	static GOB_Reader *GetSoundGob() { return m_pSoundGOB; }
private:
	static hash_map<string, ISoundLoader *> m_LoaderMap;
	static hash_map<string, int> m_SoundBufferMap;
	static vector<ISoundLoader *> m_LoaderList;
	static int m_nCurBuffer;
	static int m_uSourceFlags[32];
	static unsigned int m_uLastUsed[32];

	static GOB_Reader *m_pSoundGOB;
};
