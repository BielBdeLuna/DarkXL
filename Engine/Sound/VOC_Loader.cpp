#include "VOC_Loader.h"
#include "SoundSystem.h"
#include <stdlib.h>
#include <memory.h>

#pragma pack(push)
#pragma pack(1)

typedef struct
{
	unsigned char desc[20];
	unsigned short datablock_offset;
	unsigned short version;
	unsigned short id;
} VocFileHeader_t;

typedef struct
{
	unsigned char blocktype;
	unsigned char size[3];
	unsigned char sr;
	unsigned char pack;
} VocBlockHeader_t;

#pragma pack(pop)

VOC_Loader::VOC_Loader(void):ISoundLoader()
{
}

VOC_Loader::~VOC_Loader(void)
{
}

int VOC_Loader::GetSampleRateFromVOCRate(int vocSR)
{
	int sr;
	if ( vocSR == 0xa5 || vocSR == 0xa6 )
	{
		sr = 11025;
	}
	else if ( vocSR == 0xd2 || vocSR == 0xd3 )
	{
		sr = 22050;
	}
	else
	{
		sr = 1000000L / (256L - vocSR);
	}
	return sr;
}

bool VOC_Loader::LoadSound(const unsigned char *pFileData, int nFileLen, SoundData_t *pResult)
{
	VocFileHeader_t *header = (VocFileHeader_t *)pFileData;
	int idx = sizeof(VocFileHeader_t);

	int begin_loop, end_loop, loops;

	pResult->format = AL_FORMAT_MONO8;
	pResult->size = 0;
	pResult->pData = 0;

	int code, len;
	while ( idx < nFileLen )
	{
		code = pFileData[idx]; idx++;
		len  = pFileData[idx]; idx++;
		len |= pFileData[idx] << 8;  idx++;
		len |= pFileData[idx] << 16; idx++;

		switch (code)
		{
			case 1:
			case 9:
			{
				int packing;
				if ( code == 1 )
				{
					int time_constant = pFileData[idx]; idx++;
					packing = pFileData[idx]; idx++;
					len -= 2;
					pResult->freq = GetSampleRateFromVOCRate(time_constant);
				}
				else
				{
					pResult->freq = *((unsigned int *)&pFileData[idx]); idx+=4;
					int bits = pFileData[idx]; idx++;
					int channels = pFileData[idx]; idx++;
					if ( bits != 8 || channels != 1 )
					{
						//unsupported...
						break;
					}
					packing = *((unsigned short *)&pFileData[idx]); idx+=2;
					idx+=4;
					len -= 12;
				}
				if (packing == 0)
				{
					if ( pResult->size )
					{
						pResult->pData = realloc(pResult->pData, pResult->size + len);
					}
					else
					{
						pResult->pData = malloc(len);
					}
					memcpy( &((char *)pResult->pData)[pResult->size], &pFileData[idx], len );
					pResult->size += len;
					begin_loop = pResult->size;
					end_loop = pResult->size;
				}
			}
			break;
			case 3:	//silence...
				idx+=3;
			break;
			case 6:	//begin loop
				loops = *((unsigned short *)&pFileData[idx]); idx+=2;
			break;
			case 7: //end of loop

			break;
			default:
				return true;
			break;
		};
	};

	return true;
}