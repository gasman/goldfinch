; CALLER linkage for function pointers

XLIB fatfs_fsopen
LIB fatfs_fsopen_asmentry

.fatfs_fsopen

   pop de
   pop hl
   pop ix
   push ix
   push hl
   push de
   
   jp fatfs_fsopen_asmentry
