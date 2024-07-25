       PGM   PARM()

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&JRN)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FLIB)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WS)         TYPE(*CHAR) LEN(10)

             RTVJOBA    JOB(&WS)

             RTVDTAARA  DTAARA(JRNDTAARA (1 10)) RTNVAR(&JRN)
             IF         COND(&JRN *EQ ' ') THEN(GOTO CMDLBL(ENDNOW))
             RTVDTAARA  DTAARA(JRNDTAARA (11 10)) RTNVAR(&LIB)
             IF         COND(&LIB *EQ ' ') THEN(CHGVAR VAR(&LIB) +
                          VALUE('*LIBL'))

   LIBAGN:
             SNDUSRMSG  MSG('Enter the files library') MSGRPY(&FLIB)
             CHKOBJ     OBJ(QSYS/&FLIB) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             SNDBRKMSG  MSG('Invalid Library entered.  Press enter +
                          and try again.') TOMSGQ(&WS)
             GOTO       CMDLBL(LIBAGN)
             ENDDO

             MONMSG     MSGID(CPF700A)
             STRJRNPF   FILE(&FLIB/DLYHITR &FLIB/DLYHITS &FLIB/LABEL +
                          &FLIB/LABELDO &FLIB/LICACTIVE +
                          &FLIB/LICINFO &FLIB/LICLOG &FLIB/ORDH +
                          &FLIB/ORDD &FLIB/ORRTN &FLIB/PIRITEM +
                          &FLIB/PIRTRAN &FLIB/PIRTRAND +
                          &FLIB/PIRUSER &FLIB/PLTSUM &FLIB/POHHDR +
                          &FLIB/POHDTL &FLIB/RTEHED &FLIB/RTESTP +
                          &FLIB/RUNNER &FLIB/SLOT &FLIB/SLOTDEF +
                          &FLIB/SLOTUSAGE &FLIB/VSLOT &FLIB/WORKLBL +
                          &FLIB/ITEMFLD &FLIB/RTNCODE) +
                          JRN(&LIB/&JRN) IMAGES(*BOTH) +
                          OMTJRNE(*OPNCLO)

  ENDNOW:
             ENDPGM
