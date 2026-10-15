; Diagnostic and testing utilities


; Sets test code and optional error text
; Preserved: AF, BC, DE, HL
MACRO set_test ; code[,text[,text2]]
     push hl
     call set_test_
     jr   .set_test\@
     db \1
     IF _NARG > 1
          db \2
     ENDC
     IF _NARG > 2
          db \3
     ENDC
     db 0
.set_test\@:
     pop  hl
ENDM

set_test_:
     pop  hl
     push hl
     push af
     inc  hl
     inc  hl
     ld   a,[hli]
     ld   [wResult],a
     ld   a,l
     ld   [wTestName],a
     ld   a,h
     ld   [wTestName+1],a
     pop  af
     ret


; Initializes testing module
init_testing:
     set_test $FF
     call init_crc
     ret


; Reports "Passed", then exits with code 0
tests_passed:
     call print_newline
     print_str "Passed"
     ld   a,0
     jp   exit


; Reports "Done" if set_test has never been used,
; "Passed" if set_test 0 was last used, or
; failure if set_test n was last used.
tests_done:
     ld   a,[wResult]
     inc  a
     jr   z,.done
     dec  a
     jr   z,tests_passed
     jr   test_failed
.done:
     print_str "Done"
     ld   a,0
     jp   exit


; Reports current error text and exits with result code
test_failed:
     ld   a,[wTestName]
     ld   l,a
     ld   a,[wTestName+1]
     ld   h,a
     ld   a,[hl]
     or   a
     jr   z,.no_text
     call print_newline
     call print_str_hl
     call print_newline
.no_text:
     ld   a,[wResult]
     cp   1         ; if a = 0 then a = 1
     adc  0
     jp   exit


; Prints checksum as 8-character hex value
; Preserved: AF, BC, DE, HL
print_crc:
     push af

     ; Must read checksum entirely before printing,
     ; since printing updates it.
     lda  hChecksum
     cpl
     push af

     lda  hChecksum+1
     cpl
     push af

     lda  hChecksum+2
     cpl
     push af

     lda  hChecksum+3
     cpl

     call print_hex
     pop  af
     call print_hex
     pop  af
     call print_hex
     pop  af
     call print_a

     pop  af
     ret


; If checksum doesn't match expected, reports failed test.
; Passing 0 just prints checksum. Clears checksum afterwards.
MACRO check_crc
     IF (\1) == 0
          call show_printing
          call print_newline
          call print_crc
     ELSE
          ld   bc,((\1) >>> 16) ^ $FFFF
          ld   de,((\1) & $FFFF) ^ $FFFF
          call check_crc_
     ENDC
ENDM

check_crc_:
     lda  hChecksum+0
     cp   e
     jr   nz,.failed

     lda  hChecksum+1
     cp   d
     jr   nz,.failed

     lda  hChecksum+2
     cp   c
     jr   nz,.failed

     lda  hChecksum+3
     cp   b
     jr   nz,.failed

     jp   reset_crc

.failed:
     call print_crc
     jp   test_failed


; Updates checksum with bytes from addr to addr+size-1
MACRO checksum_mem
     ld   hl,\1
     ld   bc,\2
     call checksum_mem_
ENDM

checksum_mem_:
.loop:
     ld   a,[hli]
     call update_crc
     dec  bc
     ld   a,b
     or   c
     jr   nz,.loop
     ret
