; Tests interrupt handling time for slow and fast
; CPU. First value is CPU speed (0=slow, 1=fast),
; second is number of cycles taken by interrupt.
; Should take 13 cycles at either speed.
DEF REQUIRE_CGB EQU 1
DEF TEST_NAME EQUS "interrupt time"

INCLUDE "shell.inc"
INCLUDE "cpu_speed.s"
INCLUDE "timer.s"
INCLUDE "apu.s"

; $58: JP $DEC3
; $DEC3: RET
PUSHS UNION "Serial interrupt handler", WRAMX[$DEC3], BANK[1]
wSerialHandler: db
POPS

Main:
	call InitTimer

	ld d, 0
	call TestInterrupt
	ld d, 8
	call TestInterrupt
	call CPUFast
	ld d, 0
	call TestInterrupt
	ld d, 8
	call TestInterrupt

	; The released ROM expects this checksum; the source said $C86CC74D.
	check_crc $B511F33D
	jp TestsPassed

TestInterrupt:
	call GetCPUSpeed
	call PrintA
	call PrintD

	ld a, $C9 ; RET
	ld [wSerialHandler], a

	wreg rIE, $08
	wreg rIF, $00
	call StartTimer
	ei
	ld a, d
	ld [rIF], a ; $00 = 0 clocks, $08 = 13 clocks
	di
	call StopTimer
	sub 3+4 ; instruction overhead
	call PrintA
	call PrintNewline

	ret

; RST handler that matches the one in my devcart
PUSHS
SECTION "vector 1", ROM0[$58]
	jp $DEC3
POPS

INCLUDE "shell_end.inc"
