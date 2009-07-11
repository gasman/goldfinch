; CALLER linkage for function pointers

XLIB fatfs_drive_init
LIB fatfs_drive_init_callee
XREF fatfs_drive_init_asmentry

.trdos_fsopen

   pop bc
   pop de
   pop hl
   push hl
   push de
   push bc
   
   jp fatfs_drive_init_asmentry + (fatfs_drive_init_callee-fatfs_drive_init_callee)
