; CALLER linkage for function pointers

XLIB trdos_fsopen
LIB trdos_fsopen_callee
XREF ASMDISP_TRDOS_FSOPEN_CALLEE

.memcpy

   pop de
   pop hl
   pop ix
   push ix
   push hl
   push de
   
   jp trdos_fsopen_callee + ASMDISP_TRDOS_FSOPEN_CALLEE
