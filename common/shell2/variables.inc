; The RAM of the shell: the variables of the runtime, printing, testing and
; console libraries. The variables of a test go after these, in sections that
; start at wShellVariablesEnd (WRAM) and hShellVariablesEnd (HRAM).
;
; The sections are unionized: every test of a multi-test ROM is assembled
; on its own, and they all use the same RAM, as they do when they are ROMs of
; their own. The addresses are fixed, because the ROMs have to be the released
; ones.

; The exit code and the text output are written to cartridge RAM, which has
; the state of the driver of a multi-test ROM from here
DEF SAVED_STATE_START EQU $BC00

PUSHS UNION "Non-volatile variables", WRAMX[NV_RAM_START], BANK[1]

wGbId:              db  ; DMG/CGB hardware identifier, from A at reset

POPS

PUSHS UNION "Shell variables", WRAMX[BSS_START], BANK[1]

wTestCode:          db  ; test code, set by set_test
wTestName:          dw  ; text of the test, set by set_test

; build_devcart and build_multi customize this
IF !DEF(CUSTOM_PRINT)
wTextOutAddr:       dw  ; where the next character of the text output goes
ENDC

wConsoleBuf:        ds CONSOLE_WIDTH
wConsolePos:        db
wConsoleMode:       db
wConsoleScroll:     db

wShellVariablesEnd:

POPS

PUSHS UNION "Shell HRAM variables", HRAM[HRAM_START]

hChecksum:          ds 4 ; CRC-32 of the output, little-endian, complemented

hShellVariablesEnd:

POPS

IF !DEF(CUSTOM_PRINT)
     PUSHS "Text output", SRAM[$A000]

sFinalResult:       db  ; exit code of the test, $80 while it runs
sSignature:         ds 3 ; $DE $B0 $61, which tells that there is text output
sTextOutput:        ds SAVED_STATE_START - $A004 ; zero-terminated string

     POPS
ENDC
