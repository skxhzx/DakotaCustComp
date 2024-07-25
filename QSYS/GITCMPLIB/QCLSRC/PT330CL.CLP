/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT330CL   Print Open put away transactions                       */
/*  17 September, 1999                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    09/17/99  HNK  4.12                                            */
/*      - Created                                                    */
/*    08/23/00  RRH  4.14a                                           */
/*    - Add PTTASK='PUTEMP' to QRYSLT                                */
/*    09/07/01  HNK  4.16                                            */
/*    - Add Department selection.                                    */
/*                                                                   */
/*    06/06/05  MLB  5.00                                            */
/*    - Enh: Revised join on OPNQRYF to add warehouse when joining   */
/*      PIRTRAN to LICENSE1 file. Changed OPNQRYF to use LICENSE1    */
/*      instead of LICENSE.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT330CL:    PGM        PARM(&FMDT &TODT &WHSE &JOBQ &RETURN +
                            &DEV &FORM &WHDP)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PT330CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PT330)

  /* Report program and printer file name. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(PIRTRAN)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(PT331PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Open Put-away transactions')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Open Put-away transactions')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
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
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&FMDT &TODT &WHSE  +
                          &JOBQ &RETURN &DEV &FORM &WHDP)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&FMDT &TODT &WHSE +
                          &JOBQ &RETURN &DEV &FORM &WHDP)) JOB(*JOBD)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('PTWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                          '%SST(PTGRP1 1 1) = %VALUES("P")')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSTAT *LT +
                          "4"')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK *EQ +
                          "PUTEMP"')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTGDTE  +
                          *GE ' *CAT &FMDT))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTGDTE  +
                          *LE ' *CAT &TODT))
/* 416 */
             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO
/* 416 */

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(PT331)  TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (LICENSE1)) FORMAT(PT331) +
                          QRYSLT(&QRYSLT) KEYFLD((PIRTRAN/PTTRN#)) +
                        JFLD((pirtran/ptwhse license1/liwhse) +
                             (PIRTRAN/PTTRN# LICENSE1/LITRN#))  /*(500 M) */
/*                        JFLD((PIRTRAN/PTTRN# LICENSE/LITRN#))   (500 D) */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(PT331) PARM(&WHSE &FMDT &TODT &WHDP)


 /* REPORT:    */

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
