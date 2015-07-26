#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>
#include <ctr/FS.h>

#include "decomp.h"
#include "imports.h"

#define LINEAR_BUFFER ((u8*)0x31000000)

Result gspwn(void* dst, void* src, u32 size)
{
	u32 gxCommand[]=
	{
		0x00000004, //command header (SetTextureCopy)
		(u32)src, //source address
		(u32)dst, //destination address
		size, //size
		0xFFFFFFFF, // dim in
		0xFFFFFFFF, // dim out
		0x00000008, // flags
		0x00000000, //unused
	};

	return _GSPGPU_GxTryEnqueue(sharedGspCmdBuf, gxCommand);
}

void _main()
{
	Handle fileHandle = 0x0;
	Result ret = 0x0;

	u32 compressed_size = 0x0;
	u8* compressed_buffer = LINEAR_BUFFER;

	ret = _FSUSER_OpenFileDirectly(fsHandle, &fileHandle, 0x0, 0x00000004, PATH_EMPTY, "", 1, PATH_CHAR, "/payload.bin", 13, 0x1, 0x0);
	if(ret)*(u32*)ret = 0xdead0001;

	ret = _FSUSER_ReadFile(&fileHandle, &compressed_size, 0x0, compressed_buffer, 0xA000);
	if(ret)*(u32*)ret = 0xdead0002;

	u8* decompressed_buffer = &compressed_buffer[(compressed_size + 0xfff) & ~0xfff];
	u32 decompressed_size = lzss_get_decompressed_size(compressed_buffer, compressed_size);

	ret = lzss_decompress(compressed_buffer, compressed_size, decompressed_buffer, decompressed_size);	

	ret = _GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)decompressed_buffer, decompressed_size);
	ret = gspwn((void*)(0x37a00000 + 0x00101000 - 0x00100000), decompressed_buffer, (decompressed_size + 0x1f) & ~0x1f);
	svc_sleepThread(100*1000*1000);

	{
		void (*payload)(u32* paramlk) = (void*)0x00101000;
		u32* paramblk = (u32*)LINEAR_BUFFER;

		paramblk[0x1c >> 2] = IRON_GSPGPU_GXCMD4;
		paramblk[0x20 >> 2] = IRON_GSPGPU_FLUSHDATACACHE_WRAPPER;
		paramblk[0x48 >> 2] = 0x8d; // flags
		paramblk[0x58 >> 2] = IRON_GSPGPU_HANDLE;
		paramblk[0x64 >> 2] = 0x08010000;

		payload(paramblk);	
	}

	*(u32*)ret = 0xdead0008;
}
