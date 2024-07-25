/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER420CL   Total thru-put (Includes Idle time)                    */
/*  02 October, 2000                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created  4.14                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    06/23/03  MLB  4.17                                            */
/*      - Enh: Revised sort for printing report to be                */
/*        WHDP, STYP, TASK, SDTE, STIM order.                        */
/*    06/23/03  MLB  4.17a                                           */
/*      - Fix: Moved call to GETUNQMEM and GETWRKMEML to after       */
/*        Report tag. Program was failing when sent to batch to run. */
/*    06/24/03  MLB  4.17b                                           */
/*      - Enh: Revised program to remove members from workfile       */
/*        at job completion.                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER420CL:    PGM        PARM(&FMDT &TODT &WHSE &BTIM &ETIM +
                          &JOBQ &RETURN &DEV &FORM &MRG)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER420CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER420)

  /* Report program and printer file name. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ER422)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Total thru-put')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing total thru-put')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BTIM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&ERRFLG)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&ETIM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
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

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRFLG) VALUE('0')
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
/*              CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER) (417a) */
                ENDDO

/*           CALL       PGM(GETWRKMEML) PARM(*REUSE ER4221 &FILE +
                          &MEMBER)                                   (417a) */


/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&FMDT &TODT &WHSE &BTIM +
                          &ETIM &JOBQ &RETURN &DEV &FORM &MRG)

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
                           &BTIM &ETIM &JOBQ &RETURN &DEV &FORM &MRG)) +
                          JOB(*JOBD)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:


/*    - Get unique member to use.                                      (417a) */
/*    - Override file to use unique member.                            (417a) */

             IF (&MEMBER = ' ') DO                                  /* (417a) */
               CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER) /* (417a) */
             ENDDO                                                  /* (417a) */

             CALL       PGM(GETWRKMEML) PARM(*REUSE ER4221 &FILE +
                          &MEMBER)                                  /* (417a) */
             CALL       PGM(GETWRKMEML) PARM(*REUSE ER4222 &FILE +
                          &MEMBER)                                  /* (417a) */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('PTWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTSDTE  +
                          *GE ' *CAT &FMDT))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTSDTE  +
                          *LE ' *CAT &TODT))


             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

/* Bulk pick, Order pick, Replen, Putaway, IDLE task tran */

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
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT P *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                    '(PTTASK *EQ ' *CAT &QUOTE *CAT IDLE *CAT &QUOTE *CAT '))' +
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
                       '(LBTYPE *EQ ' *CAT &QUOTE *CAT P *CAT &QUOTE *CAT ')' +
                        *BCAT '*OR' *BCAT                             +
                    '(PTTASK *EQ ' *CAT &QUOTE *CAT IDLE *CAT &QUOTE *CAT '))' +
                                                                       ))

/*5.10c*/    ENDDO
   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(ER421) TOFILE(PIRTRAN) SHARE(*YES)
             OPNQRYF    FILE((PIRTRAN) (LABEL)) FORMAT(ER421) +
                          QRYSLT(&QRYSLT) KEYFLD((PIRTRAN/PTSDTE) +
                          (PIRTRAN/PTSTIM) (LABEL/LBWHDP)) +
                          JFLD((PIRTRAN/PTTRN# LABEL/LBTRN# *EQ)) +
                          JDFTVAL(*YES)

   /* Populate work file */

             OVRDBF     FILE(ER422) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(ER4221) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(ER4222) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(ER421) PARM(&FMDT &TODT &WHSE &BTIM &ETIM)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


       /* Summary Report */

             OVRPRTF    FILE(ER422PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             OPNQRYF    FILE((ER422)) KEYFLD((ER422/ERWHDP) +
                          (ER422/ERSTYP) (ER422/ERTASK) (ERSDTE) +
                          (ERSTIM))
             CALL       PGM(ER422) PARM(&FMDT &TODT &WHSE &BTIM +
                          &ETIM &MRG)

             RMVMSG     CLEAR(*ALL)

 /* REPORT:    */

 /* Receive any messages and pass them on */

 GETOUT:
             IF         COND(&ERRFLG *EQ '1') THEN(GOTO BOTTOM)
             CHGVAR     VAR(&ERRFLG) VALUE('1')
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

/*           CLRPFM     FILE(&FILE)                                    (417b) */
             DLTOVR     FILE(ER4221)                                /* (417b) */
             MONMSG     MSGID(CPF9841)                              /* (417b) */
             DLTOVR     FILE(ER4222)                                /* (417b) */
             MONMSG     MSGID(CPF9841)                              /* (417b) */
             DLTOVR     FILE(&FILE)                                 /* (417b) */
             MONMSG     MSGID(CPF9841)                              /* (417b) */
             CLOF       OPNID(ER4221)                               /* (417b) */
             MONMSG     MSGID(CPF4519 CPF4520)                      /* (417b) */
             CLOF       OPNID(&FILE)                                /* (417b) */
             MONMSG     MSGID(CPF4519 CPF4520)                      /* (417b) */
             RMVM       FILE(ER4221) MBR(&MEMBER)                   /* (417b) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                          /* (417b) */
             RMVM       FILE(ER4222) MBR(&MEMBER)                   /* (417b) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                          /* (417b) */
             RMVM       FILE(&FILE) MBR(&MEMBER)                    /* (417b) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                          /* (417b) */
 BOTTOM:
             RCLRSC     LVL(*CALLER)

             ENDPGM
