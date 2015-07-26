.macro set_lr,_lr
	.word ROP_IRON_POP_R1PC ; pop {r1, pc}
		.word ROP_IRON_NOP ; pop {pc}
	.word ROP_IRON_POP_R4LR_BX_R1 ; pop {r4, lr} ; bx r1
		.word 0xDEADBABE ; r4 (garbage)
		.word _lr ; lr
.endmacro

.macro sleep,nanosec_low,nanosec_high
	set_lr ROP_IRON_NOP
	.word ROP_IRON_POP_R0PC ; pop {r0, pc}
		.word nanosec_low ; r0
	.word ROP_IRON_POP_R1PC ; pop {r1, pc}
		.word nanosec_high ; r1
	.word IRON_SVC_SLEEPTHREAD
.endmacro

.macro flush_dcache,addr,size
	set_lr ROP_IRON_NOP
	.word ROP_IRON_POP_R0PC ; pop {r0, pc}
		.word IRON_GSPGPU_HANDLE ; r0 (handle ptr)
	.word ROP_IRON_POP_R1PC ; pop {r1, pc}
		.word 0xFFFF8001 ; r1 (process handle)
	.word ROP_IRON_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word addr ; r2 (addr)
		.word size ; r3 (src)
		.word 0xDEADBABE ; r4 (garbage)
		.word 0xDEADBABE ; r5 (garbage)
		.word 0xDEADBABE ; r6 (garbage)
	.word IRON_GSPGPU_FLUSHDATACACHE
.endmacro
