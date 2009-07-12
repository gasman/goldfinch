; CALLER linkage for function pointers
; extern FATFS_DIR_ENTRY __LIB__ *fatfs_dir_entrydetails(FATFS_DIRECTORY *dir, FATFS_FILESYSTEM *fs)

XLIB fatfs_dir_entrydetails
LIB fatfs_dir_entrydetails_callee
XREF fatfs_dir_entrydetails_asmentry

.fatfs_dir_entrydetails

   pop hl
   pop ix
   pop iy
   push iy
   push ix
   push hl
   
   jp fatfs_dir_entrydetails_asmentry + (fatfs_dir_entrydetails_callee-fatfs_dir_entrydetails_callee)
