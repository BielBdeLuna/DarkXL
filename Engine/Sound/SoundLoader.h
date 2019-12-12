#pragma once

class ISoundLoader
{
public:
	typedef struct
	{
		int format;
		void *pData;
		int size;
		int freq;
	} SoundData_t;
public:
	ISoundLoader(void){;}
	virtual ~ISoundLoader(void){;}

	virtual bool LoadSound(const unsigned char *pFileData, int nFileLen, SoundData_t *pResult)=0;
};
