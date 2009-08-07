; CALLER linkage for function pointers

XLIB trdos_fsopen
LIB trdos_fsopen_asmentry

.trdos_fsopen

   pop de
   pop hl
   pop ix
   push ix
   push hl
   push de
   
   jp trdos_fsopen_asmentry
