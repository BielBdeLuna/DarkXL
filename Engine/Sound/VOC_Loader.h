#pragma once
#include "SoundLoader.h"

class VOC_Loader : public ISoundLoader
{
public:
	VOC_Loader(void);
	virtual ~VOC_Loader(void);

	virtual bool LoadSound(const unsigned char *pFileData, int nFileLen, SoundData_t *pResult);
private:
	int GetSampleRateFromVOCRate(int vocSR);
};
