/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR780CL   Substitute Item Report                                 */
/*  08 December, 2010                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    12/08/10  RH   5.30                                            */
/*      - Created using HC320                                        */
/*    09/16/13  LMC  6.50a                                           */
/*      - Added Time selection.                                      */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 /* OR780CL:    PGM        PARM(&WHSE &STS &FRMDTE &TODTE &RETURN +
                          &DEV &FORM)   650aD */
 OR780CL:    PGM        PARM(&WHSE &STS &FRMDTE &TODTE &RETURN &DEV +
                          &FORM &FRMTIM &TOTIM) /* 650aM */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR780CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR780)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RTEHED)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR781PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Substitute item report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Substitute item report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BLANK)      TYPE(*CHAR) LEN(1) VALUE(' ')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FRMDTE)     TYPE(*CHAR) LEN(8)       /* (530 A) */
             DCL        VAR(&TODTE)      TYPE(*CHAR) LEN(8)       /* (530 A) */
             DCL        VAR(&FRMTIM)     TYPE(*CHAR) LEN(6)       /* (650aA) */
             DCL        VAR(&TOTIM)      TYPE(*CHAR) LEN(6)       /* (650aA) */
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&STS)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

/*           CALL       PGM(&OPTPGM) PARM(&WHSE &STS &FRMDTE &TODTE +
                          &RETURN &JOBQ &DEV &FORM) 650aD */
             CALL       PGM(&OPTPGM) PARM(&WHSE &STS &FRMDTE &TODTE +
                          &RETURN &JOBQ &DEV &FORM &FRMTIM &TOTIM) +
                          /* 650aM */

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
/*             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &STS &FRMDTE +
                            &TODTE &RETURN &DEV &FORM)) JOB(&SBMPGM)  650aD */
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &STS +
                          &FRMDTE &TODTE &RETURN &DEV &FORM &FRMTIM +
                          &TOTIM)) JOB(&SBMPGM) /* 650aA */

             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('RHWHSE *EQ ' *CAT &WHSE)

             IF (&STS *NE ' ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RHSTAT *EQ +
                          ' *BCAT &QUOTE *CAT &STS *CAT &QUOTE)
             ENDDO

/*         Select Route based on date range.                     */
             IF (&FRMDTE *NE '0') THEN(DO)
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND') /*(530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('RHSTSD +
                            *GE ' *CAT &FRMDTE))                  /* (530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('RHSTST +
                            *GE ' *CAT &FRMTIM))                  /* (650aA) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND') /*(530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('RHSTSD +
                            *LE ' *CAT &TODTE))                   /* (530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('RHSTST +
                            *LE ' *CAT &TOTIM))                   /* (650aA) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND') /*(530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('ODOITM +
                            *NE " "'))                  /* (5          30 A) */
             ENDDO                                                /* (530 A) */

 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR781) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((RTEHED) (ORDH) (ORDD)) FORMAT(OR781) +
                          QRYSLT(&QRYSLT) KEYFLD((RTEHED/RHWHSE) +
                          (RTEHED/RHSTAT) (RTEHED/RHSTSD) +
                          (RTEHED/RHSTST)) JFLD((RTEHED/RHWHSE +
                          ORDH/OHWHSE) (RTEHED/RHRTID ORDH/OHRTE) +
                          (ORDH/OHWHSE ORDD/ODWHSE) (ORDH/OHORD +
                          ORDD/ODORD)) JDFTVAL(*YES) JORDER(*FILE) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(OR781) PARM(&STS &FRMDTE &TODTE)       /* (30 M) */

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
