; Reads from wave RAM while playing, each time 2
; clocks later.

;DEF REQUIRE_DMG EQU 1
;DEF REQUIRE_CGB EQU 1
DEF TEST_NAME EQUS "09-wave read while on"
INCLUDE "shell.inc"
INCLUDE "apu.s"

Main:
	wreg rAUDTERM,0    ; mute sound
	loop_n_times Test,69
	check_crc_dmg_cgb $118A3620,$270DA9A3
	jp   TestsPassed

Test:
	add  $99
	ld   b,a

	; Reload wave and have its first
	; sample read occur 2 clocks earlier
	; each loop iteration
	ld   hl,Wave
	call LoadWave
	wreg rAUD3ENA,$80  ; enable
	wreg rAUD3LEVEL,$00  ; silent
	ld   a,b
	sta  rAUD3LOW      ; period
	wreg rAUD3HIGH,$87  ; start

	; Read from wave
	wreg rAUD3LOW,-2   ; period = 4
	delay_clocks 176
	lda  rAUD3WAVE_0

	call PrintA

	ret

Wave:
	db $00, $11, $22, $33, $44, $55, $66, $77
	db $88, $99, $AA, $BB, $CC, $DD, $EE, $FF

INCLUDE "shell_end.inc"
