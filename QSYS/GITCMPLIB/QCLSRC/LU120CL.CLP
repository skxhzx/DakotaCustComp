/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LU120CL   Transactions lookup by empl#/start date + Tran Per Hr  */
/*  28 December, 1998                                                */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  09/19/99  HNK  4.12                                              */
/*   - "TO Date" and Begin time parameter added.                     */
/*      &PTODT, &PENDT and &PBTIM added.                             */
/*                                                                   */
/*    04/30/01  HNK  4.15                                            */
/*      - Loop until Canceled in LU120 program.                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LU120CL:    PGM        PARM(&PEMP# &PFMDT &PTODT &PENDT &PBTIM +
                          &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LU120CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LU120)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LU121)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRTRAN2)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Transactions lookup')
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
             DCL        VAR(&PENDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PBTIM)      TYPE(*CHAR) LEN(6)
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
/* Begin 4.15   */

 BEGIN:

/* End 4.15   */

/*  Get options. */

             CALL       PGM(&OPTPGM) PARM(&PEMP# &PFMDT &PTODT +
                          &PENDT &PBTIM &RETURN)


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO
/* Begin 4.15   */
             IF (&RETURN *EQ '*EXIT') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO
/* End 4.15   */

/*  Clear WRKTRAN file. */

             CLRPFM     FILE(WRKTRAN)

/*  Run program. */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(PTEMP# *EQ +
                           ' *CAT &PEMP# *BCAT '*AND' *BCAT           +
                           'PTSDTE *GE ' *CAT &PFMDT *BCAT '*AND'     +
                           *BCAT 'PTSDTE *LE ' *CAT &PENDT *BCAT ')')

/* When done, above query should look like this .....                */

/* (PTEMP# = Emp# AND PTSDTE >= From Date AND PTSDTE <= End date  */

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                          KEYFLD((&FILE/PTEMP#) (&FILE/PTSDTE +
                          *DESCEND) (&FILE/PTSTIM *DESCEND)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(LU120A) PARM(&PFMDT &PENDT &PBTIM)

             CHGVAR     VAR(&FILEKY) VALUE(&FILEKY *TCAT &PEMP#)
             CHGVAR     VAR(&RETURN) VALUE(' ')

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(WRKTRAN) SHARE(*YES)
             OPNQRYF    FILE((WRKTRAN)) KEYFLD((WRKTRAN/WTEMP#) +
                          (WRKTRAN/WTSDTE) (WRKTRAN/WTSTIM)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)
             CALL       PGM(LU121) PARM(&FILEKY &RETURN)
/* Begin 4.15   */

             CHGVAR     VAR(&QRYSLT) VALUE(' ')
             RCLRSC     LVL(*CALLER)
             GOTO       CMDLBL(BEGIN)

/* End 4.15   */

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
