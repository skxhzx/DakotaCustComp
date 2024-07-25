/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EX155CL   Catch weight exceptions report                         */
/*  13 September 2004                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    09/13/04  RH   4.17                                            */
/*      - Created using EX125                                        */
/*                                                                   */
/*  Revisions                                                        */
/*    03/24/09  CWM  5.20                                            */
/*      -ENH:  Added code for Report Distribution/Print Over Rides   */
/*  05/12/16  MLB/RH  7.00                                           */
/*    -Fix: Revised $PARM to change length to 136 from 80 to fix     */
/*     data decimal error.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EX155CL:    PGM        PARM(&WHSE &ITEM &RETURN &JOBQ &DEV +
                             &FORM &FMDT &TODT &STAT)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX155CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX155)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(CWEXCP)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(EX156PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Catch weight exception report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Cathc weight exception report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1) /* (4.14a) */

             DCL        VAR(&PARMS)      TYPE(*CHAR) LEN(136)     /* (700 M) */
             DCL        VAR(&PRTCTR)     TYPE(*DEC)  LEN(15 5) VALUE(1)  /*520*/
             DCL        VAR(&CANCEL)     TYPE(*CHAR) LEN(8)              /*520*/
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(1024)           /*520*/
             DCL        VAR(&LEN)       TYPE(*DEC) LEN(15 5) VALUE(1024) /*520*/
             DCL        VAR(&POVR)       TYPE(*CHAR) LEN(1)              /*520*/
             DCL        VAR(&ONETIM)     TYPE(*CHAR) LEN(1)              /*520*/


             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


 START:

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

/*           CALL       PGM(&OPTPGM) PARM(&WHSE &ITEM &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &STAT)       */

             CALL       PGM(&OPTPGM) PARM(&WHSE &ITEM &RETURN +
                          &JOBQ &FMDT &TODT &STAT &POVR)            /* 520 */

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &ITEM +
                          &RETURN &DEV &FORM &FMDT &TODT &STAT)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

/*           OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)        520 D         */

/*  Setup One Time Run Time Print Override  */

             IF (&POVR = 'Y') THEN(DO)                                 /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 1 8)) VALUE('*ADD    ')      /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 9 10)) VALUE(&SBMPGM)        /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 19 10)) VALUE('EX156PR   ')  /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 29 3)) VALUE('000')          /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 32 3)) VALUE(&WHSE)          /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 35 45)) VALUE(' ')           /* 520 */
             CHGVAR VAR(%SUBSTRING(&PARMS 68 1)) VALUE('Y')            /* 520 */
             CALL       PGM(RP152) PARM(&PARMS)                        /* 520 */
             CHGVAR VAR(&CANCEL)  VALUE(%SST(&PARMS 69 8))             /* 520 */
             IF         COND(&CANCEL *EQ '*CANCEL ') THEN(DO)          /* 520 */
             CHGVAR VAR(&CANCEL)  VALUE(' ')                           /* 520 */
             GOTO       CMDLBL(START)                                  /* 520 */
             ENDDO                                                     /* 520 */
             ENDDO                                                     /* 520 */

             DOUNTIL    COND(&PRTCTR *EQ 0)                            /* 520 */
             CALL       PGM(RPT120) PARM(&PRTF &PRTCTR &CMD &ONETIM)   /* 520 */
             IF         COND(&PRTCTR *NE 0) THEN(DO)                   /* 520 */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('CXWHSE *EQ ' *CAT &WHSE)

             IF (&ITEM *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'CXITEM *EQ +
                          ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)
             ENDDO


/*  New code added starting here.                                             */
             IF (&STAT = '1') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'CXESTA +
                          *EQ' *BCAT &QUOTE *CAT '1 ' *CAT &QUOTE)
             ENDDO

             IF (&STAT = '4') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'CXESTA +
                          *EQ' *BCAT &QUOTE *CAT '4 ' *CAT &QUOTE)
             ENDDO


             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('CXGDTE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('CXGDTE  +
                          *LE ' *CAT &TODT))

 PRINT:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                          KEYFLD((CWEXCP/CXWHSE) (CWEXCP/CXESTA) +
                          (CWEXCP/CXITEM)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CHGVAR     VAR(&PRTCTR) VALUE(&PRTCTR + 1)                /* 520 */
             CALL       PGM(QCMDEXC) PARM(&CMD &LEN)                   /* 520 */
             CALL       PGM(EX156) PARM(&FMDT &TODT)                   /* 520 */
             IF         COND(&ONETIM *EQ 'Y') THEN(DO)                 /* 520 */
             CHGVAR     VAR(&PRTCTR) VALUE(0)                          /* 520 */
             ENDDO                                                     /* 520 */
             CLOF       OPNID(&FILE)                                   /* 520 */
             DLTOVR     FILE(&PRTF)                                    /* 520 */
             MONMSG     MSGID(CPF9841)                                 /* 520 */
             ENDDO                                                     /* 520 */
             ENDDO                                                     /* 520 */

 /*          CALL       PGM(EX156)  PARM(&FMDT &TODT)  520 D                  */

 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
