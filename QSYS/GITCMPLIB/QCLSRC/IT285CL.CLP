/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT285CL   RF Replenishment exception report.                     */
/*  23 April, 1997                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*    09/05/00  MLB  4.14a                                           */
/*      - Change program to allow selection of open and closed       */
/*        exceptions. Added &STAT to end of PGM, SBMJOB parms.       */
/*      - Changed sort of OPNQRYF, added EXESTA right after          */
/*        warehouse to sort all open, closed exceptions.             */
/*      - Removed selection of just REPL tasks from query selection. */
/*    02/06/01  RH   4.15a                                           */
/*      - FIX -  Add &JOBQ to Parms at start of CL.                  */
/*                                                                   */
/*    10/03/01  DAS  4.16                                            */
/*      - Revised to only select records with EXTASK = 'REPL'        */
/*    10/03/02  RH   4.16a                                           */
/*      - FIX - Add &JOBQ to SBMJOB command.                         */
/*    05/20/03  RH   4.17a                                           */
/*      - FIX - Add selection of REPL, REPLTF, REPLBK, TFRMOV        */
/*    12/11/09  GJA  6.10a                                           */
/*      - Revised to add selection LCNS                              */
/*    07/13/10  MLB  6.10b                                           */
/*      - Fix: Revised program to correct problem with &QRYSLT       */
/*        string build error.                                        */
/*    04/30/16  RH   6.40a  (07/02/10  RH  5.30 missed)              */
/*      - FIX - Add selection of VERIFY                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT285CL:    PGM        PARM(&WHSE &WHDP &SECTN &RETURN &JOBQ &DEV +
                             &FORM &FMDT &TODT &STAT)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT285CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT285)

  /* Report program and printer file name. */

/*           DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)  */
             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ITMEXCP)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IT286PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Replenishment exception report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Replenishment exception report')

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
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1) /* (4.14a) */

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
             SBMJOB   CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &SECTN +
                      &RETURN &JOBQ &DEV &FORM &FMDT &TODT &STAT)) JOB(&SBMPGM)
             GOTO     CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('EXWHSE *EQ ' *CAT &WHSE)


   /*        CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     (4.14a) */
   /*        CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXTASK +   (4.14a) */
   /*                     *EQ' *BCAT &QUOTE *CAT 'REPL' *CAT &QUOTE) (4.14a) */
   /* 4.17a follows */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
/*           CHGVAR     VAR(&QRYSLT) VALUE('(&QRYSLT *BCAT +
                          ''((EXTASK *EQ "REPL")'' *BCAT ''*OR'' +
                          *BCAT ''(EXTASK *EQ "REPLTF")'' *BCAT +
                          ''*OR'' *BCAT ''(EXTASK *EQ "VERIFY")'' +
                          ''*OR'' *BCAT ''(EXTASK *EQ "REPLBK")'' +
                          *BCAT ''*OR'' *BCAT ''(EXTASK *EQ +
                          "TFRMOV") *BCAT ''*OR'' *BCAT ''(EXTASK +
                          *EQ "LCNS" *AND (EXTDIS *EQ "LT105" *OR +
                          EXTDIS *EQ "IT276")))'')')              /* (610bD)*/
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                          '((EXTASK *EQ "REPL")'   *BCAT '*OR' *BCAT +
                           '(EXTASK *EQ "REPLTF")' *BCAT '*OR' *BCAT +
                           '(EXTASK *EQ "VERIFY")' *BCAT '*OR' *BCAT +
                           '(EXTASK *EQ "REPLBK")' *BCAT '*OR' *BCAT +
                           '(EXTASK *EQ "TFRMOV")' *BCAT '*OR' *BCAT +
                           '(EXTASK *EQ "LCNS")'   *BCAT '*AND' *BCAT +
                           '(EXTDIS *EQ "LT105" *OR EXTDIS *EQ "IT276"))') +
                                                                  /* (610bM)*/
   /* 4.17a ends    */

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

/*  New code added starting here. 4.14a                                       */
             IF (&STAT = '1') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXESTA +
                          *EQ' *BCAT &QUOTE *CAT '1 ' *CAT &QUOTE)
             ENDDO

             IF (&STAT = '4') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'EXESTA +
                          *EQ' *BCAT &QUOTE *CAT '4 ' *CAT &QUOTE)
             ENDDO
/*  New code added ending here. 4.14a                                         */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('EXGDTE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('EXGDTE  +
                          *LE ' *CAT &TODT))

 PRINT:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(IT286) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(IT286) QRYSLT(&QRYSLT) +
                          KEYFLD((ITMEXCP/EXWHSE) (ITMEXCP/EXESTA) +
                          (ITMEXCP/EXWHDP) (ITMEXCP/EXSTYP) +
                          (ITMEXCP/EXITEM)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(IT286)  PARM(&FMDT &TODT)

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
