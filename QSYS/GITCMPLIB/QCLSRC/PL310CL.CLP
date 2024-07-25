/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PL310CL   Pallet utilization report by length                    */
/*  12 April, 1996                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*-------------------------------------------------------------------*/

 PL310CL:    PGM        PARM(&PCODE &PHANGA &PFLENA &PTLENA &JOBQ +
                          &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PL310CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PL310)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PL311)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PACKAGE)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(PL311PR)
  /* Informational messages */


             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Pallet utilization by +
                          length')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Pallet utilization by +
                          length')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCODE)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PHANG)      TYPE(*DEC)  LEN(3 2)
             DCL        VAR(&PFLEN)      TYPE(*DEC)  LEN(5 2)
             DCL        VAR(&PTLEN)      TYPE(*DEC)  LEN(5 2)
             DCL        VAR(&PHANGA)     TYPE(*CHAR) LEN(3)
             DCL        VAR(&PFLENA)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&PTLENA)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

/*           MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT)) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PCODE &PHANG &PFLEN &PTLEN +
                          &JOBQ &RETURN &DEV &FORM)

             CHGVAR     VAR(&PHANGA) VALUE(&PHANG)
             CHGVAR     VAR(&PFLENA) VALUE(&PFLEN)
             CHGVAR     VAR(&PTLENA) VALUE(&PTLEN)


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PCODE &PHANGA +
                          &PFLENA &PTLENA &JOBQ &RETURN &DEV &FORM)) +
                          JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:
   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('(PKPAL *EQ' *BCAT &QUOTE +
                          *CAT &PCODE *CAT &QUOTE *CAT ')')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(PKHANG *EQ +
                          ' *CAT &PHANGA *CAT ')')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                          '((PKLEN=%RANGE(' *CAT +
                          &PFLENA *BCAT &PTLENA *CAT ')))')

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(PL311) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(PL311) QRYSLT(&QRYSLT) +
                          KEYFLD((&FILE/PKPAL) (&FILE/PKHANG) +
                          (&FILE/PKLEN *ASCEND)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)



             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)



   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(PL311)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
