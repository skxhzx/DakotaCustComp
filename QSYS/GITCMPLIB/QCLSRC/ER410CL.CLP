/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER410CL   Thru-put for a date range                              */
/*  15 September, 2000                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    06/24/03  MLB  4.17                                            */
/*      - Enh: Revised sort for printing report to be                */
/*        WHDP, STYP, TASK, SDTE, STIM order from sdte, stim, whdp   */
/*        order.                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER410CL:    PGM        PARM(&FMDT &TODT &WHSE &BTIM &ETIM +
                          &JOBQ &RETURN &DEV &FORM &ZORD &MRG)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER410CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER410)

  /* Report program and printer file name. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(PIRTRAN)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Thru-put for a time range')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing thru-put for a time range')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BTIM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&ETIM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
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
             DCL        VAR(&ZORD)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&FMDT &TODT &WHSE &BTIM +
                          &ETIM &JOBQ &RETURN &DEV &FORM &ZORD &MRG)

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
                          &BTIM &ETIM &JOBQ &RETURN &DEV &FORM +
                          &ZORD &MRG)) JOB(*JOBD)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:


   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('PTWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTSDTE  +
                          *GE ' *CAT &FMDT))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTSDTE  +
                          *LE ' *CAT &TODT))


             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

/*5.10c*/    IF         COND(&MRG *EQ 'Y') THEN(DO)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT (          +
                       '((LBTYPE *EQ ' *CAT &QUOTE *CAT B *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT O *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT M *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT R *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT P *CAT &QUOTE *CAT '))' +
                                                                       ))
/*5.10c*/    ENDDO
/*5.10c*/    IF         COND(&MRG *EQ 'N') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT (          +
                       '((LBTYPE *EQ ' *CAT &QUOTE *CAT B *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT O *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT R *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT P *CAT &QUOTE *CAT '))' +
                                                                       ))
/*5.10c*/    ENDDO

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(ER412)  TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((PIRTRAN) (LABEL)) FORMAT(ER412) +
                          QRYSLT(&QRYSLT) KEYFLD((PIRTRAN/PTWHDP) +
                          (PIRTRAN/PTSTYP) (PIRTRAN/PTTASK) +
                          (PIRTRAN/PTSDTE) (PIRTRAN/PTSTIM)) +
                          JFLD((PIRTRAN/PTTRN# LABEL/LBTRN# *EQ)) +
                          JDFTVAL(*YES)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


       /* Summary Report */

             OVRPRTF    FILE(ER412PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER412) PARM(&FMDT &TODT &WHSE &BTIM +
                          &ETIM &ZORD &MRG)


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
