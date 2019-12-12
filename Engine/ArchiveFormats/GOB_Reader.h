#pragma once

#include <stdio.h>

typedef long GOB_Handle;

class GOB_Reader
{
public:
	bool OpenGOB(const char *pszName);
	void CloseGOB();
	static void SetRootDir(const char *pszDir);

	bool OpenFile(const char *pszFile);
	void CloseFile();
	long GetFileLen();
	bool ReadFile(void *pData);

	int GetFileCount();
	const char *GetFileName(int nFileIdx);

private:

#pragma pack(push)
#pragma pack(1)

	typedef struct
	{
		char GOB_MAGIC[4];
		long MASTERX;	//offset to GOX_Index_t
	} GOB_Header_t;

	typedef struct
	{
		long IX;		//offset to the start of the file.
		long LEN;		//length of the file.
		char NAME[13];	//file name.
	} GOB_Entry_t;

	typedef struct
	{
		long MASTERN;	//num files
		GOB_Entry_t *pEntries;
	} GOB_Index_t;

#pragma pack(pop)

	GOB_Header_t m_Header;
	GOB_Index_t m_FileList;
	long m_CurFile;
	bool m_bGOB;

	FILE *m_pFile;
	char m_szFileName[64];
	static char m_szRootDir[260];
};
