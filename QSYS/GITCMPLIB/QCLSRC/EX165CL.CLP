/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EX165CL   RF Selection exceptions report                         */
/*  23 March 2006                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    03/23/06  RH   5.00                                            */
/*      - Created using EX155                                        */
/*    08/08/06  RH   5.10a                                           */
/*      - Enh: Add time range                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EX165CL:    PGM        PARM(&WHSE &ITEM &RETURN &JOBQ &DEV &FORM +
                             &FMDT &TODT &STAT &BTHH &BTMM &BTSS +
                             &ETHH &ETMM &ETSS)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX165CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX165)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(VOEXCP)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(EX166PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('RF Selection exception report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing RF Selction exception report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BTHH)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&BTMM)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&BTSS)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&DASH )      TYPE(*CHAR) LEN(1) VALUE('-')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&ETHH)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&ETMM)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&ETSS)       TYPE(*CHAR) LEN(2)
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
             DCL        VAR(&FMDTC)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&FMDTS)      TYPE(*CHAR) LEN(19)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODTC)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&TODTS)      TYPE(*CHAR) LEN(19)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1) /* (4.14a) */

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &ITEM &RETURN &JOBQ +
                          &DEV &FORM &FMDT &TODT &STAT &BTHH &BTMM +
                          &BTSS &ETHH &ETMM &ETSS)

/*  Convert YYMMDD parm date to YYYY-MM-DD ISO date to compare and */
/*  select using datestamp field.                                  */
             CVTDAT     DATE(&FMDT) TOVAR(&FMDTC) FROMFMT(*YYMD) +
                          TOFMT(*ISO)
             CVTDAT     DATE(&TODT) TOVAR(&TODTC) FROMFMT(*YYMD) +
                          TOFMT(*ISO)
/*  Add time to YYYY-MM-DD ISO date for datestamp field */
             CHGVAR     VAR(&FMDTS) VALUE(&FMDTC *CAT '-' *CAT &BTHH +
                          *CAT '.' *CAT &BTMM *CAT '.' *CAT &BTSS)
             CHGVAR     VAR(&TODTS) VALUE(&TODTC *CAT '-' *CAT &ETHH +
                          *CAT '.' *CAT &ETMM *CAT '.' *CAT &ETSS)
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

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SXWHSE *EQ ' *CAT &WHSE)

             IF (&ITEM *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SXITEM *EQ +
                          ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)
             ENDDO


/*  New code added starting here.                                             */
             IF (&STAT = '1') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SXESTA +
                          *EQ' *BCAT &QUOTE *CAT '1 ' *CAT &QUOTE)
             ENDDO

             IF (&STAT = '4') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SXESTA +
                          *EQ' *BCAT &QUOTE *CAT '4 ' *CAT &QUOTE)
             ENDDO

/*  %DATE will extract YYYY-MM-DD from datestamp field for compare.           */
/*  5.10 ADDED TIME RANGE, NO LONGER NEED TO EXTRACT DATE.                    */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('%DATE(SXGDTS) +   */
/*                        *GE ' *CAT &QUOTE *CAT &FMDTC *CAT &QUOTE))        */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SXGDTS +
                          *GE ' *CAT &QUOTE *CAT &FMDTS *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('%DATE(SXGDTS) +   */
/*                        *LE ' *CAT &QUOTE *CAT &TODTC *CAT &QUOTE))        */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SXGDTS +
                          *LE ' *CAT &QUOTE *CAT &TODTS *CAT &QUOTE)

 PRINT:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                          KEYFLD((VOEXCP/SXWHSE) (VOEXCP/SXESTA) +
                          (VOEXCP/SXITEM)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(EX166)  PARM(&FMDT &TODT)

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
