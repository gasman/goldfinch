; CALLER linkage for function pointers

XLIB trdos_fsopen
LIB trdos_fsopen_callee
XREF ASMDISP_TRDOS_FSOPEN_CALLEE

.trdos_fsopen

   pop de
   pop hl
   pop ix
   push ix
   push hl
   push de
   
   jp trdos_fsopen_callee + ASMDISP_TRDOS_FSOPEN_CALLEE
