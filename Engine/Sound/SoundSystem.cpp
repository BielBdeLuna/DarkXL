#include "SoundSystem.h"
#include "System.h"

ALCdevice  *m_pDevice;
ALCcontext *m_pContext;
ALuint *m_pBuffers;
ALuint *m_pSources;
int m_nNumBuffers;

int SoundSystem::m_nCurBuffer;
hash_map<string, ISoundLoader *> SoundSystem::m_LoaderMap;
hash_map<string, int> SoundSystem::m_SoundBufferMap;
vector<ISoundLoader *> SoundSystem::m_LoaderList;
int SoundSystem::m_uSourceFlags[32];
unsigned int SoundSystem::m_uLastUsed[32];
unsigned int m_uCurFrame=0;
bool m_bSoundEnabled = true;

unsigned int m_uMaxSimulSounds=32;//8;

GOB_Reader *SoundSystem::m_pSoundGOB;
const Vector3 m_vZero(0.0f, 0.0f, 0.0f);

#ifndef NULL
#define NULL    0
#endif

enum
{
	SFLAGS_NONE=0,
	SFLAGS_PLAYING=(1<<0),
	SFLAGS_ONE_SHOT=(1<<1),
	SFLAGS_LOOP=(1<<2),
	SFLAGS_PAUSED=(1<<3),
};

bool SoundSystem::Init(bool bNoSound, int numBuffers)
{
	m_bSoundEnabled = !bNoSound;

	//pretend like the sound system loaded...
	if ( m_bSoundEnabled == false ) return true;

	//get the default device.
	m_nCurBuffer = 0;
	m_pDevice = alcOpenDevice("Generic Software");//DirectSound3D");
	if ( m_pDevice )
	{
		//create the context
		m_pContext = alcCreateContext(m_pDevice, NULL);
		alcMakeContextCurrent(m_pContext);

		//reset error handling
		alGetError();

		m_nNumBuffers = numBuffers;
		m_pBuffers = new ALuint[numBuffers];
		alGenBuffers(numBuffers, m_pBuffers);
		if ( alGetError() == AL_OUT_OF_MEMORY )
		{
			//free allocated memory.
			delete [] m_pBuffers;
			m_pBuffers = NULL;
			alcCloseDevice(m_pDevice);
			m_pDevice = NULL;

			//handle error here...
			return false;
		}
		alGetError();
		m_pSources = new ALuint[m_uMaxSimulSounds];
		alGenSources(m_uMaxSimulSounds, m_pSources);
		if ( alGetError() == AL_OUT_OF_MEMORY )
		{
			//free allocated memory.
			alDeleteBuffers(m_nNumBuffers, m_pBuffers);
			delete [] m_pBuffers;
			m_pBuffers = NULL;
			delete [] m_pSources;
			m_pSources = NULL;
			alcCloseDevice(m_pDevice);
			m_pDevice = NULL;

			//handle error here...
			return false;
		}
		memset(m_uSourceFlags, 0, sizeof(int)*m_uMaxSimulSounds);
		memset(m_uLastUsed, 0, sizeof(int)*m_uMaxSimulSounds);
		//set attenuation model...
		alDistanceModel(AL_INVERSE_DISTANCE_CLAMPED);

		m_pSoundGOB= new GOB_Reader();
		m_pSoundGOB->OpenGOB("SOUNDS.GOB");

		return true;
	}

	return false;
}

void SoundSystem::Destroy()
{
	if ( m_bSoundEnabled == false ) return;

	alcMakeContextCurrent( NULL );
	alcDestroyContext(m_pContext);
	if ( m_nNumBuffers )
	{
		alDeleteBuffers(m_nNumBuffers, m_pBuffers);
		m_nNumBuffers = 0;
	}
	if ( m_pBuffers )
	{
		delete [] m_pBuffers;
		m_pBuffers = NULL;
	}
	if ( m_pSources )
	{
		delete [] m_pSources;
		m_pSources = NULL;
	}
	if ( m_pDevice )
	{
		alcCloseDevice(m_pDevice);
		m_pDevice = NULL;
	}
	//if ( m_LoaderList.push_back(pLoader);
	vector<ISoundLoader *>::iterator iter = m_LoaderList.begin();
	vector<ISoundLoader *>::iterator end  = m_LoaderList.end();
	for (; iter != end; ++iter)
	{
		ISoundLoader *pLoader = *iter;
		if ( pLoader )
		{
			delete pLoader;
		}
	}
	m_LoaderList.clear();
	m_SoundBufferMap.clear();

	if ( m_pSoundGOB )
	{
		m_pSoundGOB->CloseGOB();
		delete m_pSoundGOB;
		m_pSoundGOB = NULL;
	}
}

void SoundSystem::Update()
{
	if ( m_bSoundEnabled == false ) return;

	int state;
	Log(LogVerbose, "Game Update");

	for (int s=0; s<(int)m_uMaxSimulSounds; s++)
	{
		if ( m_uSourceFlags[s]&SFLAGS_PLAYING )
		{
			alGetSourcei( m_pSources[s], AL_SOURCE_STATE, &state );
			if ( state != AL_PLAYING )
			{
				m_uSourceFlags[s] &= ~SFLAGS_PLAYING;
			}
		}
	}

	m_uCurFrame++;
}

int SoundSystem::GetSoundIdx(const char *pszFile)
{
	if ( m_bSoundEnabled == false ) return -1;

	int sound=-1;
	sound = SoundSystem::FindSound((char *)pszFile);
	if ( sound == -1 )
	{
		if ( m_pSoundGOB->OpenFile(pszFile) )
		{
			long len = m_pSoundGOB->GetFileLen();
			char *pszSnd = new char[len+1];
			m_pSoundGOB->ReadFile(pszSnd);
			m_pSoundGOB->CloseFile();

			sound = SoundSystem::LoadSound((void *)pszSnd, len, (char *)pszFile);
			if ( pszSnd ) delete pszSnd;
		}
	}
	return sound;
}

int SoundSystem::FindNextFreeSource(bool bForce)
{
	if ( m_bSoundEnabled == false ) return -1;

	//First look for an available source
	for (unsigned int s=0; s<m_uMaxSimulSounds; s++)
	{
		if ( !(m_uSourceFlags[s]&SFLAGS_PLAYING) && !(m_uSourceFlags[s]&SFLAGS_PAUSED) )
		{
			return s;
		}
	}
	//If none found then pick the oldest source.
	if ( bForce )
	{
		unsigned int oldest=0xffffffff;
		int idx=-1;
		for (unsigned int s=0; s<m_uMaxSimulSounds; s++)
		{
			if ( m_uLastUsed[s] < oldest && !(m_uSourceFlags[s]&SFLAGS_PAUSED) )
			{
				oldest = m_uLastUsed[s];
				idx = s;
			}
		}
		StopSound(idx);
		return idx;
	}
	return -1;
}

void SoundSystem::AttachBufferToSource(int bufferIdx, int sourceIdx)
{
	alSourcei( m_pSources[sourceIdx], AL_BUFFER, m_pBuffers[bufferIdx] );
	alSourcef( m_pSources[sourceIdx], AL_MAX_DISTANCE, 200.0f );
	alSourcef( m_pSources[sourceIdx], AL_REFERENCE_DISTANCE, 15.0f );
	alSourcef( m_pSources[sourceIdx], AL_ROLLOFF_FACTOR, 1.0f );
	
}

void SoundSystem::SetSourceLoc(int sourceIdx, Vector3 *pvLoc)
{
	if ( m_bSoundEnabled == false ) return;
	alSourcefv( m_pSources[sourceIdx], AL_POSITION, &pvLoc->x );
}

void SoundSystem::SetSourceLoc(int sourceIdx, const Vector3 *pvLoc)
{
	if ( m_bSoundEnabled == false ) return;
	alSourcefv( m_pSources[sourceIdx], AL_POSITION, &pvLoc->x );
}

bool SoundSystem::IsSoundPlaying(int soundIdx)
{
	if ( m_bSoundEnabled == false ) return false;
	return (m_uSourceFlags[soundIdx]&SFLAGS_PLAYING)?true:false;
}

int SoundSystem::PlayOneShot(const char *pszSound, Vector3 *pvLoc, float volume)
{
	if ( m_bSoundEnabled == false ) return -1;

	int sound  = GetSoundIdx(pszSound);
	int source = FindNextFreeSource(true);
	AttachBufferToSource(sound, source);
	if ( pvLoc )
	{
		//this is a "3D" source.
		alSourcei( m_pSources[source], AL_SOURCE_RELATIVE, AL_FALSE );
		SetSourceLoc(source, pvLoc);
	}
	else
	{
		//this is a "2D" source.
		alSourcei( m_pSources[source], AL_SOURCE_RELATIVE, AL_TRUE );
		SetSourceLoc(source, &m_vZero);
	}

	PlaySoundSource(source, true, volume);

	return source;
}

int SoundSystem::PlayLoopingSoundSrc(int source, Vector3 *pvLoc, float volume)
{
	if ( m_bSoundEnabled == false ) return -1;

	PlaySoundSource(source, false, volume);
	return source;
}

int SoundSystem::PlayOneShotSoundSrc(int source, Vector3 *pvLoc, float volume)
{
	if ( m_bSoundEnabled == false ) return -1;

	PlaySoundSource(source, true, volume);
	return source;
}

void SoundSystem::SetPan(int source, float pan)
{
	if ( m_bSoundEnabled == false ) return;

	const float _pi_over_2 = 1.5707963267948967f;
	float afOrient[6];
	afOrient[0] = sinf(pan*_pi_over_2); afOrient[1] = cosf(pan*_pi_over_2); afOrient[2] = 0.0f;
	afOrient[3] = 0.0f; afOrient[4] = 0.0f; afOrient[5] = 1.0f;
	alListenerfv(AL_ORIENTATION, afOrient);
}

int SoundSystem::PlayLoopingSound(const char *pszSound, Vector3 *pvLoc, float volume)
{
	if ( m_bSoundEnabled == false ) return -1;

	int sound  = GetSoundIdx(pszSound);
	int source = FindNextFreeSource(true);
	AttachBufferToSource(sound, source);
	if ( pvLoc )
	{
		//this is a "3D" source.
		alSourcei( m_pSources[source], AL_SOURCE_RELATIVE, AL_FALSE );
		SetSourceLoc(source, pvLoc);
	}
	else
	{
		//this is a "2D" source.
		alSourcei( m_pSources[source], AL_SOURCE_RELATIVE, AL_TRUE );
		SetSourceLoc(source, &m_vZero);
	}

	PlaySoundSource(source, false, volume);

	return source;
}

void SoundSystem::SetSoundVolume(int sourceIdx, float volume)
{
	if ( m_bSoundEnabled == false ) return;

	alSourcef( m_pSources[sourceIdx], AL_GAIN, volume );
}

void SoundSystem::PlaySoundSource(int sourceIdx, bool bOneShot, float volume)
{
	if ( m_bSoundEnabled == false ) return;

	alSourcePlay( m_pSources[sourceIdx] );
	m_uSourceFlags[sourceIdx]  = (bOneShot)?SFLAGS_ONE_SHOT : SFLAGS_LOOP;
	m_uSourceFlags[sourceIdx] |= SFLAGS_PLAYING;
	alSourcei( m_pSources[sourceIdx], AL_LOOPING, bOneShot?AL_FALSE:AL_TRUE );
	float fvol = (volume < 1.0f) ? volume : 1.0f;
	alSourcef( m_pSources[sourceIdx], AL_GAIN, fvol );
	if ( volume > 1.0f )
	{
		//adjust the hearing distance...
		alSourcef( m_pSources[sourceIdx], AL_REFERENCE_DISTANCE, 15.0f*volume );
		alSourcef( m_pSources[sourceIdx], AL_MAX_DISTANCE, 200.0f*volume );
	}
	else
	{
		alSourcef( m_pSources[sourceIdx], AL_REFERENCE_DISTANCE, 15.0f );
		alSourcef( m_pSources[sourceIdx], AL_MAX_DISTANCE, 200.0f );
	}

	m_uLastUsed[sourceIdx] = m_uCurFrame;
}

void SoundSystem::StopSound(int sourceIdx)
{
	if ( m_bSoundEnabled == false ) return;

	m_uSourceFlags[sourceIdx] &= ~SFLAGS_PLAYING;
	m_uSourceFlags[sourceIdx] &= ~SFLAGS_PAUSED;
	alSourceStop( m_pSources[sourceIdx] );
}

void SoundSystem::PauseSound(int sourceIdx)
{
	if ( m_bSoundEnabled == false ) return;

	m_uSourceFlags[sourceIdx] |= SFLAGS_PAUSED;
}

void SoundSystem::UnpauseSound(int sourceIdx)
{
	if ( m_bSoundEnabled == false ) return;

	m_uSourceFlags[sourceIdx] &= ~SFLAGS_PAUSED;
}

void SoundSystem::StopAllSounds()
{
	if ( m_bSoundEnabled == false ) return;

	unsigned int i;
	for (i=0; i<m_uMaxSimulSounds; i++)
	{
		if ( IsSoundPlaying(i) )
		{
			StopSound(i);
		}
	}
}

void SoundSystem::UnpauseAllSounds()
{
	if ( m_bSoundEnabled == false ) return;

	unsigned int i;
	for (i=0; i<m_uMaxSimulSounds; i++)
	{
		m_uSourceFlags[i] &= ~SFLAGS_PAUSED;
	}
}

void SoundSystem::RegisterSoundLoader(const char *pszLoaderExt, ISoundLoader *pLoader)
{
	if ( m_bSoundEnabled == false ) return;

	m_LoaderMap[pszLoaderExt] = pLoader;
	m_LoaderList.push_back(pLoader);
}

int SoundSystem::FindSound(char *pszName)
{
	if ( m_bSoundEnabled == false ) return -1;
	
	char szFName[64];
	strcpy(szFName, pszName);
	int l = (int)strlen(szFName);
	for ( int i=0; i<l; i++)
	{
		if ( szFName[i] >= 'A' && szFName[i] <= 'Z' )
		{
			szFName[i] -= 'A' - 'a';
		}
	}

	hash_map<string, int>::iterator iSound = m_SoundBufferMap.find(pszName);
	if ( iSound != m_SoundBufferMap.end() )
	{
		return iSound->second;
	}
	return -1;
}

int SoundSystem::LoadAndPrepareSound(void *pData, int len, char *pszName)
{
	if ( m_bSoundEnabled == false ) return -1;

	int buffer = LoadSound(pData, len, pszName);
	int source = FindNextFreeSource(true);
	PauseSound(source);
	AttachBufferToSource(buffer, source);

	//this is a "2D" source.
	alSourcei( m_pSources[source], AL_SOURCE_RELATIVE, AL_TRUE );
	SetSourceLoc(source, &m_vZero);

	return source;
}

int SoundSystem::LoadSound(void *pData, int len, char *pszName)
{
	if ( m_bSoundEnabled == false ) return -1;

	char szFName[64];
	strcpy(szFName, pszName);
	int l = (int)strlen(szFName);
	for ( int i=0; i<l; i++)
	{
		if ( szFName[i] >= 'A' && szFName[i] <= 'Z' )
		{
			szFName[i] -= 'A' - 'a';
		}
	}

	//1. Does it exist already?
	hash_map<string, int>::iterator iSound = m_SoundBufferMap.find(pszName);
	if ( iSound != m_SoundBufferMap.end() )
	{
		return iSound->second;
	}

	//2. Which loader do we use?
	int bufferIdx = -1;
	char szExt[4];
	l = (int)strlen(szFName);
	szExt[0] = szFName[l-3];
	szExt[1] = szFName[l-2];
	szExt[2] = szFName[l-1];
	szExt[3] = 0;
	hash_map<string, ISoundLoader *>::iterator iLoader = m_LoaderMap.find(szExt);
	if ( iLoader != m_LoaderMap.end() )
	{
		ISoundLoader::SoundData_t res;
		if ( iLoader->second->LoadSound((unsigned char *)pData, len, &res) )
		{
			bufferIdx = m_nCurBuffer;
			m_nCurBuffer++;

			m_SoundBufferMap[pszName] = bufferIdx;
			if ( _stricmp("QUARTER.VOC", pszName)==0 )
			{
				res.freq >>= 1;
			}
			//else if ( stricmp("REPEATER.VOC", pszName) == 0 )
			//{
			//	res.freq >>= 2;
			//}
			alBufferData( m_pBuffers[bufferIdx], res.format, res.pData, res.size, res.freq );
			free(res.pData);
		}
	}

	return bufferIdx;
}

void SoundSystem::SetListenerLoc(Vector3 *pvLoc)
{
	if ( m_bSoundEnabled == false ) return;

	alListenerfv(AL_POSITION, &pvLoc->x);
}

void SoundSystem::SetListenerOrient(Vector3 *pvAt, const Vector3 *pvUp)
{
	if ( m_bSoundEnabled == false ) return;

	float afOrient[6];
	afOrient[0] = pvAt->x; afOrient[1] = pvAt->y; afOrient[2] = pvAt->z;
	afOrient[3] = pvUp->x; afOrient[4] = pvUp->y; afOrient[5] = pvUp->z;
	alListenerfv(AL_ORIENTATION, afOrient);
}

void SoundSystem::SetListenerVel(Vector3 *pvVel)
{
	if ( m_bSoundEnabled == false ) return;

	alListenerfv(AL_VELOCITY, &pvVel->x);
}
