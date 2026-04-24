; Welcome to compiler tutorial #2

; Command Line Parameters:
; 1. To get a full listof command line parameters, run the compiler
;    with the oh flag
; 2. For this tutorial, we will change the DEPTH of the mif file to 512
; 3. We will also specify the name of the output file

; Handling Errors:
; 1. The compiler will handle most errors without crashing
  2. Even if I forget a Semicolon, the compiler will figure output
     that these lines should have been comments
; 3. Any errors in the assembly code will be printed out to the terminal
;    when the compiler is run
; 4. If you forget to prepend an instruction with # or r, the compiler 
;    will try its best to infer what you meant to do
; 5. Even if there are errors in your assembly code, the compiler will 
;    generate the mif file anyways, along with a warning. Just in case
;    what you did was intentional. Though be warned, it likely will not
;    function as you thought it would.



; Let's see some code

CLR R0      ; R0 <- 0
SR0 1       ; R0 <- 1
MOV R3,R0   ; R3 <- 1 (define delay to be 1/100 of a second)
SR0 0       ; R0 <- 0
SRH0 3      ; R0 <- 30(hex)=48(dec)
MOV R1,R0   ; R1 <- 30(hex)=48(dec)
CLR R0      ; R0 <- 0 (set-up loop iterator)
SR0 10      ; R0 <- 10(decimal) - (loop repeats 10 times)
MOVR R1     ; Move the motor 48 steps (1 full turn) clockwise
SUBI R0,1   ; R0 <- R0-1
BRZ 2       ; Branch 2 instructions forward if R0 has reached 0
BR -3       ; Branch 3 locations backwards
PAUSE       ; pause 1/100 of a second
...         ; 8 times for a total of 8/100 of a second
SR0 0       ; R0 <- 0
SRH0 13     ; R0 <- D0(hex)=-48(dec)
MOV R1,R0   ; R1 <- D0(hex)=-48(dec)
CLR R0      ; R0 <- 0
SR0 10      ; R0 <- 10(decimal)
MOVR R1     ; Move the motor 48 steps (1 full turn) counter-clockwise
SUBI R0,1   ; R0 <- R0-1
BRZ 2       ; Branch 2 instructions forward if R0 has reached 0
BR -3       ; Branch 3 locations backwards
PAUSE       ; pause 1/100 of a second
...         ; 8 times for a total of 8/100 of a second
MOVRHS R1   ; Move the motor 48 half-steps (1/2 a turn) counter-clockwise
BR 0        ; infinite loop (branches to PC+0, i.e., itself)



; To Compile Me:
; python compiler.py compiler_tut_02.s -o compiler_tutorial_002 -w 512