; =================================================================================
; SUPER MARIO BROS - COMPLETE VERSION WITH FILE HANDLING & SOUND (Roll No: 24I-0857)
; =================================================================================
INCLUDE Irvine32.inc
INCLUDELIB kernel32.lib
GetAsyncKeyState PROTO, vKey:DWORD

.data

; --- FILE ---
highScoreFile   BYTE "scores.txt", 0
fileHandle      DWORD 0

; --- HIGH SCORES ---
MAX_SCORES = 5
highScoreValues DWORD 5000, 4000, 3000, 2000, 1000  ; Default scores
highScoreNames  BYTE "MARIO ", "LUIGI ", "PEACH ", "TOAD  ", "YOSHI "  ; 6 chars each
scoreCount      DWORD 5

; --- PLAYER DATA ---
playerName      BYTE 20 DUP(' ')    ; Current player's name
tempNameBuffer  BYTE 20 DUP(' ')    ; For input
nameLength      BYTE 0

; --- STRINGS ---
strEnterName    BYTE "Enter your name (6 chars max): ", 0
strScoreTitle   BYTE "=== HIGH SCORES ===", 0
strNoScores     BYTE "No high scores yet!", 0
strPressAnyKey  BYTE "Press any key to return to menu...", 0
strYourScore    BYTE "Your score: ", 0
strNewHighScore BYTE "NEW HIGH SCORE!", 0


; --- GAME STATES ---
STATE_MENU      = 0
STATE_SETUP     = 1
STATE_PLAY      = 2
STATE_GAMEOVER  = 3
STATE_INSTR     = 4
STATE_HIGHSCORE = 5
STATE_PAUSE     = 6
currentState    BYTE STATE_MENU

; --- KEYS ---
VK_SHIFT        EQU 10h
VK_LEFT         EQU 25h
VK_UP           EQU 26h
VK_RIGHT        EQU 27h
VK_DOWN         EQU 28h
VK_A            EQU 41h
VK_D            EQU 44h
VK_W            EQU 57h
VK_F            EQU 46h
VK_P            EQU 50h
VK_ESCAPE       EQU 1Bh

jumpKeyPressed  BYTE 0
xMoveTimer      BYTE 0
gravityTimer    BYTE 0
maxJumps        BYTE 2

; --- STRINGS ---
strTitle1       BYTE "=== S U P E R   M A R I O   B R O S ===", 0
strTitle2       BYTE "     HIGH JUMP MARIO - OPTIMIZED!", 0
strRollNo       BYTE "           Roll No: 24I-0857", 0

strOpt1         BYTE "         1. START GAME", 0
strOpt2         BYTE "         2. HIGH SCORES", 0
strOpt3         BYTE "         3. INSTRUCTIONS", 0
strOpt4         BYTE "         4. EXIT", 0

strGameOver     BYTE "GAME OVER - Press 'R' to Restart", 0
strPaused       BYTE "=== PAUSED ===", 0
strPauseOpt1    BYTE "Press 'P' to Resume", 0
strPauseOpt2    BYTE "Press 'ESC' to Exit", 0

strScore1       BYTE "1. MARIO .... 50000", 0
strScore2       BYTE "2. LUIGI .... 45000", 0
strScore3       BYTE "3. YOU ...... 00000", 0

; --- HUD ---
strHUD_Header   BYTE " MARIO              COINS              WORLD                TIME", 0
strHUD_Level    BYTE "                   1-1", 0
strLivesText    BYTE " LIVES: ", 0

; --- INSTRUCTIONS ---
strInstTitle    BYTE "--- INSTRUCTIONS ---", 0
strInst1        BYTE "1. MOVE: WASD or Arrows. Hold SHIFT to RUN.", 0
strInst2        BYTE "2. JUMP: 'W'. Hold longer for High Jump.", 0
strInst3        BYTE "3. FIRE: Press 'F' to shoot Fireballs.", 0
strInst4        BYTE "4. PAUSE: Press 'P' to pause game.", 0
strInst5        BYTE "5. GOAL: Collect Coins, Avoid Enemies.", 0
strInst6        BYTE "6. HORIZONTAL ENEMIES: 'G' (Ground) - 'V' (Air)", 0
strInst7        BYTE "7. VERTICAL ENEMIES: 'K' (Flying)", 0
strInst8        BYTE "8. SOUND: Press 'M' to toggle music", 0
strInstExit     BYTE "   [ Press Any Key to Return ]", 0

; --- CHARACTERS ---
CHAR_SOLID      BYTE 219
CHAR_BRICK      BYTE 178
CHAR_PIPE       BYTE 219
CHAR_COIN       BYTE 'O'
CHAR_MARIO      BYTE 'M'
CHAR_GROUND_ENEMY BYTE 'G'    ; Ground enemy (horizontal)
CHAR_AIR_ENEMY  BYTE 'V'      ; Air enemy (horizontal)
CHAR_FLYING_ENEMY BYTE 'K'    ; Flying enemy (vertical)
CHAR_FIRE       BYTE '*'

; --- COLORS ---
COLOR_SKY       = cyan + (lightBlue * 16)    
COLOR_GROUND    = brown + (lightblue * 16)
COLOR_PIPE      = lightGreen + (lightblue * 16)
COLOR_QBLOCK    = yellow + (lightblue * 16)
COLOR_MARIO     = blue + (green * 16)
COLOR_GROUND_ENEMY_COLOR = red + (lightblue * 16)
COLOR_AIR_ENEMY_COLOR = magenta + (lightblue * 16)
COLOR_FLYING_ENEMY_COLOR = lightRed + (lightblue * 16)
COLOR_FIRE      = yellow + (lightblue * 16)
COLOR_COIN      = yellow + (lightblue * 16)
COLOR_HUD       = white + (lightblue * 16)
COLOR_TITLE     = yellow + (red * 16)

; --- GAME VARIABLES ---
score           DWORD 0
coins           DWORD 0
lives           BYTE 3
gameTime        DWORD 398
frameCounter    BYTE 0
currentLevel    BYTE 1
levelProgress   BYTE 0



; =================================================================================
; COMPREHENSIVE SOUND SYSTEM
; =================================================================================

; --- SOUND CONTROL FLAGS ---
soundEnabled    BYTE 1
musicEnabled    BYTE 1
currentMusic    BYTE 0  ; 0=none, 1=overworld, 2=underground, 3=castle, 4=victory

; Musical note frequencies (Hz) - Full Scale
C3  EQU 130
D3  EQU 146
E3  EQU 164
F3  EQU 174
G3  EQU 196
A3  EQU 220
B3  EQU 246
C4  EQU 261
D4  EQU 293
E4  EQU 329
F4  EQU 349
G4  EQU 392
A4  EQU 440
B4  EQU 493
C5  EQU 523
D5  EQU 587
E5  EQU 659
F5  EQU 698
G5  EQU 784
A5  EQU 880
B5  EQU 987
C6  EQU 1046
D6  EQU 1174
E6  EQU 1318
F6  EQU 1397
G6  EQU 1568
A6  EQU 1760
B6  EQU 1975

; Special effects frequencies
LASER_SOUND   EQU 5000
EXPLOSION_LOW EQU 80
EXPLOSION_HIGH EQU 200

; Sound effect arrays
normalJumpFreq   DWORD 600, 400, 700, 300  ; Double beep for jump
normalJumpDur    DWORD 60, 40, 70, 30
normalJumpCount  DWORD 4

springJumpFreq   DWORD 800, 1200, 1000, 1500  ; Springy triple beep
springJumpDur    DWORD 70, 50, 60, 40
springJumpCount  DWORD 4

coinCollectFreq  DWORD 2000, 2500, 3000  ; Sparkly coin sound
coinCollectDur   DWORD 25, 20, 15
coinCollectCount DWORD 3

enemyDefeatFreq  DWORD 1500, 800, 200  ; Descending "splat" sound
enemyDefeatDur   DWORD 50, 80, 120
enemyDefeatCount DWORD 3

fireballFreq     DWORD 1200, 1000, 800, 600  ; Whoosh sound
fireballDur      DWORD 20, 30, 40, 50
fireballCount    DWORD 4

powerUpFreq      DWORD 523, 659, 784, 1046  ; C5, E5, G5, C6 - Major chord
powerUpDur       DWORD 100, 100, 100, 200
powerUpCount     DWORD 4

; Win sequence - Exciting victory fanfare
winFreq          DWORD 659, 784, 1046, 1318, 1568, 1318, 1046, 1568  ; E5, G5, C6, E6, G6, E6, C6, G6
winDur           DWORD 150, 150, 200, 150, 300, 150, 150, 400
winCount         DWORD 8

; Game Over - Sad descending melody
gameOverFreq     DWORD 523, 466, 415, 349, 311, 277, 246  ; C5, A#4, G#4, F4, D#4, C#4, B3
gameOverDur      DWORD 200, 200, 200, 300, 200, 200, 500
gameOverCount    DWORD 7

; Level Complete - Happy ascending melody
levelCompleteFreq DWORD 523, 659, 784, 1046, 1318, 1568  ; C5, E5, G5, C6, E6, G6
levelCompleteDur  DWORD 120, 120, 120, 150, 150, 300
levelCompleteCount DWORD 6

; Background music - Super Mario Bros overworld theme (simplified)
bgMusicFreq      DWORD 659, 659, 0, 659, 0, 523, 659, 0, 784  ; E5, E5, pause, E5, pause, C5, E5, pause, G5
bgMusicDur       DWORD 200, 200, 100, 200, 100, 200, 200, 100, 400
bgMusicCount     DWORD 9

; Pause/Resume sound
pauseFreq        DWORD 800, 600
pauseDur         DWORD 100, 100
pauseCount       DWORD 2

; Error/bump sound
bumpFreq         DWORD 200, 300
bumpDur          DWORD 50, 50
bumpCount        DWORD 2

; Secret discovered sound
secretFreq       DWORD 1000, 1500, 2000, 2500, 3000
secretDur        DWORD 80, 80, 80, 80, 200
secretCount      DWORD 5

; Time warning sound (when time is low)
timeWarningFreq  DWORD 1000, 0, 1000, 0, 1000
timeWarningDur   DWORD 100, 50, 100, 50, 200
timeWarningCount DWORD 5

; --- PLAYER PHYSICS ---
marioX          BYTE 5
marioY          BYTE 18
oldX            BYTE 5
oldY            BYTE 18
facingRight     BYTE 1
velocityY       SDWORD 0
velocityX       SDWORD 0
jumpCount       BYTE 0
onGroundd       BYTE 1    ; CHANGED from onGround to onGroundd

; --- MOVEMENT ACCELERATION ---
walkAccel       BYTE 1
walkMaxSpeed    BYTE 2
runMaxSpeed     BYTE 3
isRunning       BYTE 0
moveTimer       BYTE 0

; --- ENEMIES ---
; Ground enemy 1 (horizontal movement)
e1_X            BYTE 30
e1_Y            BYTE 18
e1_OldX         BYTE 30
e1_OldY         BYTE 18
e1_Dir          BYTE 0          ; 0=left, 1=right
e1_Active       BYTE 1
e1_Timer        BYTE 0
e1_Type         BYTE 0          ; 0=ground (G), 1=air horizontal (V), 2=flying vertical (K)

; Ground enemy 2 (horizontal movement)
e2_X            BYTE 50
e2_Y            BYTE 18
e2_OldX         BYTE 50
e2_OldY         BYTE 18
e2_Dir          BYTE 1          ; 0=left, 1=right
e2_Active       BYTE 1
e2_Timer        BYTE 0
e2_Type         BYTE 0          ; Ground enemy

; Ground enemy 3 (horizontal movement)
e3_X            BYTE 70
e3_Y            BYTE 18
e3_OldX         BYTE 70
e3_OldY         BYTE 18
e3_Dir          BYTE 0          ; 0=left, 1=right
e3_Active       BYTE 1
e3_Timer        BYTE 0
e3_Type         BYTE 0          ; Ground enemy

; Air enemy (horizontal movement)
e4_X            BYTE 60
e4_Y            BYTE 10
e4_OldX         BYTE 60
e4_OldY         BYTE 10
e4_Dir          BYTE 1          ; 0=left, 1=right
e4_Active       BYTE 1
e4_Timer        BYTE 0
e4_Type         BYTE 1          ; Air horizontal enemy

; Flying enemy 1 (vertical movement)
e5_X            BYTE 40
e5_Y            BYTE 8
e5_OldX         BYTE 40
e5_OldY         BYTE 8
e5_Dir          BYTE 0          ; 0=up, 1=down
e5_Active       BYTE 1
e5_Timer        BYTE 0
e5_Type         BYTE 2          ; Flying vertical enemy

; Flying enemy 2 (vertical movement)
e6_X            BYTE 80
e6_Y            BYTE 12
e6_OldX         BYTE 80
e6_OldY         BYTE 12
e6_Dir          BYTE 1          ; 0=up, 1=down
e6_Active       BYTE 1
e6_Timer        BYTE 0
e6_Type         BYTE 2          ; Flying vertical enemy

; Ground enemy 4 (horizontal movement - near start)
e7_X            BYTE 20
e7_Y            BYTE 18
e7_OldX         BYTE 20
e7_OldY         BYTE 18
e7_Dir          BYTE 1          ; 0=left, 1=right
e7_Active       BYTE 1
e7_Timer        BYTE 0
e7_Type         BYTE 0          ; Ground enemy

; Ground enemy 5 (horizontal movement - middle)
e8_X            BYTE 40
e8_Y            BYTE 18
e8_OldX         BYTE 40
e8_OldY         BYTE 18
e8_Dir          BYTE 0          ; 0=left, 1=right
e8_Active       BYTE 1
e8_Timer        BYTE 0
e8_Type         BYTE 0          ; Ground enemy

; --- PROJECTILE ---
fireX           BYTE 0
fireY           BYTE 0
oldFireX        BYTE 0
oldFireY        BYTE 0
fireDir         BYTE 0
fireActive      BYTE 0
fireTimer       BYTE 0

; --- INPUT ---
inputChar       BYTE 0

; --- LEVEL MAP (80x21) ---
levelMap        LABEL BYTE
    ; Rows 3-10 (Sky with coins)
    BYTE 15 DUP(' '), "CCC", 15 DUP(' '), "CC", 45 DUP(' ')
    BYTE 20 DUP(' '), "CCC", 57 DUP(' ')
    BYTE 640 DUP(' ')
    ; Row 11-13 (High Coins & Stairs)
    BYTE 25 DUP(' '), "CCCCCC", 10 DUP(' '), "CCC", 36 DUP(' ')
    BYTE 10 DUP(' '), "CC", 48 DUP(' '), "###", 17 DUP(' ')
    BYTE 60 DUP(' '), "####", 16 DUP(' ')
    ; Row 14 (Platform with Enemy 3)
    BYTE 35 DUP(' '), "?QQQ?", 40 DUP(' ')
    ; Row 15 (Platform & Coins)
    BYTE 10 DUP(' '), "????", 3 DUP(' '), "CCC", 40 DUP(' '), "#####", 15 DUP(' ')
    ; Row 16 (Lower Coins)
    BYTE 8 DUP(' '), "CCCC", 68 DUP(' ')
    ; Row 17-18 (Sky)
    BYTE 15 DUP(' '), "CC", 143 DUP(' ')
    ; Row 19 (Pipe Tops)
    BYTE 50 DUP(' '), "PP", 28 DUP(' ')
    ; Row 20 (Pipe Bodies)
    BYTE 50 DUP(' '), "PP", 28 DUP(' ')
    ; Row 21-23 (Floor)
    BYTE 25 DUP('#'), "    ", 51 DUP('#')
    BYTE 25 DUP('#'), "    ", 51 DUP('#')
    BYTE 25 DUP('#'), "    ", 51 DUP('#')

.code
; Windows Beep function
Beep PROTO, dwFreq:DWORD, dwDuration:DWORD
main PROC
       call Randomize
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr
    
    ; Load existing scores
    call LoadScores  ; <-- ADD THIS
    
    
    MasterLoop:
        cmp currentState, STATE_MENU
        je  Do_Menu
        cmp currentState, STATE_SETUP
        je  Do_Setup
        cmp currentState, STATE_PLAY
        je  Do_Play
        cmp currentState, STATE_PAUSE
        je  Do_Pause
        cmp currentState, STATE_GAMEOVER
        je  Do_GameOver
        cmp currentState, STATE_INSTR
        je  Do_Instr
        cmp currentState, STATE_HIGHSCORE
        je  Do_HighScore
        exit

    Do_Menu:
        call Process_Menu
        jmp MasterLoop

    Do_Setup:
        call Process_Setup
        jmp MasterLoop

    Do_Play:
        call Process_Play
        jmp MasterLoop

    Do_Pause:
        call Process_Pause
        jmp MasterLoop

    Do_GameOver:
        call Process_GameOver
        jmp MasterLoop

    Do_Instr:
        call Process_Instr
        jmp MasterLoop

    Do_HighScore:
        call Process_HighScore
        jmp MasterLoop
main ENDP

; ================================================
; GET PLAYER NAME - Call this in Process_Setup
; ================================================
GetPlayerName PROC
    ; Clear screen
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr
    
    ; Display prompt
    mov dh, 10
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strEnterName
    call WriteString
    
    mov dh, 12
    mov dl, 25
    call Gotoxy
    
    ; Clear buffer
    mov edi, OFFSET tempNameBuffer
    mov ecx, 20
    mov al, 0
    rep stosb
    
    ; Get input (max 6 characters for display)
    mov edx, OFFSET tempNameBuffer
    mov ecx, 19
    call ReadString
    mov nameLength, al
    
    ; Copy to playerName with proper formatting (6 chars with spaces)
    mov esi, OFFSET tempNameBuffer
    mov edi, OFFSET playerName
    
    ; Clear playerName first
    push edi
    mov ecx, 20
    mov al, ' '
    rep stosb
    pop edi
    
    ; Copy actual characters (max 6)
    movzx ecx, nameLength
    cmp ecx, 6
    jle CopyName
    mov ecx, 6  ; Limit to 6 chars for display
    
CopyName:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop CopyName
    
    ; Ensure last byte is null for string operations
    mov byte ptr [edi], 0
    
    ret
GetPlayerName ENDP

; ================================================
; LOAD SCORES SAFELY - Called at program start
; ================================================
LoadScores PROC
    ; Try to open file
    mov edx, OFFSET highScoreFile
    call OpenInputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je UseDefaults  ; If no file, use defaults
    
    ; Close file - we'll just use defaults for simplicity
    ; (To add file reading, implement SafeLoadScores from previous)
    mov eax, fileHandle
    call CloseFile
    
UseDefaults:
    ; Always use defaults for reliability
    mov scoreCount, 5
    
    ; Ensure player has a default name
    cmp playerName[0], 0
    jne NameOK
    mov playerName[0], 'P'
    mov playerName[1], 'L'
    mov playerName[2], 'A'
    mov playerName[3], 'Y'
    mov playerName[4], 'E'
    mov playerName[5], 'R'
    
NameOK:
    ret
LoadScores ENDP

; ================================================
; ADD HIGH SCORE WITH PLAYER NAME
; ================================================
AddHighScoreWithName PROC
    ; Don't add zero scores
    cmp score, 0
    je NoAdd
    
    ; Make sure we have a name
    cmp playerName[0], 0
    jne HasName
    
    ; Use default if no name
    mov playerName[0], 'P'
    mov playerName[1], 'L'
    mov playerName[2], 'A'
    mov playerName[3], 'Y'
    mov playerName[4], 'E'
    mov playerName[5], 'R'
    
HasName:
    ; Check if score beats any existing score
    mov ecx, scoreCount
    mov ebx, 0
    
CheckLoop:
    cmp ebx, ecx
    jge CheckLast
    
    mov eax, highScoreValues[ebx*4]
    cmp score, eax
    jg InsertScoreHere
    
    inc ebx
    jmp CheckLoop
    
InsertScoreHere:
    ; Shift scores down
    mov ecx, scoreCount
    dec ecx
    
ShiftLoop:
    cmp ecx, ebx
    jl InsertNew
    
    ; Move score down
    mov eax, highScoreValues[ecx*4]
    mov highScoreValues[ecx*4 + 4], eax
    
    ; Move name down
    push esi
    push edi
    push ecx
    
    ; Calculate positions
    mov esi, OFFSET highScoreNames
    mov eax, ecx
    imul eax, 6
    add esi, eax  ; Source
    
    mov edi, OFFSET highScoreNames
    mov eax, ecx
    inc eax
    imul eax, 6
    add edi, eax  ; Destination
    
    ; Copy 6 bytes
    mov ecx, 6
    rep movsb
    
    pop ecx
    pop edi
    pop esi
    
    dec ecx
    jmp ShiftLoop
    
InsertNew:
    ; Insert new score
    mov eax, score
    mov highScoreValues[ebx*4], eax
    
    ; Insert player name (copy first 6 chars)
    mov esi, OFFSET playerName
    mov edi, OFFSET highScoreNames
    mov eax, ebx
    imul eax, 6
    add edi, eax
    
    ; Copy name
    mov ecx, 0
CopyNameLoop:
    cmp ecx, 6
    jge SaveChanges
    mov al, [esi + ecx]
    cmp al, 0
    je FillRest
    mov [edi + ecx], al
    inc ecx
    jmp CopyNameLoop
    
FillRest:
    ; Fill with spaces
    cmp ecx, 6
    jge SaveChanges
    mov byte ptr [edi + ecx], ' '
    inc ecx
    jmp FillRest
    
CheckLast:
    ; Score not higher than any, check if we can add at end
    cmp scoreCount, MAX_SCORES
    jge NoAdd
    
    ; Add at end
    mov eax, score
    mov ecx, scoreCount
    mov highScoreValues[ecx*4], eax
    
    ; Copy name to end
    mov esi, OFFSET playerName
    mov edi, OFFSET highScoreNames
    mov eax, scoreCount
    imul eax, 6
    add edi, eax
    
    mov ecx, 0
CopyToEnd:
    cmp ecx, 6
    jge IncCount
    mov al, [esi + ecx]
    cmp al, 0
    je FillEnd
    mov [edi + ecx], al
    inc ecx
    jmp CopyToEnd
    
FillEnd:
    cmp ecx, 6
    jge IncCount
    mov byte ptr [edi + ecx], ' '
    inc ecx
    jmp FillEnd
    
IncCount:
    inc scoreCount
    
SaveChanges:
    ; Save to file
    call SaveScoresToFile
    
    ; Show message
    mov dh, 18
    mov dl, 25
    call Gotoxy
    mov eax, yellow + (blue * 16)
    call SetTextColor
    mov edx, OFFSET strNewHighScore
    call WriteString
    
    mov eax, 1000
    call Delay
    
NoAdd:
    ret
AddHighScoreWithName ENDP

; ================================================
; SAVE SCORES TO FILE (SIMPLE)
; ================================================
SaveScoresToFile PROC
    ; Create/overwrite file
    mov edx, OFFSET highScoreFile
    call CreateOutputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je SaveError
    
    ; Write each score as text
    mov ecx, scoreCount
    mov ebx, 0
    
WriteLoop:
    cmp ebx, ecx
    jge CloseFile
    
    ; Write name (6 chars)
    push ebx
    mov eax, fileHandle
    mov edx, OFFSET highScoreNames
    mov eax, ebx
    imul eax, 6
    add edx, eax
    mov ecx, 6
    call WriteToFile
    pop ebx
    
    ; Write space
    push ebx
    mov eax, fileHandle
    mov edx, OFFSET spaceChar
    mov ecx, 1
    call WriteToFile
    pop ebx
    
    ; Convert score to string
    push ebx
    mov eax, highScoreValues[ebx*4]
    
    ; Simple conversion for 4-digit scores
    ;mov edi, OFFSET tempBuffer
    mov ecx, 0
    mov ebx, 10
    
    ; Handle zero
    cmp eax, 0
    jne ConvertScore
    mov byte ptr [edi], '0'
    mov byte ptr [edi+1], 0
    jmp WriteScore
    
ConvertScore:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    test eax, eax
    jnz ConvertScore
    
    ; Pop digits
    mov esi, ecx
StoreDigits:
    pop eax
    mov [edi], al
    inc edi
    loop StoreDigits
    
WriteScore:
    ; Write score string
    pop ebx
    push ebx
    mov eax, fileHandle
;    mov edx, OFFSET tempBuffer
    mov ecx, esi
    call WriteToFile
    
    ; Write newline
    mov edx, OFFSET newLine
    mov ecx, 2
    call WriteToFile
    
    pop ebx
    inc ebx
    jmp WriteLoop
    

    mov eax, fileHandle
    call CloseFile
    
SaveError:
    ret

spaceChar BYTE " ", 0
newLine   BYTE 13, 10, 0
SaveScoresToFile ENDP

; ================================================
; DISPLAY HIGH SCORES
; ================================================
Process_HighScore PROC
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr

    ; Title
    mov dh, 5
    mov dl, 30
    call Gotoxy
    mov edx, OFFSET strScoreTitle
    call WriteString

    ; Check if we have scores
    cmp scoreCount, 0
    je NoScores

    ; Display each score
    mov ecx, scoreCount
    mov ebx, 0
    
DisplayLoop:
    push ecx
    
    ; Row position
    mov eax, 8
    add eax, ebx
    add eax, ebx  ; 2 lines between entries
    mov dh, al
    mov dl, 25
    call Gotoxy
    
    ; Display rank
    mov eax, ebx
    inc eax
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display name (6 characters)
    mov edx, OFFSET highScoreNames
    mov eax, ebx
    imul eax, 6
    add edx, eax
    
    ; Print 6 chars
    mov ecx, 6
PrintName:
    mov al, [edx]
    call WriteChar
    inc edx
    loop PrintName
    
    ; Display dots
    mov al, '.'
    mov ecx, 8
PrintDots:
    call WriteChar
    loop PrintDots
    
    ; Display score
    mov eax, highScoreValues[ebx*4]
    call WriteDec
    
    inc ebx
    pop ecx
    loop DisplayLoop
    
    ; Show current player's recent score
    cmp score, 0
    je WaitKey
    
    mov dh, 20
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strYourScore
    call WriteString
    mov eax, score
    call WriteDec

WaitKey:
    ; Wait for key
    mov dh, 23
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strPressAnyKey
    call WriteString
    
    call ReadChar
    mov currentState, STATE_MENU
    ret

NoScores:
    mov dh, 10
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strNoScores
    call WriteString
    jmp WaitKey
    
Process_HighScore ENDP




; =================================================================================
; SOUND & MUSIC PROCEDURES (Using Irvine32 Beep)
; =================================================================================

; =================================================================================
; SOUND EFFECT PROCEDURES
; =================================================================================

; ================================================
; Generic sound player
; ================================================
; Input: ESI = pointer to frequency array
;        EDI = pointer to duration array  
;        ECX = number of notes to play
PlaySoundArray PROC
    pushad
    cmp soundEnabled, 0
    je NoSound
    
    SoundLoop:
        push ecx
        mov eax, [esi]        ; Get frequency
        mov ebx, [edi]        ; Get duration
        
        ; Check if this is a pause (frequency = 0)
        cmp eax, 0
        je IsPause
        
        ; Play the note
        INVOKE Beep, eax, ebx
        
        jmp NextNote
        
    IsPause:
        ; Sleep for the duration instead of beeping
        mov eax, ebx
        call Delay
        
    NextNote:
        add esi, 4            ; Next frequency
        add edi, 4            ; Next duration
        pop ecx
        loop SoundLoop
    
    NoSound:
    popad
    ret
PlaySoundArray ENDP



; ================================================
; Play background music (non-blocking in theory)
; ================================================
PlayBackgroundMusic PROC
    pushad
    cmp musicEnabled, 0
    je NoMusic
    
    ; Only play if no other music is playing
    cmp currentMusic, 0
    jne AlreadyPlaying
    
    mov currentMusic, 1
    
AlreadyPlaying:
    ; In a real game, you'd play this in a separate thread
    ; For now, we'll just occasionally play a note
    inc frameCounter
    cmp frameCounter, 30
    jl NoMusic
    
    mov frameCounter, 0
    INVOKE Beep, 6590, 1000  ; Simple background tone //////yahan change
    
    NoMusic:
    popad
    ret
PlayBackgroundMusic ENDP

; ================================================
; Jump Sound Effects
; ================================================
PlayJumpSound PROC
    pushad
    cmp soundEnabled, 0
    je JumpNoSound
    
    mov esi, OFFSET normalJumpFreq
    mov edi, OFFSET normalJumpDur
    mov ecx, normalJumpCount
    call PlaySoundArray
    
    JumpNoSound:
    popad
    ret
PlayJumpSound ENDP

PlaySpringJumpSound PROC
    pushad
    cmp soundEnabled, 0
    je SpringNoSound
    
    ; Check if Mario is on a special platform (like a spring)
    ; For now, we'll call this for high jumps
    mov eax, velocityY
    cmp eax, -6  ; If jumping very high
    jl HighJump
    jmp RegularJump
    
HighJump:
    mov esi, OFFSET springJumpFreq
    mov edi, OFFSET springJumpDur
    mov ecx, springJumpCount
    call PlaySoundArray
    jmp SpringNoSound
    
RegularJump:
    call PlayJumpSound
    
SpringNoSound:
    popad
    ret
PlaySpringJumpSound ENDP

; ================================================
; Collectible Sounds
; ================================================
PlayCoinSound PROC
    pushad
    cmp soundEnabled, 0
    je CoinNoSound
    
    mov esi, OFFSET coinCollectFreq
    mov edi, OFFSET coinCollectDur
    mov ecx, coinCollectCount
    call PlaySoundArray
    
    CoinNoSound:
    popad
    ret
PlayCoinSound ENDP

PlayPowerUpSound PROC
    pushad
    cmp soundEnabled, 0
    je PowerUpNoSound
    
    mov esi, OFFSET powerUpFreq
    mov edi, OFFSET powerUpDur
    mov ecx, powerUpCount
    call PlaySoundArray
    
    PowerUpNoSound:
    popad
    ret
PlayPowerUpSound ENDP

; ================================================
; Combat Sounds
; ================================================
PlayEnemySound PROC
    pushad
    cmp soundEnabled, 0
    je EnemyNoSound
    
    mov esi, OFFSET enemyDefeatFreq
    mov edi, OFFSET enemyDefeatDur
    mov ecx, enemyDefeatCount
    call PlaySoundArray
    
    EnemyNoSound:
    popad
    ret
PlayEnemySound ENDP

PlayFireSound PROC
    pushad
    cmp soundEnabled, 0
    je FireballNoSound
    
    mov esi, OFFSET fireballFreq
    mov edi, OFFSET fireballDur
    mov ecx, fireballCount
    call PlaySoundArray
    
    FireballNoSound:
    popad
    ret
PlayFireSound ENDP

; ================================================
; Game State Sounds
; ================================================
PlayVictorySound PROC
    pushad
    cmp soundEnabled, 0
    je WinNoSound
    
    mov esi, OFFSET winFreq
    mov edi, OFFSET winDur
    mov ecx, winCount
    call PlaySoundArray
    
    WinNoSound:
    popad
    ret
PlayVictorySound ENDP

PlayGameOverSound PROC
    pushad
    cmp soundEnabled, 0
    je GameOverNoSound
    
    mov esi, OFFSET gameOverFreq
    mov edi, OFFSET gameOverDur
    mov ecx, gameOverCount
    call PlaySoundArray
    
    GameOverNoSound:
    popad
    ret
PlayGameOverSound ENDP

PlayLevelCompleteSound PROC
    pushad
    cmp soundEnabled, 0
    je LevelCompleteNoSound
    
    mov esi, OFFSET levelCompleteFreq
    mov edi, OFFSET levelCompleteDur
    mov ecx, levelCompleteCount
    call PlaySoundArray
    
    LevelCompleteNoSound:
    popad
    ret
PlayLevelCompleteSound ENDP

; ================================================
; UI Sounds
; ================================================
PlayPauseSound PROC
    pushad
    cmp soundEnabled, 0
    je PauseNoSound
    
    mov esi, OFFSET pauseFreq
    mov edi, OFFSET pauseDur
    mov ecx, pauseCount
    call PlaySoundArray
    
    PauseNoSound:
    popad
    ret
PlayPauseSound ENDP

PlayBumpSound PROC
    pushad
    cmp soundEnabled, 0
    je BumpNoSound
    
    ; Play when hitting a wall or blocked
    mov esi, OFFSET bumpFreq
    mov edi, OFFSET bumpDur
    mov ecx, bumpCount
    call PlaySoundArray
    
    BumpNoSound:
    popad
    ret
PlayBumpSound ENDP

PlaySecretSound PROC
    pushad
    cmp soundEnabled, 0
    je SecretNoSound
    
    ; Play when discovering a secret area
    mov esi, OFFSET secretFreq
    mov edi, OFFSET secretDur
    mov ecx, secretCount
    call PlaySoundArray
    
    SecretNoSound:
    popad
    ret
PlaySecretSound ENDP

PlayTimeWarningSound PROC
    pushad
    cmp soundEnabled, 0
    je TimeWarningNoSound
    
    ; Play when time is running low
    cmp gameTime, 100
    jg TimeWarningNoSound
    
    ; Only play every 2 seconds
    mov al, frameCounter
    and al, 63  ; Check every 64 frames (~1 second)
    cmp al, 0
    jne TimeWarningNoSound
    
    mov esi, OFFSET timeWarningFreq
    mov edi, OFFSET timeWarningDur
    mov ecx, timeWarningCount
    call PlaySoundArray
    
TimeWarningNoSound:
    popad
    ret
PlayTimeWarningSound ENDP

; ================================================
; Creative Special Effects
; ================================================
PlayLaserSound PROC
    pushad
    cmp soundEnabled, 0
    je LaserNoSound
    
    ; Quick laser zap
    INVOKE Beep, LASER_SOUND, 50
    
    LaserNoSound:
    popad
    ret
PlayLaserSound ENDP

PlayExplosionSound PROC
    pushad
    cmp soundEnabled, 0
    je ExplosionNoSound
    
    ; Explosion with descending rumble
    INVOKE Beep, EXPLOSION_HIGH, 30
    INVOKE Beep, EXPLOSION_LOW, 200
    
    ExplosionNoSound:
    popad
    ret
PlayExplosionSound ENDP

PlayTeleportSound PROC
    pushad
    cmp soundEnabled, 0
    je TeleportNoSound
    
    ; Mystical teleport sound
    INVOKE Beep, 3000, 30
    INVOKE Beep, 1500, 40
    INVOKE Beep, 800, 50
    INVOKE Beep, 5000, 20
    
    TeleportNoSound:
    popad
    ret
PlayTeleportSound ENDP

PlayHealSound PROC
    pushad
    cmp soundEnabled, 0
    je HealNoSound
    
    ; Gentle healing chime
    INVOKE Beep, 784, 100  ; G5
    INVOKE Beep, 1046, 150 ; C6
    INVOKE Beep, 1318, 200 ; E6
    
    HealNoSound:
    popad
    ret
PlayHealSound ENDP

; ================================================
; Sound Control Functions
; ================================================
ToggleMusic PROC
    cmp musicEnabled, 1
    je TurnMusicOff
    mov musicEnabled, 1
    ; Play music on sound
    INVOKE Beep, 523, 100  ; C5
    INVOKE Beep, 659, 100  ; E5
    ret
TurnMusicOff:
    mov musicEnabled, 0
    mov currentMusic, 0
    ; Play music off sound
    INVOKE Beep, 659, 100  ; E5
    INVOKE Beep, 523, 100  ; C5
    ret
ToggleMusic ENDP

ToggleSound PROC
    cmp soundEnabled, 1
    je TurnSoundOff
    mov soundEnabled, 1
    ; Play confirmation sound
    INVOKE Beep, 800, 50
    ret
TurnSoundOff:
    mov soundEnabled, 0
    ; Play off sound
    INVOKE Beep, 400, 50
    ret
ToggleSound ENDP
; =================================================================================
; STATE LOGIC
; =================================================================================

Process_Menu PROC
    call DrawMainMenu
    call ReadChar
    mov inputChar, al
    
    ; Clear any remaining input
    call ClearInputBuffer
    
    cmp inputChar, '1'
    je  SetSetup
    cmp inputChar, '2'
    je  SetHighScore  ; Changed from SetScore
    cmp inputChar, '3'
    je  SetInstr
    cmp inputChar, '4'
    je  ReqExit
    ret

SetSetup:
    mov currentState, STATE_SETUP
    ret
    
SetHighScore:  ; Changed label
    mov currentState, STATE_HIGHSCORE
    ret
    
SetInstr:
    mov currentState, STATE_INSTR
    ret
    
ReqExit:
    ;call SaveGameData
    exit
    
ClearInputBuffer:
    ; Clear any remaining characters in the input buffer
    push eax
InputLoop:
    call ReadKey
    jz DoneClear
    jmp InputLoop
DoneClear:
    pop eax
    ret
Process_Menu ENDP

Process_Pause PROC
    ; Draw pause overlay
    mov dh, 10
    mov dl, 32
    call Gotoxy
    mov eax, white + (red * 16)
    call SetTextColor
    mov edx, OFFSET strPaused
    call WriteString

    mov dh, 12
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET strPauseOpt1
    call WriteString

    mov dh, 13
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET strPauseOpt2
    call WriteString

    ; Wait for input
    WaitForUnpause:
        invoke GetAsyncKeyState, VK_P
        test eax, 8000h
        jnz CheckPRelease

        invoke GetAsyncKeyState, VK_ESCAPE
        test eax, 8000h
        jnz ExitToMenu

        ; Check for music toggle
        invoke GetAsyncKeyState, 'M'
        test eax, 8000h
        jnz ToggleMusicPause

        mov eax, 50
        call Delay
        jmp WaitForUnpause

    CheckPRelease:
        ; Wait for P key release
        invoke GetAsyncKeyState, VK_P
        test eax, 8000h
        jnz CheckPRelease
        ; Redraw screen
        mov eax, COLOR_SKY
        call SetTextColor
        call Clrscr
        call DrawLevelMap
        call DrawHUD_Static
        call Game_RenderAll  ; Draw Mario and enemies immediately
        mov currentState, STATE_PLAY
        ret

    ToggleMusicPause:
        call ToggleMusic
        mov eax, 200
        call Delay
        jmp WaitForUnpause

    ExitToMenu:
        mov currentState, STATE_MENU
        ret
Process_Pause ENDP

Process_Instr PROC
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr

    mov dh, 5
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strInstTitle
    call WriteString

    mov dh, 8
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst1
    call WriteString

    mov dh, 10
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst2
    call WriteString

    mov dh, 12
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst3
    call WriteString

    mov dh, 14
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst4
    call WriteString

    mov dh, 16
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst5
    call WriteString

    mov dh, 18
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst6
    call WriteString

    mov dh, 20
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst7
    call WriteString

    mov dh, 22
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst8
    call WriteString

    mov dh, 25
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strInstExit
    call WriteString

    call ReadChar
    mov currentState, STATE_MENU
    ret
Process_Instr ENDP



Process_Setup PROC
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr
    
    ; Get player name
    call GetPlayerName  ; <-- ADD THIS

    ; Reset game variables
    mov score, 0
    mov coins, 0
    mov lives, 3
    mov gameTime, 398
    
    mov marioX, 5
    mov marioY, 18
    mov oldX, 5
    mov oldY, 18
    
    mov velocityY, 0
    mov velocityX, 0
    mov jumpCount, 0
    mov isRunning, 0
    mov onGroundd, 1

    call ResetEnemiesForLevel
    mov fireActive, 0

    call DrawLevelMap
    call DrawHUD_Static
    call Game_RenderAll

    mov currentState, STATE_PLAY
    ret
Process_Setup ENDP

ResetEnemiesForLevel PROC
    ; Reset enemies based on current level
    cmp currentLevel, 1
    je Level1Enemies
    cmp currentLevel, 2
    je Level2Enemies
    ; Level 3 enemies
    jmp Level3Enemies
    
Level1Enemies:
    ; Level 1 enemies
    mov e1_X, 30
    mov e1_Y, 18
    mov e1_Active, 1
    mov e1_OldX, 30
    mov e1_OldY, 18
    mov e1_Timer, 0
    mov e1_Type, 0
    
    mov e2_X, 50
    mov e2_Y, 18
    mov e2_Active, 1
    mov e2_OldX, 50
    mov e2_OldY, 18
    mov e2_Timer, 0
    mov e2_Type, 0
    
    mov e3_X, 70
    mov e3_Y, 18
    mov e3_Active, 1
    mov e3_OldX, 70
    mov e3_OldY, 18
    mov e3_Timer, 0
    mov e3_Type, 0
    
    mov e4_X, 60
    mov e4_Y, 10
    mov e4_Active, 1
    mov e4_OldX, 60
    mov e4_OldY, 10
    mov e4_Timer, 0
    mov e4_Type, 1
    
    mov e5_X, 40
    mov e5_Y, 8
    mov e5_Active, 1
    mov e5_OldX, 40
    mov e5_OldY, 8
    mov e5_Timer, 0
    mov e5_Type, 2
    
    mov e6_X, 80
    mov e6_Y, 12
    mov e6_Active, 1
    mov e6_OldX, 80
    mov e6_OldY, 12
    mov e6_Timer, 0
    mov e6_Type, 2
    
    mov e7_X, 20
    mov e7_Y, 18
    mov e7_Active, 1
    mov e7_OldX, 20
    mov e7_OldY, 18
    mov e7_Timer, 0
    mov e7_Type, 0
    
    mov e8_X, 40
    mov e8_Y, 18
    mov e8_Active, 1
    mov e8_OldX, 40
    mov e8_OldY, 18
    mov e8_Timer, 0
    mov e8_Type, 0
    ret
    
Level2Enemies:
    ; Level 2 has more enemies
    ; Similar setup but with more enemies
    ret
    
Level3Enemies:
    ; Level 3 has the most enemies
    ; Similar setup but with even more enemies
    ret
ResetEnemiesForLevel ENDP

Process_Play PROC
    ; Check for pause
    invoke GetAsyncKeyState, VK_P
    test eax, 8000h
    jnz PauseGame
    
    ; Check for music toggle
    invoke GetAsyncKeyState, 'M'
    test eax, 8000h
    jnz ToggleMusicPlay

    ; 60 FPS Logic (16ms)
    mov eax, 16
    call Delay

    ; REMOVE THIS LINE (might cause exceptions):
    ; call PlayTimeWarningSound  ; <-- COMMENT OUT OR DELETE

    ; Clear previous input
    mov inputChar, 0

    call Game_HandleInput
    call Game_UpdatePhysics
    call Game_UpdateXMovement

    call Update_E1
    call Update_E2
    call Update_E3
    call Update_E4
    call Update_E5
    call Update_E6
    call Update_E7
    call Update_E8
    call Game_UpdateFireball

    call Game_RenderAll

    call Game_UpdateTimer
    call DrawHUD_Dynamic
    
    ; Check for level completion
    call CheckLevelCompletion

    ret

    PauseGame:
        ; Wait for key release
        invoke GetAsyncKeyState, VK_P
        test eax, 8000h
        jnz PauseGame
        mov currentState, STATE_PAUSE
        ret
        
    ToggleMusicPlay:
        call ToggleMusic
        mov eax, 200
        call Delay
        ret
Process_Play ENDP

CheckLevelCompletion PROC
    cmp marioX, 78
    jl NotComplete
    
    ; Level completed
    call PlayVictorySound
    
    ; COMMENT OUT the high score call temporarily:
    ; call AddHighScore  ; <-- COMMENT THIS LINE
    
    ; Update level progress
    inc levelProgress
    cmp levelProgress, 3
    jl NotMaxLevel
    mov levelProgress, 0
    inc currentLevel
    
NotMaxLevel:
    ; COMMENT OUT save if it causes issues:
    ; call SaveGameData
    
    mov currentState, STATE_SETUP
    
NotComplete:
    ret
CheckLevelCompletion ENDP



Process_GameOver PROC
    call PlayGameOverSound
    
    ; CHANGE THIS LINE:
    ; call AddHighScore  ; <-- OLD
    call AddHighScoreWithName  ; <-- NEW (with name)
    
    ; Save progress (only if procedure exists)
    ; call SaveGameData  ; <-- Optional
    
    ; Display game over message
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov eax, white + (red * 16)
    call SetTextColor
    mov edx, OFFSET strGameOver
    call WriteString
    
    call ReadChar
    cmp al, 'r'
    je Restart
    cmp al, 'R'
    je Restart
    exit
    
Restart:
    mov currentState, STATE_MENU
    ret
Process_GameOver ENDP
; =================================================================================
; INPUT & PHYSICS
; =================================================================================

Game_HandleInput PROC
    ; --- 1. RUNNING (Shift) ---
    invoke GetAsyncKeyState, VK_SHIFT
    test eax, 8000h
    jnz SetRun
    mov isRunning, 0
    jmp CheckMoves
    SetRun:
    mov isRunning, 1

    CheckMoves:
    ; --- 2. LEFT ---
    invoke GetAsyncKeyState, VK_A
    test eax, 8000h
    jnz MoveL
    invoke GetAsyncKeyState, VK_LEFT
    test eax, 8000h
    jnz MoveL
    jmp CheckRight
    MoveL:
    mov inputChar, 'a'
    jmp CheckJump

    CheckRight:
    ; --- 3. RIGHT ---
    invoke GetAsyncKeyState, VK_D
    test eax, 8000h
    jnz MoveR
    invoke GetAsyncKeyState, VK_RIGHT
    test eax, 8000h
    jnz MoveR
    jmp CheckJump
    MoveR:
    mov inputChar, 'd'

    CheckJump:
    ; --- 4. JUMP (DOUBLE JUMP LOGIC) ---
    invoke GetAsyncKeyState, VK_W
    test eax, 8000h
    jnz KeyIsDown
    invoke GetAsyncKeyState, VK_UP
    test eax, 8000h
    jnz KeyIsDown

    ; Key Released: Reset Lock
    mov jumpKeyPressed, 0
    jmp CheckFire

    KeyIsDown:
    cmp jumpKeyPressed, 1
    je CheckFire

    ; Key Just Pressed: Try to Jump
    mov jumpKeyPressed, 1

    ; Check Max Jumps
    mov al, jumpCount
    cmp al, maxJumps
    jge CheckFire

     ; Perform Jump
    inc jumpCount
    mov velocityY, -5  ; Stronger jump
    
    ; Use spring jump for high jumps, normal for regular jumps
    cmp velocityY, -6
    jl UseSpringJump
    call PlayJumpSound
    jmp CheckFire
UseSpringJump:
    call PlaySpringJumpSound

    CheckFire:
    ; --- 5. FIRE ---
    invoke GetAsyncKeyState, VK_F
    test eax, 8000h
    jnz DoFire
    ret

    DoFire:
    mov inputChar, 'f'
    call PlayFireSound
    ret
Game_HandleInput ENDP

Game_UpdateXMovement PROC
    ; --- MOVEMENT TIMER FOR SMOOTH MOTION ---
    inc moveTimer
    cmp isRunning, 1
    je DoMove
    cmp moveTimer, 3
    jl EndMoveX
    DoMove:
    mov moveTimer, 0

    cmp inputChar, 'a'
    je MoveLeft
    cmp inputChar, 'd'
    je MoveRight
    jmp EndMoveX

       MoveLeft:
        mov facingRight, 0
        cmp marioX, 1
        jle HitWallLeft
        call GetMapCharAtNextLeft
        cmp al, '#'
        je HitWallLeft
        cmp al, 'P'
        je HitWallLeft
        cmp al, '?'
        je HitWallLeft
        cmp al, 'Q'
        je HitWallLeft
        dec marioX
        jmp EndMoveX
        
    HitWallLeft:
        call PlayBumpSound
        jmp EndMoveX
        
    MoveRight:
        mov facingRight, 1
        cmp marioX, 78
        jge HitWallRight
        call GetMapCharAtNextRight
        cmp al, '#'
        je HitWallRight
        cmp al, 'P'
        je HitWallRight
        cmp al, '?'
        je HitWallRight
        cmp al, 'Q'
        je HitWallRight
        inc marioX
        jmp EndMoveX
        
    HitWallRight:
        call PlayBumpSound
        jmp EndMoveX

    EndMoveX:
    ret
Game_UpdateXMovement ENDP

PlayFlyingEnemyDefeat PROC
    pushad
    cmp soundEnabled, 0
    je FlyingEnemyNoSound
    
    call PlayExplosionSound
    
FlyingEnemyNoSound:
    popad
    ret
PlayFlyingEnemyDefeat ENDP

Game_UpdatePhysics PROC
    ; Handle Fire Trigger
    cmp inputChar, 'f'
    jne ApplyGravity
    call TryFire

    ApplyGravity:
    ; --- GRAVITY TIMER ---
    inc gravityTimer
    cmp gravityTimer, 5
    jl PhysEnd
    mov gravityTimer, 0

    ; Check Velocity Direction
    mov eax, velocityY
    cmp eax, 0
    jl GoingUp
    jg GoingDown
    jmp CheckSupport

    GoingUp:
        ; Check ceiling collision
        cmp marioY, 3
        jle HitCeiling
        call GetMapCharAbove
        cmp al, '#'
        je HitCeiling
        cmp al, '?'
        je HitCeiling
        cmp al, 'Q'
        je HitCeiling
        dec marioY
        inc velocityY
        cmp velocityY, 0
        jge StartFalling
        jmp PhysEnd
        
        HitCeiling:
            mov velocityY, 2
            jmp PhysEnd
        
        StartFalling:
            mov onGroundd, 0    ; CHANGED
            jmp PhysEnd

    GoingDown:
        call GetMapCharAtBelow
        cmp al, '#'
        je HitFloor
        cmp al, 'P'
        je HitFloor
        cmp al, '?'
        je HitFloor
        cmp al, 'Q'
        je HitFloor

        ; Fall Down
        inc marioY
        inc velocityY
        mov onGroundd, 0    ; CHANGED

        ; Cap Velocity
        cmp velocityY, 4
        jle PhysEnd
        mov velocityY, 4
        jmp PhysEnd

    CheckSupport:
        call GetMapCharAtBelow
        cmp al, '#'
        je OnGround
        cmp al, 'P'
        je OnGround
        cmp al, '?'
        je OnGround
        cmp al, 'Q'
        je OnGround

        ; Falling
        mov velocityY, 1
        mov onGroundd, 0    ; CHANGED
        jmp PhysEnd

    HitFloor:
        mov velocityY, 0
        mov jumpCount, 0
        mov onGroundd, 1    ; CHANGED
        jmp PhysEnd

    OnGround:
        mov velocityY, 0
        mov jumpCount, 0
        mov onGroundd, 1    ; CHANGED
        jmp PhysEnd

    PhysEnd:
    ; Check if fell off the map
    cmp marioY, 23
    jge Die
    ret
    
    Die:
    ; Decrease life instead of immediate game over
    dec lives
    cmp lives, 0
    jle ReallyDie
    ; Reset position
    mov marioX, 5
    mov marioY, 18
    mov oldX, 5
    mov oldY, 18
    mov velocityY, 0
    mov onGroundd, 1    ; CHANGED
    ret
    
    ReallyDie:
    mov currentState, STATE_GAMEOVER
    ret
Game_UpdatePhysics ENDP

GetMapCharAbove PROC
    ; Returns character above Mario in AL
    movzx ecx, marioY
    dec ecx
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, marioX
    add eax, ecx
    mov ebx, OFFSET levelMap
    add ebx, eax
    mov al, [ebx]
    ret
GetMapCharAbove ENDP

TryFire PROC
    cmp fireActive, 1
    je EndFireReq
    mov al, marioX
    mov fireX, al
    mov oldFireX, al
    mov al, marioY
    mov fireY, al
    mov oldFireY, al
    mov al, facingRight
    mov fireDir, al
    mov fireActive, 1
    mov fireTimer, 0
    EndFireReq:
    ret
TryFire ENDP

; =================================================================================
; ENTITY UPDATES
; =================================================================================

CheckEnemyCollision PROC
    ; Check all ground and air enemies
    mov ecx, 8  ; Check 8 enemies
    
    EnemyCheckLoop:
        push ecx
        
        cmp ecx, 8
        je CheckE1
        cmp ecx, 7
        je CheckE2
        cmp ecx, 6
        je CheckE3
        cmp ecx, 5
        je CheckE4
        cmp ecx, 4
        je CheckE5
        cmp ecx, 3
        je CheckE6
        cmp ecx, 2
        je CheckE7
        cmp ecx, 1
        je CheckE8
        
        jmp NextEnemyCheck
        
    CheckE1:
        cmp e1_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e1_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e1_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE2:
        cmp e2_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e2_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e2_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE3:
        cmp e3_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e3_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e3_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE4:
        cmp e4_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e4_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e4_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE5:
        cmp e5_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e5_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e5_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE6:
        cmp e6_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e6_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e6_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE7:
        cmp e7_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e7_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e7_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    CheckE8:
        cmp e8_Active, 1
        jne NextEnemyCheck
        mov al, marioX
        cmp al, e8_X
        jne NextEnemyCheck
        mov al, marioY
        cmp al, e8_Y
        jne NextEnemyCheck
        jmp EnemyCollisionDetected
        
    NextEnemyCheck:
        pop ecx
        dec ecx
        jnz EnemyCheckLoop
        jmp NoCollision
    
    EnemyCollisionDetected:
        pop ecx  ; Clean up stack
        call PlayEnemySound
        dec lives
        cmp lives, 0
        jle EnemyDie
        ; Reset position
        mov marioX, 5
        mov marioY, 18
        mov oldX, 5
        mov oldY, 18
        mov velocityY, 0
        mov onGroundd, 1    ; CHANGED
        ret
        
    EnemyDie:
        mov currentState, STATE_GAMEOVER
        ret

    NoCollision:
        ret
CheckEnemyCollision ENDP

Update_E1 PROC
    ; Ground enemy 1 (G) - Horizontal movement
    cmp e1_Active, 0
    je RetE1
    
    ; Slow down enemy movement with timer
    inc e1_Timer
    cmp e1_Timer, 4
    jl RetE1
    mov e1_Timer, 0
    
    cmp e1_Dir, 0
    je E1_L
    ; Move right
    inc e1_X
    cmp e1_X, 35
    jge E1_FlipL
    jmp E1_End
    E1_FlipL:
        mov e1_Dir, 0
        jmp E1_End
    E1_L:
        ; Move left
        dec e1_X
        cmp e1_X, 25
        jle E1_FlipR
        jmp E1_End
    E1_FlipR:
        mov e1_Dir, 1
    E1_End:
    RetE1:
    ret
Update_E1 ENDP

Update_E2 PROC
    ; Ground enemy 2 (G) - Horizontal movement
    cmp e2_Active, 0
    je RetE2
    
    ; Slow down enemy movement with timer
    inc e2_Timer
    cmp e2_Timer, 5
    jl RetE2
    mov e2_Timer, 0
    
    cmp e2_Dir, 0
    je E2_L
    ; Move right
    inc e2_X
    cmp e2_X, 55
    jge E2_FlipL
    jmp E2_End
    E2_FlipL:
        mov e2_Dir, 0
        jmp E2_End
    E2_L:
        ; Move left
        dec e2_X
        cmp e2_X, 45
        jle E2_FlipR
        jmp E2_End
    E2_FlipR:
        mov e2_Dir, 1
    E2_End:
    RetE2:
    ret
Update_E2 ENDP

Update_E3 PROC
    ; Ground enemy 3 (G) - Horizontal movement
    cmp e3_Active, 0
    je RetE3
    
    ; Slow down enemy movement with timer
    inc e3_Timer
    cmp e3_Timer, 6
    jl RetE3
    mov e3_Timer, 0
    
    cmp e3_Dir, 0
    je E3_L
    ; Move right
    inc e3_X
    cmp e3_X, 75
    jge E3_FlipL
    jmp E3_End
    E3_FlipL:
        mov e3_Dir, 0
        jmp E3_End
    E3_L:
        ; Move left
        dec e3_X
        cmp e3_X, 65
        jle E3_FlipR
        jmp E3_End
    E3_FlipR:
        mov e3_Dir, 1
    E3_End:
    RetE3:
    ret
Update_E3 ENDP

Update_E4 PROC
    ; Air enemy (V) - Horizontal movement
    cmp e4_Active, 0
    je RetE4
    
    ; Slow down enemy movement with timer
    inc e4_Timer
    cmp e4_Timer, 3
    jl RetE4
    mov e4_Timer, 0
    
    cmp e4_Dir, 0
    je E4_L
    ; Move right
    inc e4_X
    cmp e4_X, 70
    jge E4_FlipL
    jmp E4_End
    E4_FlipL:
        mov e4_Dir, 0
        jmp E4_End
    E4_L:
        ; Move left
        dec e4_X
        cmp e4_X, 50
        jle E4_FlipR
        jmp E4_End
    E4_FlipR:
        mov e4_Dir, 1
    E4_End:
    RetE4:
    ret
Update_E4 ENDP

Update_E5 PROC
    ; Flying enemy 1 (K) - Vertical movement
    cmp e5_Active, 0
    je RetE5
    
    ; Slow down enemy movement with timer
    inc e5_Timer
    cmp e5_Timer, 5
    jl RetE5
    mov e5_Timer, 0
    
    cmp e5_Dir, 0
    je E5_Up
    ; Move down
    inc e5_Y
    cmp e5_Y, 15
    jge E5_FlipUp
    jmp E5_End
    E5_FlipUp:
        mov e5_Dir, 0
        jmp E5_End
    E5_Up:
        ; Move up
        dec e5_Y
        cmp e5_Y, 5
        jle E5_FlipDown
        jmp E5_End
    E5_FlipDown:
        mov e5_Dir, 1
    E5_End:
    RetE5:
    ret
Update_E5 ENDP

Update_E6 PROC
    ; Flying enemy 2 (K) - Vertical movement
    cmp e6_Active, 0
    je RetE6
    
    ; Slow down enemy movement with timer
    inc e6_Timer
    cmp e6_Timer, 4
    jl RetE6
    mov e6_Timer, 0
    
    cmp e6_Dir, 0
    je E6_Up
    ; Move down
    inc e6_Y
    cmp e6_Y, 17
    jge E6_FlipUp
    jmp E6_End
    E6_FlipUp:
        mov e6_Dir, 0
        jmp E6_End
    E6_Up:
        ; Move up
        dec e6_Y
        cmp e6_Y, 7
        jle E6_FlipDown
        jmp E6_End
    E6_FlipDown:
        mov e6_Dir, 1
    E6_End:
    RetE6:
    ret
Update_E6 ENDP

Update_E7 PROC
    ; Ground enemy 4 (G) - Horizontal movement (near start)
    cmp e7_Active, 0
    je RetE7
    
    ; Slow down enemy movement with timer
    inc e7_Timer
    cmp e7_Timer, 4
    jl RetE7
    mov e7_Timer, 0
    
    cmp e7_Dir, 0
    je E7_L
    ; Move right
    inc e7_X
    cmp e7_X, 25
    jge E7_FlipL
    jmp E7_End
    E7_FlipL:
        mov e7_Dir, 0
        jmp E7_End
    E7_L:
        ; Move left
        dec e7_X
        cmp e7_X, 15
        jle E7_FlipR
        jmp E7_End
    E7_FlipR:
        mov e7_Dir, 1
    E7_End:
    RetE7:
    ret
Update_E7 ENDP

Update_E8 PROC
    ; Ground enemy 5 (G) - Horizontal movement (middle)
    cmp e8_Active, 0
    je RetE8
    
    ; Slow down enemy movement with timer
    inc e8_Timer
    cmp e8_Timer, 5
    jl RetE8
    mov e8_Timer, 0
    
    cmp e8_Dir, 0
    je E8_L
    ; Move right
    inc e8_X
    cmp e8_X, 45
    jge E8_FlipL
    jmp E8_End
    E8_FlipL:
        mov e8_Dir, 0
        jmp E8_End
    E8_L:
        ; Move left
        dec e8_X
        cmp e8_X, 35
        jle E8_FlipR
        jmp E8_End
    E8_FlipR:
        mov e8_Dir, 1
    E8_End:
    RetE8:
    ret
Update_E8 ENDP

Game_UpdateFireball PROC
    cmp fireActive, 0
    je EndFire
    inc fireTimer
    cmp fireTimer, 2
    jl EndFire
    mov fireTimer, 0
    cmp fireDir, 1
    je FireR
    dec fireX
    jmp CheckFCol
    FireR:
    inc fireX

    CheckFCol:
        ; Check bounds
        cmp fireX, 1
        jle KillFire
        cmp fireX, 78
        jge KillFire
        
        ; Check terrain collision
        call GetMapCharAtFire
        cmp al, '#'
        je KillFire
        cmp al, 'P'
        je KillFire
        cmp al, '?'
        je KillFire
        cmp al, 'Q'
        je KillFire

        ; Check collision with all enemies
        mov ecx, 8  ; Check 8 enemies
        
        FireEnemyCheckLoop:
            push ecx
            
            cmp ecx, 8
            je FireCheckE1
            cmp ecx, 7
            je FireCheckE2
            cmp ecx, 6
            je FireCheckE3
            cmp ecx, 5
            je FireCheckE4
            cmp ecx, 4
            je FireCheckE5
            cmp ecx, 3
            je FireCheckE6
            cmp ecx, 2
            je FireCheckE7
            cmp ecx, 1
            je FireCheckE8
            
            jmp NextFireEnemyCheck
            
        FireCheckE1:
            cmp e1_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e1_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e1_Y
            jne NextFireEnemyCheck
            mov e1_Active, 0
            add score, 100
            call PlayEnemySound
            jmp KillFire
            
        FireCheckE2:
            cmp e2_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e2_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e2_Y
            jne NextFireEnemyCheck
            mov e2_Active, 0
            add score, 100
            call PlayEnemySound
            jmp KillFire
            
        FireCheckE3:
            cmp e3_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e3_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e3_Y
            jne NextFireEnemyCheck
            mov e3_Active, 0
            add score, 100
            call PlayEnemySound
            jmp KillFire
            
        FireCheckE4:
            cmp e4_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e4_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e4_Y
            jne NextFireEnemyCheck
            mov e4_Active, 0
            add score, 150
            call PlayEnemySound
            jmp KillFire
            
            FireCheckE5:
        cmp e5_Active, 1
        jne NextFireEnemyCheck
        mov al, fireX
        cmp al, e5_X
        jne NextFireEnemyCheck
        mov al, fireY
        cmp al, e5_Y
        jne NextFireEnemyCheck
        mov e5_Active, 0
        add score, 200
        call PlayFlyingEnemyDefeat  ; Changed from PlayEnemySound
        jmp KillFire
            
        FireCheckE6:
            cmp e6_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e6_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e6_Y
            jne NextFireEnemyCheck
            mov e6_Active, 0
            add score, 200
            call PlayEnemySound
            jmp KillFire
            
        FireCheckE7:
            cmp e7_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e7_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e7_Y
            jne NextFireEnemyCheck
            mov e7_Active, 0
            add score, 100
            call PlayEnemySound
            jmp KillFire
            
        FireCheckE8:
            cmp e8_Active, 1
            jne NextFireEnemyCheck
            mov al, fireX
            cmp al, e8_X
            jne NextFireEnemyCheck
            mov al, fireY
            cmp al, e8_Y
            jne NextFireEnemyCheck
            mov e8_Active, 0
            add score, 100
            call PlayEnemySound
            jmp KillFire
            
        NextFireEnemyCheck:
            pop ecx
            dec ecx
            jnz FireEnemyCheckLoop
            jmp F_Bounds

    F_Bounds:
        jmp EndFire

    KillFire:
        pop ecx  ; Clean up stack
        mov fireActive, 0
    EndFire:
    ret
Game_UpdateFireball ENDP

; =================================================================================
; RENDERING - ALL IN ONE PASS
; =================================================================================

Game_RenderAll PROC
    ; Clear old Mario position (only if position changed)
    mov al, oldX
    cmp al, marioX
    jne ClearMario
    mov al, oldY
    cmp al, marioY
    je SkipClearMario

    ClearMario:
        mov dh, oldY
        mov dl, oldX
        call RestoreBackground

    SkipClearMario:

    ; Clear old enemy 1
    cmp e1_Active, 1
    jne SkipE1Clear
    mov al, e1_OldX
    cmp al, e1_X
    jne ClearE1
    mov al, e1_OldY
    cmp al, e1_Y
    je SkipE1Clear
    ClearE1:
        mov dh, e1_OldY
        mov dl, e1_OldX
        call RestoreBackground
    SkipE1Clear:

    ; Clear old enemy 2
    cmp e2_Active, 1
    jne SkipE2Clear
    mov al, e2_OldX
    cmp al, e2_X
    jne ClearE2
    mov al, e2_OldY
    cmp al, e2_Y
    je SkipE2Clear
    ClearE2:
        mov dh, e2_OldY
        mov dl, e2_OldX
        call RestoreBackground
    SkipE2Clear:

    ; Clear old enemy 3
    cmp e3_Active, 1
    jne SkipE3Clear
    mov al, e3_OldX
    cmp al, e3_X
    jne ClearE3
    mov al, e3_OldY
    cmp al, e3_Y
    je SkipE3Clear
    ClearE3:
        mov dh, e3_OldY
        mov dl, e3_OldX
        call RestoreBackground
    SkipE3Clear:

    ; Clear old enemy 4
    cmp e4_Active, 1
    jne SkipE4Clear
    mov al, e4_OldX
    cmp al, e4_X
    jne ClearE4
    mov al, e4_OldY
    cmp al, e4_Y
    je SkipE4Clear
    ClearE4:
        mov dh, e4_OldY
        mov dl, e4_OldX
        call RestoreBackground
    SkipE4Clear:

    ; Clear old enemy 5
    cmp e5_Active, 1
    jne SkipE5Clear
    mov al, e5_OldX
    cmp al, e5_X
    jne ClearE5
    mov al, e5_OldY
    cmp al, e5_Y
    je SkipE5Clear
    ClearE5:
        mov dh, e5_OldY
        mov dl, e5_OldX
        call RestoreBackground
    SkipE5Clear:

    ; Clear old enemy 6
    cmp e6_Active, 1
    jne SkipE6Clear
    mov al, e6_OldX
    cmp al, e6_X
    jne ClearE6
    mov al, e6_OldY
    cmp al, e6_Y
    je SkipE6Clear
    ClearE6:
        mov dh, e6_OldY
        mov dl, e6_OldX
        call RestoreBackground
    SkipE6Clear:

    ; Clear old enemy 7
    cmp e7_Active, 1
    jne SkipE7Clear
    mov al, e7_OldX
    cmp al, e7_X
    jne ClearE7
    mov al, e7_OldY
    cmp al, e7_Y
    je SkipE7Clear
    ClearE7:
        mov dh, e7_OldY
        mov dl, e7_OldX
        call RestoreBackground
    SkipE7Clear:

    ; Clear old enemy 8
    cmp e8_Active, 1
    jne SkipE8Clear
    mov al, e8_OldX
    cmp al, e8_X
    jne ClearE8
    mov al, e8_OldY
    cmp al, e8_Y
    je SkipE8Clear
    ClearE8:
        mov dh, e8_OldY
        mov dl, e8_OldX
        call RestoreBackground
    SkipE8Clear:

    ; Clear old fireball
    cmp fireActive, 0
    je SkipFireClear
    mov al, oldFireX
    cmp al, fireX
    jne ClearFire
    mov al, oldFireY
    cmp al, fireY
    je SkipFireClear
    ClearFire:
        mov dh, oldFireY
        mov dl, oldFireX
        call RestoreBackground
    SkipFireClear:

    ; Check for coin collection
    call CheckCoinCollection

    ; Check for enemy collision (AFTER clearing old positions)
    call CheckEnemyCollision

    ; Draw Mario at new position
    mov dh, marioY
    mov dl, marioX
    call Gotoxy
    mov eax, COLOR_MARIO
    call SetTextColor
    mov al, CHAR_MARIO
    call WriteChar

    ; Draw Enemy 1 (Ground enemy - G)
    cmp e1_Active, 1
    jne SkipE1Draw
    mov dh, e1_Y
    mov dl, e1_X
    call Gotoxy
    mov eax, COLOR_GROUND_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_GROUND_ENEMY
    call WriteChar
    SkipE1Draw:

    ; Draw Enemy 2 (Ground enemy - G)
    cmp e2_Active, 1
    jne SkipE2Draw
    mov dh, e2_Y
    mov dl, e2_X
    call Gotoxy
    mov eax, COLOR_GROUND_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_GROUND_ENEMY
    call WriteChar
    SkipE2Draw:

    ; Draw Enemy 3 (Ground enemy - G)
    cmp e3_Active, 1
    jne SkipE3Draw
    mov dh, e3_Y
    mov dl, e3_X
    call Gotoxy
    mov eax, COLOR_GROUND_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_GROUND_ENEMY
    call WriteChar
    SkipE3Draw:

    ; Draw Enemy 4 (Air horizontal - V)
    cmp e4_Active, 1
    jne SkipE4Draw
    mov dh, e4_Y
    mov dl, e4_X
    call Gotoxy
    mov eax, COLOR_AIR_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_AIR_ENEMY
    call WriteChar
    SkipE4Draw:

    ; Draw Enemy 5 (Flying vertical - K)
    cmp e5_Active, 1
    jne SkipE5Draw
    mov dh, e5_Y
    mov dl, e5_X
    call Gotoxy
    mov eax, COLOR_FLYING_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_FLYING_ENEMY
    call WriteChar
    SkipE5Draw:

    ; Draw Enemy 6 (Flying vertical - K)
    cmp e6_Active, 1
    jne SkipE6Draw
    mov dh, e6_Y
    mov dl, e6_X
    call Gotoxy
    mov eax, COLOR_FLYING_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_FLYING_ENEMY
    call WriteChar
    SkipE6Draw:

    ; Draw Enemy 7 (Ground enemy - G)
    cmp e7_Active, 1
    jne SkipE7Draw
    mov dh, e7_Y
    mov dl, e7_X
    call Gotoxy
    mov eax, COLOR_GROUND_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_GROUND_ENEMY
    call WriteChar
    SkipE7Draw:

    ; Draw Enemy 8 (Ground enemy - G)
    cmp e8_Active, 1
    jne SkipE8Draw
    mov dh, e8_Y
    mov dl, e8_X
    call Gotoxy
    mov eax, COLOR_GROUND_ENEMY_COLOR
    call SetTextColor
    mov al, CHAR_GROUND_ENEMY
    call WriteChar
    SkipE8Draw:

    ; Draw Fireball
    cmp fireActive, 1
    jne SkipFireDraw
    mov dh, fireY
    mov dl, fireX
    call Gotoxy
    mov eax, COLOR_FIRE
    call SetTextColor
    mov al, CHAR_FIRE
    call WriteChar
    SkipFireDraw:

    ; Update old positions
    mov al, marioX
    mov oldX, al
    mov al, marioY
    mov oldY, al

    mov al, e1_X
    mov e1_OldX, al
    mov al, e1_Y
    mov e1_OldY, al

    mov al, e2_X
    mov e2_OldX, al
    mov al, e2_Y
    mov e2_OldY, al

    mov al, e3_X
    mov e3_OldX, al
    mov al, e3_Y
    mov e3_OldY, al

    mov al, e4_X
    mov e4_OldX, al
    mov al, e4_Y
    mov e4_OldY, al

    mov al, e5_X
    mov e5_OldX, al
    mov al, e5_Y
    mov e5_OldY, al

    mov al, e6_X
    mov e6_OldX, al
    mov al, e6_Y
    mov e6_OldY, al

    mov al, e7_X
    mov e7_OldX, al
    mov al, e7_Y
    mov e7_OldY, al

    mov al, e8_X
    mov e8_OldX, al
    mov al, e8_Y
    mov e8_OldY, al

    mov al, fireX
    mov oldFireX, al
    mov al, fireY
    mov oldFireY, al

    ret
Game_RenderAll ENDP

; =================================================================================
; DRAWING PROCEDURES
; =================================================================================

DrawMainMenu PROC
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr

    ; Title only - NO PLAYER NAME
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov eax, COLOR_TITLE
    call SetTextColor
    mov edx, OFFSET strTitle1
    call WriteString

    mov dh, 6
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET strTitle2
    call WriteString

    mov dh, 7
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET strRollNo
    call WriteString

    ; REMOVED: Display player name section
    
    ; Menu Options
    mov eax, white + (blue * 16)
    call SetTextColor

    mov dh, 12
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strOpt1
    call WriteString

    mov dh, 14
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strOpt2
    call WriteString

    mov dh, 16
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strOpt3
    call WriteString

    mov dh, 18
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strOpt4
    call WriteString

    ret
DrawMainMenu ENDP

DrawInstructionsPage PROC
    mov eax, COLOR_SKY
    call SetTextColor
    call Clrscr

    mov dh, 5
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strInstTitle
    call WriteString

    mov dh, 8
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst1
    call WriteString

    mov dh, 10
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst2
    call WriteString

    mov dh, 12
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst3
    call WriteString

    mov dh, 14
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst4
    call WriteString

    mov dh, 16
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst5
    call WriteString

    mov dh, 18
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst6
    call WriteString

    mov dh, 20
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst7
    call WriteString

    mov dh, 22
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strInst8
    call WriteString

    mov dh, 25
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strInstExit
    call WriteString

    ret
DrawInstructionsPage ENDP

DrawLevelMap PROC
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, 0                  ; Row counter
    mov ebx, OFFSET levelMap    ; Pointer to map data

    DrawRowLoop:
        cmp ecx, 21
        jge DrawMapDone

        ; Position cursor at start of row
        mov dh, cl
        add dh, 3               ; Start at row 3
        mov dl, 0
        call Gotoxy

        push ecx
        mov ecx, 0              ; Column counter

        DrawColLoop:
            cmp ecx, 80
            jge NextRow

            mov al, [ebx]
            inc ebx

            ; Set color based on character
            cmp al, ' '
            je DrawSpace
            cmp al, '#'
            je DrawGround
            cmp al, 'P'
            je DrawPipe
            cmp al, '?'
            je DrawQBlock
            cmp al, 'Q'
            je DrawQBlock
            cmp al, 'C'
            je DrawCoin
            jmp DrawDefault

            DrawSpace:
                mov eax, COLOR_SKY
                call SetTextColor
                mov al, ' '
                call WriteChar
                jmp NextCol

            DrawGround:
                mov eax, COLOR_GROUND
                call SetTextColor
                mov al, CHAR_SOLID
                call WriteChar
                jmp NextCol

            DrawPipe:
                mov eax, COLOR_PIPE
                call SetTextColor
                mov al, CHAR_PIPE
                call WriteChar
                jmp NextCol

            DrawQBlock:
                mov eax, COLOR_QBLOCK
                call SetTextColor
                mov al, '?'
                call WriteChar
                jmp NextCol

            DrawCoin:
                mov eax, COLOR_COIN
                call SetTextColor
                mov al, CHAR_COIN
                call WriteChar
                jmp NextCol

            DrawDefault:
                mov eax, COLOR_SKY
                call SetTextColor
                call WriteChar

            NextCol:
            inc ecx
            jmp DrawColLoop

        NextRow:
        pop ecx
        inc ecx
        jmp DrawRowLoop

    DrawMapDone:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawLevelMap ENDP

DrawHUD_Static PROC
    ; Draw HUD header
    mov dh, 0
    mov dl, 0
    call Gotoxy
    mov eax, COLOR_HUD
    call SetTextColor
    mov edx, OFFSET strHUD_Header
    call WriteString

    ; Draw level info
    mov dh, 1
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET strHUD_Level
    call WriteString

    ret
DrawHUD_Static ENDP

DrawHUD_Dynamic PROC
    ; Draw Score
    mov dh, 1
    mov dl, 1
    call Gotoxy
    mov eax, COLOR_HUD
    call SetTextColor
    mov eax, score
    call WriteDec

    ; Draw Coins
    mov dh, 1
    mov dl, 23
    call Gotoxy
    mov eax, coins
    call WriteDec

    ; Draw Time
    mov dh, 1
    mov dl, 62
    call Gotoxy
    mov eax, gameTime
    call WriteDec

    ; Draw Lives
    mov dh, 2
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET strLivesText
    call WriteString
    movzx eax, lives
    call WriteDec

    ; Draw Level
    mov dh, 2
    mov dl, 70
    call Gotoxy
    mov al, 'L'
    call WriteChar
    mov al, 'V'
    call WriteChar
    mov al, 'L'
    call WriteChar
    mov al, ':'
    call WriteChar
    movzx eax, currentLevel
    call WriteDec

    ret
DrawHUD_Dynamic ENDP

; =================================================================================
; HELPER PROCEDURES
; =================================================================================

RestoreBackground PROC
    ; DH = Y, DL = X
    push eax
    push ebx
    push ecx
    push edx

    call Gotoxy

    ; Calculate map index: (Y-3) * 80 + X
    movzx ecx, dh
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, dl
    add eax, ecx

    ; Get character from map
    mov ebx, OFFSET levelMap
    add ebx, eax
    mov al, [ebx]

    ; Draw based on character type
    cmp al, ' '
    je RestSpace
    cmp al, '#'
    je RestGround
    cmp al, 'P'
    je RestPipe
    cmp al, '?'
    je RestQBlock
    cmp al, 'Q'
    je RestQBlock
    cmp al, 'C'
    je RestCoin
    jmp RestDefault

    RestSpace:
        mov eax, COLOR_SKY
        call SetTextColor
        mov al, ' '
        call WriteChar
        jmp RestDone

    RestGround:
        mov eax, COLOR_GROUND
        call SetTextColor
        mov al, CHAR_SOLID
        call WriteChar
        jmp RestDone

    RestPipe:
        mov eax, COLOR_PIPE
        call SetTextColor
        mov al, CHAR_PIPE
        call WriteChar
        jmp RestDone

    RestQBlock:
        mov eax, COLOR_QBLOCK
        call SetTextColor
        mov al, '?'
        call WriteChar
        jmp RestDone

    RestCoin:
        mov eax, COLOR_COIN
        call SetTextColor
        mov al, CHAR_COIN
        call WriteChar
        jmp RestDone

    RestDefault:
        mov eax, COLOR_SKY
        call SetTextColor
        call WriteChar

    RestDone:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
RestoreBackground ENDP

GetMapCharAtBelow PROC
    ; Returns character below Mario in AL
    movzx ecx, marioY
    inc ecx
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, marioX
    add eax, ecx
    mov ebx, OFFSET levelMap
    add ebx, eax
    mov al, [ebx]
    ret
GetMapCharAtBelow ENDP

GetMapCharAtNextLeft PROC
    ; Returns character to left of Mario in AL
    movzx ecx, marioY
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, marioX
    dec ecx
    add eax, ecx
    mov ebx, OFFSET levelMap
    add ebx, eax
    mov al, [ebx]
    ret
GetMapCharAtNextLeft ENDP

GetMapCharAtNextRight PROC
    ; Returns character to right of Mario in AL
    movzx ecx, marioY
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, marioX
    inc ecx
    add eax, ecx
    mov ebx, OFFSET levelMap
    add ebx, eax
    mov al, [ebx]
    ret
GetMapCharAtNextRight ENDP

GetMapCharAtFire PROC
    ; Returns character at fireball position in AL
    movzx ecx, fireY
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, fireX
    add eax, ecx
    mov ebx, OFFSET levelMap
    add ebx, eax
    mov al, [ebx]
    ret
GetMapCharAtFire ENDP

CheckCoinCollection PROC
    ; Check if Mario is on a coin
    movzx ecx, marioY
    sub ecx, 3
    mov eax, 80
    mul ecx
    movzx ecx, marioX
    add eax, ecx
    mov ebx, OFFSET levelMap
    
    add ebx, eax
    cmp BYTE PTR [ebx], 'C'
    jne NoCoin
    
    ; Collect coin
    mov BYTE PTR [ebx], ' '
    inc coins
    add score, 50
    call PlayCoinSound
    
    NoCoin:
    ret
CheckCoinCollection ENDP

Game_UpdateTimer PROC
    inc frameCounter
    cmp frameCounter, 60
    jl NoTimeUpdate
    
    mov frameCounter, 0
    cmp gameTime, 0
    jle TimeUp
    dec gameTime
    
    NoTimeUpdate:
    ret
    
    TimeUp:
    mov currentState, STATE_GAMEOVER
    ret
Game_UpdateTimer ENDP



END main