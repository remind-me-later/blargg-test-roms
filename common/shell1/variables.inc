; The RAM of the shell: the variables of the runtime, printing, testing and
; console libraries. The variables of a test go after these, in sections that
; start at wShellVariablesEnd (WRAM) and hShellVariablesEnd (HRAM).
;
; The sections are unionized: every test of a multi-test ROM is assembled
; on its own, and they all use the same RAM, as they do when they are ROMs of
; their own. The addresses are fixed, because the ROMs have to be the released
; ones.

IF !DEF(BSS_START)
	; Start of the variables in WRAM; the driver of a multi-test ROM has its own
	DEF BSS_START EQU $D800
ENDC

IF !DEF(HRAM_START)
	; Start of the variables in HRAM ($FF80-$FFFE)
	DEF HRAM_START EQU $FF80
ENDC

; The driver of a multi-test ROM keeps its variables at other addresses
IF DEF(MULTI_DRIVER)
	DEF RAM_OWNER EQUS " of the driver"
ELSE
	DEF RAM_OWNER EQUS ""
ENDC

PUSHS UNION "Shell variables{RAM_OWNER}", WRAMX[BSS_START], BANK[1]

wGbId:              db  ; DMG/CGB hardware identifier, from A at reset

wPrintCharNoCrc:    ds 3 ; RAM routine: JP to the print routine, or RET

wResult:            db  ; test code, set by set_test
wTestName:          dw  ; text of the test, set by set_test

IF !DEF(BUILD_MULTI)
	; The tests of a multi-test ROM don't use the console
wConsoleBuf:        ds CONSOLE_WIDTH
wConsolePos:        db
wConsoleMode:       db
wConsoleScroll:     db
ENDC

wShellVariablesEnd:

POPS

PUSHS UNION "Shell HRAM variables{RAM_OWNER}", HRAM[HRAM_START]

hChecksum:          ds 4 ; CRC-32 of the output, little-endian, complemented

hShellVariablesEnd:

POPS
