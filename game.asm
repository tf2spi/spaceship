.MEMORYMAP
SLOTSIZE $4000
DEFAULTSLOT 0
SLOT 0 $0000
SLOT 1 $4000
SLOT 2 $8000 SIZE $2000 "VRAM"
SLOT 3 $C000 SIZE $1000 "WRAM"
SLOT 4 $FF80 SIZE $80 "HRAM"
.ENDME

.ROMBANKMAP
BANKSTOTAL 2
BANKSIZE $4000
BANKS 2
.ENDRO

.ENUM $80
; HRAM VARIABLES HERE
DUMMY DB
.ENDE

.ENUM $C000
; WRAM VARIABLES HERE
STATICFLAGS DB
.ENDE

; Normal Calling Convention:
; HL is a non-volatile register. All other registers are volatile.
; Parameters are passed into C, B, E, D, A, then stack.
; 16-bit values must be aligned on stack or in register pair.
; Otherwise, assign 8-bit parameters in order.

; MEM* RST routines
; These are very common so it's worthwhile to make them RST routines.
; They are generally in 2 flavors. 256-byte block memsets and byte memsets.
; The count must be non-zero or, if you'd like to iterate 256 times, use 0.
; They're defined so you can perform code like the following memset.
;
; LD HL,ADDR
; XOR A
; LD BC,$1234
; RST $8 ; MEMSETLNZ
; RST $0 ; MEMSETHNZ
;
; As you can see, these have a modified calling convention where
; HL is dest, DE is src, BC is counts, and A is the value for memset

; MEMSETHNZ = RST $0
; HL = DEST
; A = DATA
; B = NONZERO # OF 256-BYTE BLOCKS 
.ORG $0
MEMSETHNZ:
LD C,0
MEMSETHNZLOOP:
RST $8
DEC B
JR NZ, MEMSETHNZLOOP
RET

; MEMSETLNZ = RST $8
; HL = DEST
; A = DATA
; C = NONZERO # OF BYTES
.ORG $8
MEMSETLNZ:
LD (HL+),A
DEC C
JR NZ, MEMSETLNZ
RET

; MEMCPYHNZ = RST $10
; HL = DEST
; DE = SRC
; C = NONZERO # OF 256-BYTE BLOCKS
.ORG $10
MEMCPYHNZ:
LD C,0
MEMCPYHNZLOOP:
RST $18
DEC B
JR NZ, MEMCPYHNZLOOP
.ORG $18

; MEMCPYLNZ = RST $10
; HL = DEST
; DE = SRC
; C = NONZERO # OF BYTES
MEMCPYLNZ:
LD A,(DE)
LD (HL+),A
INC DE
DEC C
JR NZ,MEMCPYLNZ
RET

.ORG $40
VBLANKTHUNK:
PUSH BC
PUSH DE
PUSH HL
PUSH AF
JR VBLANKINTR

.ORG $68
VBLANKINTR:
LD HL,STATICFLAGS
SET $0,(HL)
INTRPROLOG:
POP AF
POP HL
POP DE
POP BC
RETI

.ORG $100
JP START
NOP

.GBHEADER

NAME "SPACESHIP"
LICENSEECODENEW "1A"
CARTRIDGETYPE 1
RAMSIZE 0
ROMDMG
COUNTRYCODE 1
DESTINATIONCODE 1
NINTENDOLOGO
VERSION $01

.ENDGB

.ORG $150
START:
; DISABLE INTERRUPTS FOR ANY INITIAL PROCESSING
DI
; Memset WRAM to 0 and set SP
LD SP,$D000
LD HL,$C000
LD B,$f
XOR A
RST $0
; Memset HRAM to 0
LD HL,$FF80
LD C,$80
RST $8
; RE-ENABLE INTERRUPTS
EI
; Enable interrupts we want (VBLANK)
LD A,$1
LDH ($FF),A
; WAIT FOR VBLANK, TURN OFF PPU, THEN CONTROL PPU
; DISABLE PPU FOR NOW
CALL VBLANKINTRWAIT
LD A,$0
LDH ($40),A
LD HL,$8000
LD B,$20
RST $0
STARTLOOP:
LDH A,(DUMMY)
INC A
LDH (DUMMY),A
JR STARTLOOP

; WAIT FOR VBLANK TO PASS
VBLANKINTRWAIT:
LD HL,STATICFLAGS
RES $0,(HL)
VBLANKINTRWAITLOOP:
HALT
BIT $0,(HL)
JR Z, VBLANKINTRWAITLOOP
RET


LD C,$41
LD D,$1
LD E,$3
VBLANKINTRWAITLOOPEXIT:
LDH A,[C]
AND E
CP D
JR Z,VBLANKINTRWAITLOOPEXIT
VBLANKINTRWAITLOOPENTER:
LDH A,[C]
AND E
CP D
JR NZ,VBLANKINTRWAITLOOPEXIT
RET

SPACESHIPHALF:
.DB $00,$00,$01,$01,$03,$03,$07,$07,$07,$07,$0F,$0F,$0F,$0F,$0F,$0F
