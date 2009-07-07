; CALLER linkage for function pointers

XLIB trdos_opendir
LIB trdos_opendir_callee
XREF ASMDISP_TRDOS_OPENDIR_CALLEE

.trdos_opendir

   pop hl
   pop ix
   pop iy
   push iy
   push ix
   push hl
   
   jp trdos_opendir_callee + ASMDISP_TRDOS_OPENDIR_CALLEE
