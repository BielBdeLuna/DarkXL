#include "Gob_Reader.h"
#include "System.h"
#include <string.h>
#include <stdio.h>
#include <windows.h>

char GOB_Reader::m_szRootDir[260];

void GOB_Reader::SetRootDir(const char *pszDir)
{
	strcpy(m_szRootDir, pszDir);
}

bool GOB_Reader::OpenGOB(const char *pszName)
{
	sprintf(m_szFileName, "%s\\%s", m_szRootDir, pszName);
	m_bGOB = true;
	size_t l = strlen(pszName);
	if ( (pszName[l-3] == 'l' && pszName[l-2] == 'a' && pszName[l-1] == 'b') || 
		 (pszName[l-3] == 'L' && pszName[l-2] == 'A' && pszName[l-1] == 'B') )
	{
		//this is a LAB file - very similar to a gob though.
		m_bGOB = false;
	}

	FILE *f = fopen(m_szFileName, "rb");
	if ( f )
	{
		fread(&m_Header, sizeof(GOB_Header_t), 1, f);
		if ( m_bGOB )
		{
			fseek(f, m_Header.MASTERX, SEEK_SET);
			
			fread(&m_FileList.MASTERN, sizeof(long), 1, f);
			m_FileList.pEntries = new GOB_Entry_t[m_FileList.MASTERN];
			fread(m_FileList.pEntries, sizeof(GOB_Entry_t), m_FileList.MASTERN, f);
		}
		else
		{
			int stringTableSize;
			fread(&m_FileList.MASTERN, sizeof(long), 1, f);
			fread(&stringTableSize, sizeof(long), 1, f);
			m_FileList.pEntries = new GOB_Entry_t[m_FileList.MASTERN];

			//now read string table.
			fseek(f, 16*(m_FileList.MASTERN+1), SEEK_SET);
			char *pStringTable = new char[stringTableSize+1];
			fread(pStringTable, 1, stringTableSize, f);

			//now read the entries.
			fseek(f, 16, SEEK_SET);
			for (int e=0; e<m_FileList.MASTERN; e++)
			{
				unsigned int fname_offs, start, size;
				fread(&fname_offs, sizeof(unsigned int), 1, f);
				fread(&start, sizeof(unsigned int), 1, f);
				fread(&size, sizeof(unsigned int), 1, f);

				m_FileList.pEntries[e].IX = start;
				m_FileList.pEntries[e].LEN = size;
				strcpy(m_FileList.pEntries[e].NAME, &pStringTable[fname_offs]);
			}

			delete [] pStringTable;
			pStringTable = NULL;
		}

		fclose(f);

		return true;
	}
	Log(LogError, "Failed to load %s", m_szFileName);

	return false;
}

void GOB_Reader::CloseGOB()
{
	CloseFile();
	if ( m_FileList.pEntries )
	{
		delete [] m_FileList.pEntries;
		m_FileList.pEntries = NULL;
	}
}

bool GOB_Reader::OpenFile(const char *pszFile)
{
	m_pFile = fopen(m_szFileName, "rb");
	m_CurFile = -1;
    
	if ( m_pFile )
	{
		//search for this file.
		for (int i=0; i<m_FileList.MASTERN; i++)
		{
			if ( stricmp(pszFile, m_FileList.pEntries[i].NAME) == 0 )
			{
				m_CurFile = i;
				break;
			}
		}

		if ( m_CurFile == -1 )
		{
			Log(LogError, "Failed to load %s from \"%s\"", pszFile, m_szFileName);
		}
	}

	return m_CurFile > -1 ? true : false;
}

void GOB_Reader::CloseFile()
{
	if ( m_pFile )
	{
		fclose(m_pFile);
		m_pFile = NULL;
	}
	m_CurFile = -1;
}

long GOB_Reader::GetFileLen()
{
	return m_FileList.pEntries[ m_CurFile ].LEN;
}

bool GOB_Reader::ReadFile(void *pData)
{
	if ( !m_pFile ) { return false; }

	fseek(m_pFile, m_FileList.pEntries[ m_CurFile ].IX, SEEK_SET);
	fread(pData, m_FileList.pEntries[ m_CurFile ].LEN, 1, m_pFile);

	if ( System::GetLogLevel() == System::LOG_VERBOSE )
	{
		Log(LogVerbose, "ReadFile: %s, %d bytes.", m_FileList.pEntries[m_CurFile].NAME, m_FileList.pEntries[m_CurFile].LEN);
	}

	return true;
}

int GOB_Reader::GetFileCount()
{
	return m_FileList.MASTERN;
}

const char *GOB_Reader::GetFileName(int nFileIdx)
{
	return m_FileList.pEntries[nFileIdx].NAME;
}
