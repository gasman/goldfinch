; CALLER linkage for function pointers
; extern void __LIB__ fatfs_dir_root(FATFS_FILESYSTEM *fs, FATFS_DIRECTORY *dir);

XLIB fatfs_dir_root
LIB fatfs_dir_root_callee
XREF fatfs_dir_root_asmentry

.fatfs_dir_root

   pop hl
   pop iy
   pop ix
   push ix
   push iy
   push hl
   
   jp fatfs_dir_root_asmentry + (fatfs_dir_root_callee-fatfs_dir_root_callee)
