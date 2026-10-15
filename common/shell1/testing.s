; Diagnostic and testing utilities


; Sets test code and optional error text
; Preserved: AF, BC, DE, HL
MACRO set_test ; code[,text[,text2]]
     push hl
     call SetTest_
     jr   .setTest\@
     db \1
     IF _NARG > 1
          db \2
     ENDC
     IF _NARG > 2
          db \3
     ENDC
     db 0
.setTest\@:
     pop  hl
ENDM

SetTest_:
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
InitTesting:
     set_test $FF
     call InitCRC
     ret


; Reports "Passed", then exits with code 0
TestsPassed:
     call PrintNewline
     print_str "Passed"
     ld   a,0
     jp   Exit


; Reports "Done" if set_test has never been used,
; "Passed" if set_test 0 was last used, or
; failure if set_test n was last used.
TestsDone:
     ld   a,[wResult]
     inc  a
     jr   z,.done
     dec  a
     jr   z,TestsPassed
     jr   TestFailed
.done:
     print_str "Done"
     ld   a,0
     jp   Exit


; Reports current error text and exits with result code
TestFailed:
     ld   a,[wTestName]
     ld   l,a
     ld   a,[wTestName+1]
     ld   h,a
     ld   a,[hl]
     or   a
     jr   z,.noText
     call PrintNewline
     call PrintStrHL
     call PrintNewline
.noText:
     ld   a,[wResult]
     cp   1         ; if a = 0 then a = 1
     adc  0
     jp   Exit


; Prints checksum as 8-character hex value
; Preserved: AF, BC, DE, HL
PrintCRC:
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

     call PrintHex
     pop  af
     call PrintHex
     pop  af
     call PrintHex
     pop  af
     call PrintA

     pop  af
     ret


; If checksum doesn't match expected, reports failed test.
; Passing 0 just prints checksum. Clears checksum afterwards.
MACRO check_crc
     IF (\1) == 0
          call ShowPrinting
          call PrintNewline
          call PrintCRC
     ELSE
          ld   bc,((\1) >>> 16) ^ $FFFF
          ld   de,((\1) & $FFFF) ^ $FFFF
          call CheckCRC_
     ENDC
ENDM

CheckCRC_:
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

     jp   ResetCRC

.failed:
     call PrintCRC
     jp   TestFailed


; Updates checksum with bytes from addr to addr+size-1
MACRO checksum_mem
     ld   hl,\1
     ld   bc,\2
     call ChecksumMem_
ENDM

ChecksumMem_:
.loop:
     ld   a,[hli]
     call UpdateCRC
     dec  bc
     ld   a,b
     or   c
     jr   nz,.loop
     ret
