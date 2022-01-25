; -Minimal ayFX player (Improved)  v2.05  25/01/21--------------;
; https://github.com/Threetwosevensixseven/ayfxedit-improved    ;
; Zeus format (http://www.desdes.com/products/oldfiles)         ;
;                                                               ;
; Forked from  v0.15  06/05/06                                  ;
; https://shiru.untergrund.net/software.shtml                   ;
;                                                               ;
; The simplest effects player. Plays effects on one AY,         ;
; without music in the background.                              ;
; Priority of the choice of channels: if there are free         ;
; channels, one of them is selected if free.                    ;
; If there are are no free channels, the longest-sounding       ;
; one is selected.                                              ;
; Procedure plays registers AF, BC, DE, HL, IX.                 ;
;                                                               ;
; Initialization:                                               ;
;   ld hl, the address of the effects bank                      ;
;   call AFXInit                                                ;
;                                                               ;
; Start the effect:                                             ;
;   ld a, the number of the effect (0..255)                     ;
;   call AFXPlay                                                ;
;                                                               ;
; In the interrupt handler:                                     ;
;   call AFXFrame                                               ;
;                                                               ;
; Start the effect on a specified channel:                      ;
;   ld a, the number of the effect (0..255)                     ;
;   ld e, the number of the channel (A=0, B=1, C=2)             ;
;   call AFXPlayChannel                                         ;
;                                                               ;
; Start the effect with sustain loop enabled:                   ;
;   ld a, the number of the effect (0..255)                     ;
;   ld e, the number of the channel (A=0, B=1, C=2)             ;
;   ld bc, the bank address + the release address offset        ;
;   call AFXPlayChannel                                         ;
;                                                               ;
; Notify AFX.Frame that the should be should be looped back to  ;
; the sustain point once the release point has been reached:    ;
;   ld a, the number of the effect (0..255)                     ;
;   ld e, the number of the channel (A=0, B=1, C=2)             ;
;   ld bc, the bank address + the sustain address offset        ;
;   call AFXSustain                                             ;
;                                                               ;
; Change log:
;   v2.05  25/01/21  Bug fix: AFXInit was overwriting itself    ;
;                    the first time it was called, so it        ;
;                    couldn't ever be called a second time.     ;       												;
;   v2.04  22/10/17  Bug fix: EffectTime was not fully          ;
;                    initialised.                               ;
;   v2.03  22/10/17  Bug fix: disabled loop markers should have ;
;                    MSB $00, as $FF could be a valid address.  ;
;                    Backported Zeus player to Pasmo format.    ;
;   v2.02  21/10/17  Added the ability to loop a sound while    ;
;                    receiving sustain messages.                ;
;   v2.01  21/10/17  Added the ability to play a sound on a     ;
;                    specific channel.                          ;
;   v2.00  27/08/17  Converted Z80 player to Zeus format.       ;
; --------------------------------------------------------------;

; Channel descriptors, 4 bytes per channel:
; +0 (2) current address (channel is free if high byte=$00)
; +2 (2) sound effect time
; +2 (2) start address of sustain loop (disabled if high byte=$00)
; +2 (2) end address of sustain loop (disabled if high byte=$00)
afxChDescCount  equ 3
afxChDesc       DS afxChDescCount*8
AFXSMC    	    equ 0

; --------------------------------------------------------------;
; Initialize the effects player.                                ;
; Turns off all channels, sets variables.                       ;
;                                                               ;
; Input: HL = bank address with effects                         ;
; --------------------------------------------------------------;

AFXInit:
                        inc hl
                        ld (afxBnkAdr1+1), hl           ; Save the address of the table of offsets
                        ld (afxBnkAdr2+1), hl           ; Save the address of the table of offsets
                        ld hl, afxChDesc                ; Mark all channels as empty
                        ld de, $00ff
                        ld bc, afxChDescCount*256+$fd
afxInit0:
                        ld (hl), d
                        inc hl
                        ld (hl), d
                        inc hl
                        ld (hl), e
                        inc hl
                        ld (hl), e
                        inc hl
                        ld (hl), d
                        inc hl
                        ld (hl), d
                        inc hl
                        ld (hl), d
                        inc hl
                        ld (hl), d
                        inc hl
                        djnz afxInit0

                        ld hl, $ffbf                    ; Initialize  AY
                        ld e, $15
afxInit1:
                        dec e
                        ld b, h
                        out (c), e
                        ld b,l
                        out (c), d
                        jr nz, afxInit1

                        ld (afxNseMix+1), de            ; Reset the player variables

                        ret



; --------------------------------------------------------------;
; Play the current frame.                                       ;
;                                                               ;
; No parameters.                                                ;
; --------------------------------------------------------------;
AFXFrame:
                        ld bc, $03fd
                        ld ix, afxChDesc
afxFrame0:
                        push bc

                        ld a,11
                        ld h,(ix+1)                     ; Compare high-order byte of address to <11
                        cp h
                        jr nc, afxFrame7                ; The channel does not play, we skip
                        ld l, (ix+0)
                        ld e, (hl)                      ; We take the value of the information byte
                        inc hl

                        sub b                           ; Select the volume register:
                        ld d, b                         ; (11-3=8, 11-2=9, 11-1=10)

                        ld b, $ff                       ; Output the volume value
                        out (c), a
                        ld b, $bf
                        ld a, e
                        and $0f
                        out (c), a

                        bit 5, e                        ; Will the tone change?
                        jr z, afxFrame1                 ; Tone does not change

                        ld a, 3                         ; Select the tone registers:
                        sub d                           ; 3-3=0, 3-2=1, 3-1=2
                        add a, a                        ; 0*2=0, 1*2=2, 2*2=4

                        ld b, $ff                       ; Output the tone values
                        out (c), a
                        ld b, $bf
                        ld d, (hl)
                        inc hl
                        out (c), d
                        ld b, $ff
                        inc a
                        out (c), a
                        ld b, $bf
                        ld d, (hl)
                        inc hl
                        out (c), d

afxFrame1:
                        bit 6, e                        ; Will the noise change?
                        jr z, afxFrame3                 ; Noise does not change

                        ld a, (hl)                      ; Read the meaning of noise
                        sub $20
                        jr c, afxFrame2                 ; Less than $20, play on
                        ld h, a                         ; Otherwise the end of the effect
                        ld c,$ff
                        ld b, c                         ; In BC we record the most time
                        jr afxFrame6

afxFrame2:
                        inc hl
                        ld (afxNseMix+1), a             ; Keep the noise value

afxFrame3:
                        pop bc                          ; Restore the value of the cycle in B
                        push bc
                        inc b                           ; Number of shifts for flags TN

                        ld a, %01101111                 ; Mask for flags TN
afxFrame4:
                        rrc e                           ; Shift flags and mask
                        rrca
                        djnz afxFrame4
                        ld d, a

                        ld bc, afxNseMix+2              ; Store the values of the flags
                        ld a, (bc)
                        xor e
                        and d
                        xor e                           ; E is masked with D
                        ld (bc), a

afxFrame5:
                        ld c, (ix+2)                    ; Increase the time counter
                        ld b, (ix+3)
                        inc bc

afxFrame6:
                        ld (ix+2), c
                        ld (ix+3), b

                        ld (ix+0), l                    ; Save the changed address
                        ld (ix+1), h

                        call CheckRelease
afxFrame7:
                        ld bc, 8                        ; Go to the next channel
                        add ix, bc
                        pop bc
                        djnz afxFrame0

                        ld hl, $ffbf                    ; Output the value of noise and mixer
afxNseMix:
                        ld de, 0                        ; +1(E)=noise, +2(D)=mixer
                        ld a, 6
                        ld b, h
                        out (c), a
                        ld b, l
                        out (c), e
                        inc a
                        ld b, h
                        out (c), a
                        ld b, l
                        out (c), d
                        ret
CheckRelease:
                        ld a, (ix+6)                    ; get release LSB
                        cp l
                        ret nz                          ; Carry on if no MLB match
                        ld a, (ix+7)                    ; get release MSB
                        or a
                        ret z                           ; Carry on if release disabled
                        cp h
                        ret nz                          ; Carry on if no MSB match
                        push bc
                        ld a, (ix+4)
                        or a
                        jp z, NoLoop
                        ld a, (ix+5)                    ; Set CurrentAddrCh[N] back
                        ld (ix+1), a                    ; to  SustainAddrCh[N] LSB
                        ld a, (ix+4)                    ;
                        ld (ix+0), a                    ; and                  MSB
                        xor a
                        ld (ix+4), a                    ; then toggle off the sustain
                        ld (ix+5), a                    ; to require it to be resent
NoLoop:
                        pop bc
                        ret

; --------------------------------------------------------------;
; Launch the effect on a specific channel. Any sound currently  ;
; playing on that channel is terminated next frame.             ;
;                                                               ;
; Input: A = Effect number 0..255                               ;
;        E = Channel (A=0, B=1, C=2)                            ;
; --------------------------------------------------------------;
AFXPlayChannel:
                        ld bc, $0000

; --------------------------------------------------------------;
; Launch the effect on a specific channel. Any sound currently  ;
; playing on that channel is terminated next frame.             ;
; During playback, when reaching ReleaseAddrCh[N], if an        ;
; AFXSustain call has been received since this AFXPlayLooped    ;
; returned, the playback time frame will loop back to           ;
; SustainAddrCh[N].                                             ;
;                                                               ;
; Input: A = Effect number 0..255                               ;
;        E = Channel (A=0, B=1, C=2)                            ;
;       BC = ReleaseAddrCh[N]                                   ;
; --------------------------------------------------------------;
AFXPlayLooped:
                        push af
                        ld a, c
                        ld (ReleaseLoSMC), a            ; SMC>
                        ld a, b
                        ld (ReleaseHiSMC), a            ; SMC>
                        ld a, e
                        add a, a
                        add a, a
                        add a, a
                        ld e, a
                        ld d, 0
                        ld ix, afxChDesc
                        add ix, de
                        ld e, 3
                        add ix, de
                        pop af
                        ld de, 0                        ; In DE the longest time in search
                        ld h, e
                        ld l, a
                        add hl, hl
afxBnkAdr2:
                        ld bc, 0                        ; Address of the effect offsets table
                        add hl, bc
                        ld c, (hl)
                        inc hl
                        ld b, (hl)
                        add hl, bc                      ; The effect address is obtained in hl
                        push hl                         ; Save the effect address on the stack
                        jp DoPlay

; --------------------------------------------------------------;
; Launch the effect on a free channel. If no free channels,     ;
; the longest sounding is selected.                             ;
;                                                               ;
; Input: A = Effect number 0..255                               ;
; --------------------------------------------------------------;
AFXPlay:
                        push af
                        ld a, c
                        ld (ReleaseLoSMC), a            ; SMC>
                        ld a, b
                        ld (ReleaseHiSMC), a            ; SMC>
                        pop af
                        ld de, 0                        ; In DE the longest time in search
                        ld h, e
                        ld l, a
                        add hl, hl
afxBnkAdr1:
                        ld bc, 0                        ; Address of the effect offsets table
                        add hl, bc
                        ld c, (hl)
                        inc hl
                        ld b, (hl)
                        add hl, bc                      ; The effect address is obtained in hl
                        push hl                         ; Save the effect address on the stack
                        ld hl, afxChDesc                ; Empty channel search
                        ld b, 3
afxPlay0:
                        inc hl
                        inc hl
                        ld a, (hl)                      ; Compare the channel time with the largest
                        inc hl
                        cp e
                        jr c, afxPlay1
                        ld c, a
                        ld a, (hl)
                        cp d
                        jr c, afxPlay1
                        ld e, c                         ; Remember the longest time
                        ld d, a
                        push hl                         ; Remember the channel address+3 in IX
                        pop ix
afxPlay1:
                        ld a, 5
                        add a, l						; Add(hl, a) }
                        ld l, a							;			 }
                        adc a, h						;			 }
                        sub l							;			 }
                        ld h, a							;			 }			
                        djnz afxPlay0
DoPlay:
                        pop de                          ; Take the effect address from the stack
                        ld (ix-3), e                    ; Put in the channel descriptor
                        ld (ix-2), d
                        ld (ix-1), b                    ; Zero the playing time
                        ld (ix-0), b 
ReleaseLoSMC equ $+3  
						ld (ix+3), AFXSMC               ; <SMC Release LSB
ReleaseHiSMC equ $+3
						ld (ix+4), AFXSMC               ; <SMC Release MSB
                        xor a
                        ld (ix+1), a                    ; Reset sustain LSB
                        ld (ix+2), a                    ; Reset sustain MSB
                        ret

; --------------------------------------------------------------;
; Notify AFX.Frame that the sound in channel E should be looped ;
; back to SustainAddrCh[N] once ReleaseAddrCh[N] has been       ;
; reached,provided playback was started with AFX.PlayLooped     ;
;                                                               ;
; Input: E = Channel (A=0, B=1, C=2)                            ;
;       BC = SustainAddrCh[N]                                   ;
; --------------------------------------------------------------;
AFXSustain:
                        ld a, e
                        add a, a
                        add a, a
                        add a, a
                        ld e, 4
                        add a, e
                        ld hl, afxChDesc
                        add a, l						; Add(hl, a) }
                        ld l, a							;			 }
                        adc a, h						;			 }
                        sub l							;			 }
                        ld h, a							;			 }	
                        ld (hl), c
                        inc hl
                        ld (hl), b
                        ret
