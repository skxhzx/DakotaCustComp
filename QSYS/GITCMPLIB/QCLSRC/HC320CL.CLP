/*-------------------------------------------------------------------*/
/*                                                                   */
/*  HC320CL   History HACCP Report                                   */
/*  23 April, 2008                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    04/23/08  RH   5.20                                            */
/*      - Created using HC310                                        */
/*                                                                   */
/*    01/23/10  MLB  5.30                                            */
/*      - Enh: Revised program to add from/to date range selection   */
/*        to HACCP report.                                           */
/*    09/30/11  RH   6.40                                            */
/*      - Enh: Revised program to add PO Vendor to selection.        */
/*                                                                   */
/*-------------------------------------------------------------------*/

/* HC320CL:    PGM        PARM(&WHSE &PO &RETURN &DEV &FORM)         (530 D) */
/*C320CL:    PGM        PARM(&WHSE &PO &FRMDTE &TODTE &RETURN &DEV + (640 D) */
 HC320CL:    PGM        PARM(&WHSE &PO &FRMDTE &TODTE &VEN &RETURN +
                          &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(HC320CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(HC320)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(POHHACCP)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(HC321PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('HACCP report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing HACCP report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FRMDTE)     TYPE(*CHAR) LEN(8)       /* (530 A) */
             DCL        VAR(&TODTE)      TYPE(*CHAR) LEN(8)       /* (530 A) */
             DCL        VAR(&VEN)        TYPE(*CHAR) LEN(11)      /* (640 A) */
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PO)         TYPE(*CHAR) LEN(9)
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

/*           CALL       PGM(&OPTPGM) PARM(&WHSE &PO &RETURN &JOBQ +
                          &DEV &FORM)                               (530 D) */
             CALL       PGM(&OPTPGM) PARM(&WHSE &PO &FRMDTE &TODTE +
                          &VEN &RETURN &JOBQ &DEV &FORM)         /* (530 M) */
/*                        &RETURN &JOBQ &DEV &FORM)              /* (530 M) */

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
/*             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &PO +
/*                          &RETURN &DEV &FORM)) JOB(&SBMPGM)        (530 D) */
               SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &PO &FRMDTE +
                            &TODTE &VEN &RETURN &DEV &FORM)) JOB(&SBMPGM) +
/*                          &TODTE &RETURN &DEV &FORM)) JOB(&SBMPGM) +
                                                                  /* (640 M) */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('HAHWHSE *EQ ' *CAT &WHSE)

/*           IF (&PO *NE '*ALL') THEN(DO)                            (530 D) */
             IF (&PO *NE '*ALL' *AND &PO *GT ' ') THEN(DO)        /* (530 M) */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'HAHPO *EQ +
                          ' *BCAT &QUOTE *CAT &PO *CAT &QUOTE)
             ENDDO

/*         Select HACCP info based on date range.                    (530 A) */
             IF (&PO *EQ ' ') THEN(DO)                            /* (530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND') /*(530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('HAHEDT +
                            *GE ' *CAT &FRMDTE))                  /* (530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND') /*(530 A) */
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('HAHEDT +
                            *LE ' *CAT &TODTE))                   /* (530 A) */
             ENDDO                                                /* (530 A) */

 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(HC321) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(HC321) QRYSLT(&QRYSLT) +
                          KEYFLD((POHHACCP/HAHWHSE) (POHHACCP/HAHPO) +
                          (POHHACCP/HAHSEQ)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/*           CALL       PGM(HC321)                                   (530 D) */
             CALL       PGM(HC321) PARM(&PO &FRMDTE &TODTE &VEN)  /* (640 M) */
/*           CALL       PGM(HC321) PARM(&PO &FRMDTE &TODTE)       /* (530 M) */

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
