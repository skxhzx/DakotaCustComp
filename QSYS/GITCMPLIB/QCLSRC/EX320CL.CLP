/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EX320CL   Single Order Selection exception report.               */
/*  15 November 2002                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*    11/15/02  MLB  4.16                                            */
/*      - Created.                                                   */
/*    01/06/12  RH   6.40a                                           */
/*      - Fix: add SKPUPC errro code                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EX320CL:    PGM        PARM(&WHSE &WHDP &SECTN &RETURN &JOBQ &DEV +
                             &FORM &FMDT &TODT &STAT)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX320CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX320)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ITMEXCP)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(EX325PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Single Order Selection exception report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Single Order Selection +
                          exception report')

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
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SECTN &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &STAT)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &SECTN +
                          &RETURN &DEV &FORM &FMDT &TODT &STAT)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('EXWHSE *EQ ' *CAT &WHSE)

             IF (&WHDP *NE '*ALL') THEN(DO)
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXWHDP *EQ +
                            ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF (&SECTN = 'P') THEN(DO)
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXSTYP +
                            *EQ' *BCAT &QUOTE *CAT 'P' *CAT &QUOTE)
             ENDDO

             IF (&SECTN = 'F') THEN(DO)
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXSTYP +
                            *EQ' *BCAT &QUOTE *CAT 'F' *CAT &QUOTE)
             ENDDO

             IF (&STAT = '1') THEN(DO) /* Open exceptions */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXESTA +
                            *EQ' *BCAT &QUOTE *CAT '1 ' *CAT &QUOTE)
             ENDDO

             IF (&STAT = '4') THEN(DO) /* Cleared exceptions */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXESTA +
                            *EQ' *BCAT &QUOTE *CAT '4 ' *CAT &QUOTE)
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('EXGDTE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('EXGDTE  +
                          *LE ' *CAT &TODT))

/*  Select only Single Order Selection records. */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT (' *and exerid + */
/*                        *EQ "PCKGTAV" '))                               */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(EXERID +
                          *EQ' *BCAT &QUOTE *CAT "PCKGTAV" *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXERID +
                          *EQ' *BCAT &QUOTE *CAT "SKPUPC" *CAT &QUOTE +
                          *BCAT ')')

 PRINT:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(EX325) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(EX325) QRYSLT(&QRYSLT) +
                          KEYFLD((ITMEXCP/EXWHSE) (ITMEXCP/EXESTA) +
                          (ITMEXCP/EXWHDP) (ITMEXCP/EXSTYP) +
                          (ITMEXCP/EXITEM)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(EX325)  PARM(&FMDT &TODT)

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
