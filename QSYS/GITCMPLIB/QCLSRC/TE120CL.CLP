/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TE120CL   Manual transaction maintenance.                        */
/*  19 January, 1996                                                 */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/24/97  RH  2.19                                             */
/*      - Correct BFCMSGF to PIRMSGF.                                */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TE120CL:    PGM        PARM(&PEMP# &PFMDT &PTODT &PSTIME &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(TE120CL)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(TE120)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRTRAN2)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Transactions maintenance')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Selecting records for display')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILEKY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PEMP#)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PSTIME)     TYPE(*CHAR) LEN(6)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  Run program. */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTEMP# *EQ +
                          ' *CAT &PEMP#)
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSDTE *GE*/  +
/*                        ' *CAT &PFMDT)                            */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTEDTE *LE*/  +
/*                        ' *CAT &PTODT)                            */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSTIM *GE*/  +
/*                        ' *CAT &PSTIME)                           */

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((&FILE/PTEMP#) (&FILE/PTSDTE +
                          *DESCEND) (&FILE/PTSTIM *DESCEND)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CHGVAR     VAR(&FILEKY) VALUE(&FILEKY *TCAT &PEMP#)
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(TE120) PARM(&FILEKY &RETURN)

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
