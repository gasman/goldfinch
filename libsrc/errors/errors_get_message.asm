; Enter with error code in A; return with HL = pointer to null-terminated error message string

XLIB errors_get_message

include	"errors.def"

.errors_get_message
	ld l,a
	ld h,0
	add hl,hl
	ld de,message_table
	add hl,de	; now hl points to entry in message table
	ld e,(hl)	; read address from message table
	inc hl
	ld d,(hl)
	ex de,hl
	ret
	
.message_table
	defw msg_err_ide_read_failure
	defw msg_err_ide_read_bounce
	defw msg_err_unrecognised_boot_record
	defw msg_err_no_usable_partitions

.msg_err_ide_read_failure
	defm "IDE read failure", 0
.msg_err_ide_read_bounce
	defm "Too many bounces on IDE read", 0
.msg_err_unrecognised_boot_record
	defm "Unrecognised boot record", 0
.msg_err_no_usable_partitions
	defm "No usable partitions found", 0
