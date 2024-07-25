/* LSTFL - LIST FILE LAYOUTS */
/* CPP IS LSTFLCL */
             CMD        PROMPT('List File Layout(s)')
             PARM       KWD(FILE) TYPE(*NAME) MIN(1) MAX(50) +
                          PROMPT('File name')
             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library name')
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          DFT(*) VALUES(* *PRINT) MAX(1) +
                          PMTCTL(*NONE) PROMPT('Output')
             PARM       KWD(DRAWER) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(2) VALUES(1 2 3) MAX(1) PMTCTL(OUTPUT) +
                          PROMPT('Source drawer')
             PARM       KWD(OUTQ) TYPE(Q2) SNGVAL((*NONE)) MIN(0) +
                          PMTCTL(OUTPUT) PROMPT('Output queue')
 Q2:         QUAL       TYPE(*NAME) LEN(10) DFT(PRT01) MIN(0) +
                          EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) EXPR(*YES) PROMPT('Library +
                          name')
 OUTPUT:     PMTCTL     CTL(OUTPUT) COND((*EQ *PRINT))
