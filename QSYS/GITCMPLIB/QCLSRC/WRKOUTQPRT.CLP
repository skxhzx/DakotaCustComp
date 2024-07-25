             PGM        PARM(&OUTQLIB &OUTQNAME &TGTOUTQLIB &TGTOUTQ +
                          &WRKFILE &ENDFILE)
           DCL        VAR(&OUTQNAME) TYPE(*CHAR) LEN(10)
           DCL        VAR(&OUTQLIB) TYPE(*CHAR) LEN(10)
           DCL        VAR(&TGTOUTQ) TYPE(*CHAR) LEN(10)
           DCL        VAR(&TGTOUTQLIB) TYPE(*CHAR) LEN(10)
           DCL        VAR(&WRKFILE) TYPE(*CHAR) LEN(10)
           DCL        VAR(&ENDFILE) TYPE(*CHAR) LEN(10)

           DCL        VAR(&COUNTER) TYPE(*DEC) LEN(15 5) VALUE(1)
           DCL        VAR(&WORK) TYPE(*CHAR) LEN(1) VALUE('0')
           DCL        VAR(&WORK1) TYPE(*CHAR) LEN(1) VALUE('0')
           DCL        VAR(&ZERO) TYPE(*CHAR) LEN(1) VALUE('0')
           DCL        VAR(&COPIES1) TYPE(*CHAR) LEN(5) VALUE(' ')
           DCL        VAR(&FILNUM1) TYPE(*CHAR) LEN(6) VALUE(' ')


           DCLF       FILE(WRKOUTQPRT)

           OVRDBF     FILE(WRKOUTQPRT) TOFILE(&WRKFILE) +
           MBR(*FIRST)

           WRKOUTQ    OUTQ(&OUTQLIB/&OUTQNAME) OUTPUT(*PRINT)

           CPYSPLF    FILE(QPRTSPLQ) TOFILE(WRKOUTQPRT) +
           SPLNBR(*LAST)

           GETIT:
           RCVF
           MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(ENDPGM))
           CHGVAR     VAR(&COPIES1) VALUE(' ')

           CHGVAR     VAR(&FILNUM1) VALUE(' ')
           CHGVAR     VAR(&COUNTER) VALUE(0)
           COUNT:

           IF         COND(&COUNTER *LT 6) THEN(DO)
           CHGVAR     VAR(&COUNTER) VALUE(&COUNTER + 1)

           IF         COND(&COUNTER *LT 6) THEN(DO)
           CHGVAR     VAR(&WORK) VALUE(%SST(&COPIES &COUNTER 1))

           IF         COND(&WORK *EQ ' ') THEN(CHGVAR +
           VAR(&COPIES1) VALUE(&COPIES1 *TCAT &ZERO))
           ELSE       CMD(CHGVAR VAR(&COPIES1) VALUE(&COPIES1 +
                *TCAT &WORK))
           ENDDO

           CHGVAR     VAR(&WORK1) VALUE(%SST(&FILNUM &COUNTER 1))
           IF         COND(&WORK1 *EQ ' ') THEN(CHGVAR +
           VAR(&FILNUM1) VALUE(&FILNUM1 *TCAT &ZERO))
           ELSE       CMD(CHGVAR VAR(&FILNUM1) VALUE(&FILNUM1 +
                             *TCAT &WORK1))
           GOTO       CMDLBL(COUNT)

           ENDDO


           IF         COND(&COPIES1 *LE '00000') THEN(GOTO +
                       CMDLBL(GETIT))

          IF         COND(&COPIES1 *GE '99999') THEN(GOTO +
                        CMDLBL(GETIT))

          IF         COND(&STATUS *EQ 'RDY') THEN(DO)
          CHGSPLFA   FILE(&SPLFIL) JOB(&JOBNUM/&USER/&JOB) +
                       SPLNBR(&FILNUM1) OUTQ(&TGTOUTQLIB/&TGTOUTQ)
          ENDDO

          GOTO       CMDLBL(GETIT)

          ENDPGM:

          DLTOVR     FILE(WRKOUTQPRT)

          DLTF       FILE(&WRKFILE)
          DLTF       FILE(&ENDFILE)
          ENDPGM
