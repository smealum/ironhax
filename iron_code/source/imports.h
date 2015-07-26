#ifndef IMPORTS_H
#define IMPORTS_H

#include <ctr/types.h>

#include "../../build/constants.h"

// handles
Handle* const fsHandle = (Handle*)IRON_FS_HANDLE;
Handle* const gspHandle = (Handle*)IRON_GSPGPU_HANDLE;

// buffers
u32** const sharedGspCmdBuf = (u32**)(IRON_GSPGPU_INTERRUPT_RECEIVER_STRUCT + 0x58);

// functions
Result (* const _GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size) = (void*)IRON_GSPGPU_FLUSHDATACACHE;
Result (* const _GSPGPU_GxTryEnqueue)(u32** sharedGspCmdBuf, u32* cmdAdr) = (void*)IRON_GSPGPU_GXTRYENQUEUE;
Result (* const _FSUSER_OpenFileDirectly)(Handle* handle, Handle* fileHandle, u32 transaction, u32 archiveId, u32 archivePathType, char* archivePath, u32 archivePathLength, u32 filePathType, char* filePath, u32 filePathLength, u8 openflags, u32 attributes) = (void*)IRON_FSUSER_OPENFILEDIRECTLY;
Result (* const _FSUSER_ReadFile)(Handle* handle, u32* bytesRead, s64 offset, void *buffer, u32 size) = (void*)IRON_FSUSER_READ;

#endif
