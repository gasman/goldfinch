; CALLER linkage for function pointers

XLIB trdos_open_dirent
LIB trdos_open_dirent_callee
XREF ASMDISP_TRDOS_OPEN_DIRENT_CALLEE

.trdos_open_dirent

   pop hl
   pop ix
   pop iy
   pop de
   push de
   push iy
   push ix
   push hl
   
   jp trdos_open_dirent_callee + ASMDISP_TRDOS_OPEN_DIRENT_CALLEE
