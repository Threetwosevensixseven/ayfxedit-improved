; -Sound effects player test (looped version)  v2.04  22/10/17--;
;                                                               ;
; A test program that uses the Minimal ayFX player (Improved).  ;
; Plays effects on the regular AY (second AY is removed here -  ;
; see z80player/playtest.a80 for the original 2nd AY version).  ;
; Zeus format (http://www.desdes.com/products/oldfiles)         ;
; Forked from https://shiru.untergrund.net/software.shtml       ;
;                                                               ;
; Keys Space,CS,M,N selects channels A/B/C/first free channel.  ;
; Keys 1-0,Q-P,A-L,Z-B,SS play the effects 0..35                ;
; (You can download a bank with fewer effects).                 ;
; Key J demos sustain loop: choose channel A/B/C and hold J.    ;
;                                                               ;
; --------------------------------------------------------------;

sfxBankAd               equ $a000                       ; Effects Bank Address
im2Ad                   equ $bdbd
im2Table                equ $be00
Start                   equ $6200
Stack                   equ Start-1

                        org Start

Main:
                        di
                        ld sp, Stack
                        ld a, ($5B5C)
                        ld bc, $7FFD
                        out (c), a

                        call Cls
                        ld a, 2                         ; Open upper screen channel for printing
                        call 5633
                        push af							; } Print(PrintAddr, PrintLen) macro
                        push bc							; }
                        push de							; }
                        push hl							; }
                        ld de, TextChAny				; } PrintAddr
                        ld bc, TextChAnyLen	   			; } PrintLen
                        call 8252						; }
                        pop hl							; }
                        pop de							; }
                        pop bc							; }
                        pop af							; }
                        ld a, 3
                        ld (Channel), a

                        ld hl, sfxBankAd                ; Initializing the effects player
                        call AFXInit

                        ld hl, intProc                  ; Move the interrupt handler to $bdbd
                        ld de, im2Ad
                        ld bc, intProcEnd-intProc
                        ldir

                        ld hl, im2Table                 ; Interrupt table for address $bdbd
                        ld de, im2Table+1
                        ld bc, $0100
                        ld a, h
                        ld i, a
                        ld (hl), high(im2Ad)
                        ldir
                        im 2
                        ei
mainLoop:
                        halt                            ; Basic cycle

                        ld b, 4                         ; Key polling cycle
                        ld hl, tblRowNum
keyLoop:
                        push bc

                        ld b, (hl)                      ; Check the left side of the current row
                        ld c, $fe
                        inc hl
                        in a, (c)
                        ld b, 5
                        ld c, (hl)
                        inc hl
keyRowL:
                        rra
                        call nc, playSfx
                        inc c
                        djnz keyRowL

                        ld b, (hl)                      ; Check the right side of the current row
                        ld c, $fe
                        inc hl
                        in a, (c)
                        ld b, 5
                        ld c, (hl)
                        inc hl
keyRowR:
                        rra
                        call nc, playSfx
                        dec c
                        djnz keyRowR

                        pop bc
                        djnz keyLoop

                        push bc
                        ld bc, $BFFE
                        in a, (c)                       ; Check for J
                        cpl
                        and %01000
                        ld (LastSustain), a
                        pop bc

                        jr mainLoop
pend

playSfx                 	                            ; Start the effect
                        push af
                        push bc
                        push hl

                        ld a, 39
                        cp c
                        jr z, ChA
                        dec a
                        cp c
                        jr z, ChB
                        dec a
                        cp c
                        jr z, ChC
                        dec a
                        cp c
                        jr z, ChAny
                        ld a, $1A
                        cp c
                        jp z, SustainSound

                        jp playSfx0

ChA:
                        push af							; } Print(PrintAddr, PrintLen) macro
                        push bc							; }
                        push de							; }
                        push hl							; }
                        ld de, TextA					; } PrintAddr
                        ld bc, TextALen	   				; } PrintLen
                        call 8252						; }
                        pop hl							; }
                        pop de							; }
                        pop bc							; }
                        pop af							; }						
                        xor a
                        ld (Channel), a
                        jp playSfx2
ChB:
 						push af							; } Print(PrintAddr, PrintLen) macro
                        push bc							; }
                        push de							; }
                        push hl							; }
                        ld de, TextB					; } PrintAddr
                        ld bc, TextBLen	   				; } PrintLen
                        call 8252						; }
                        pop hl							; }
                        pop de							; }
                        pop bc							; }
                        pop af							; }	
                        ld a, 1
                        ld (Channel), a
                        jp playSfx2
ChC:
 						push af							; } Print(PrintAddr, PrintLen) macro
                        push bc							; }
                        push de							; }
                        push hl							; }
                        ld de, TextC					; } PrintAddr
                        ld bc, TextCLen	   				; } PrintLen
                        call 8252						; }
                        pop hl							; }
                        pop de							; }
                        pop bc							; }
                        pop af							; }	
                        ld a, 2
                        ld (Channel), a
                        jp playSfx2
ChAny:
 						push af							; } Print(PrintAddr, PrintLen) macro
                        push bc							; }
                        push de							; }
                        push hl							; }
                        ld de, TextAny					; } PrintAddr
                        ld bc, TextAnyLen	   			; } PrintLen
                        call 8252						; }
                        pop hl							; }
                        pop de							; }
                        pop bc							; }
                        pop af							; }	
                        ld a, 3
                        ld (Channel), a
                        jp playSfx2
SustainSound:
                        ld a, (Channel)
                        cp 3
                        jp nc, playSfx0                 ; If not locked to a channel do a normal Play
                        ld a, (LastSustain)
                        or a
                        jp z, PlaySustain               ; If not already playing do a normal Play
                        ld a, (Channel)
                        ld e, a                         ;  e = channel no (0=A, 1=B, 2=C)
                        ld bc, sfxBankAd+$08F5          ; bc = Loop start/sustain address (time frame $0810)
                        call AFXSustain
                        jp playSfx2
PlaySustain:
                        ld a, (sfxBankAd)               ; Check for effect in the bank
                        dec a
                        cp c
                        jr c, playSfx2                  ; Jump if the bank doesn't have this many effects
                        ld a, (Channel)
                        cp 3
                        ld e, a                         ; e = channel no (0=A, 1=B, 2=C)
                        ld a, c                         ; a = effect no
                        ld bc, sfxBankAd+$0904          ; bc = Loop end/release address (time frame $0815)
                        call AFXPlayLooped
                        jp playSfx1
playSfx0:
                        ld a, (sfxBankAd)               ; Check for effect in the bank
                        dec a
                        cp c
                        jr c, playSfx2                  ; Jump if the bank doesn't have this many effects

                        ld a, (Channel)
                        cp 3
                        ld e, a                         ; Channel is in e
                        ld a, c                         ; Actually launch the effect
                        jp nz, PlayChannel
                        call AFXPlay
playSfx1:
                        halt                            ; Delay after pressing a key
                        halt
                        halt
                        halt
playSfx2:
                        pop hl
                        pop bc
                        pop af
                        ret
PlayChannel:
                        call AFXPlayChannel
                        jp playSfx1

aySelChip:						                        ; Procedure for selecting the chosen AY
                        ld bc, $fffd
                        xor b
                        out (c), a
                        ret

include                 "ayfxplay.asm"                  ; Include the source of the effects player

; A table for polling the keyboard
; First byte  - high byte of the port address
; Second byte - the starting number of the effect

tblRowNum:
                        DB $f7, $00, $ef, $09, $fb, $0a, $df, $13
                        DB $fd, $14, $bf, $1d, $fe, $1e, $7f, $27

CodeSize                equ $-Start


Cls:
                        ld a, $38
                        ld (23693), a
                        call 3503
                        ret

At                      equ 22

TextA:
                        db At, 0, 9, "A   "
TextALen                equ $-TextA

TextB:                 
                        db At, 0, 9, "B   "
TextBLen                equ $-TextB

TextC:
                        db At, 0, 9, "C   "
TextCLen                equ $-TextC

TextAny:
                        db At, 0, 9, "Free"
TextAnyLen              equ $-TextAny

TextChAny:
                        db At, 0, 0, "Channel: Free", 13
                        db "________________________________"
                        db 13, 13, "KEYS:", 13, 13
                        db "SPACE:  Lock to channel A", 13
                        db "SYMBOL: Lock to channel B", 13
                        db "M:      Lock to channel C", 13
                        db "N:      Any free channel", 13, 13
                        db "OTHER:  Play FX sound (0-35)"
TextChAnyLen            equ $-TextChAny

macro					Printx, PrintAddr, PrintLen
                        push af
                        push bc
                        push de
                        push hl
                        ld de, PrintAddr
                        ld bc, PrintLen
                        call 8252
                        pop hl
                        pop de
                        pop bc
                        pop af
endm

Channel:                db 3                            ; 0=A, 1=B, 2=C, 3=Any
LastSustain:            db 0

org sfxBankAd
incbin "playtest.afb"
sfxBankSize equ $-sfxBankAd

org im2Ad

intProc                 		                        ; Interrupt handler
                        push af
                        push bc
                        push de
                        push hl

enableMusic equ $+1
						ld a, 0                         ; Music on?
                        and 1
                        jr z, noMusic

                        ld a, 1                         ; Choose the second AY
                        call aySelChip
noMusic:
                        xor a                           ; Choose the first AY
                        call aySelChip
                        call AFXFrame                   ; Lose the effects

                        pop hl
                        pop de
                        pop bc
                        pop af
                        ei
                        ret
intProcEnd						

end Start

