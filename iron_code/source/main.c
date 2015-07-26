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

	*(u32*)ret = 0xdead0008;
}
