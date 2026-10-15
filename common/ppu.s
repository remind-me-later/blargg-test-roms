; Waits for LCD blanking period
; Preserved: BC, DE, HL
wait_vbl:
     ; Return if off
     lda  rLCDC
     rla
     ret  nc

     ; Wait for start of vblank
.wait:
     lda  rLY
     cp   144
     jr   nz,.wait

     ret
