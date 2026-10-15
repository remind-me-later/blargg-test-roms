set_test_:
     pop  hl
     push hl
     push af
     inc  hl
     inc  hl
     ld   a,[hli]
     ld   [wTestCode],a
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
     ld   a,[wTestCode]
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
     ld   a,[wTestCode]
     cp   $FF       ; if a = $FF then a = 1
     jr   nz,.exit
     ld   a,1
.exit:
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

checksum_mem_:
.loop:
     ld   a,[hli]
     call update_crc
     dec  bc
     ld   a,b
     or   c
     jr   nz,.loop
     ret
