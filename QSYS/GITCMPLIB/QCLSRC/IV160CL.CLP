/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV160CL   Inventory variance report by item                      */
/*  27 March, 1996                                                   */
/*  Hemant Kapadia/Roxanne Harrison                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    03/11/99  RH   4.11                                            */
/*      - Change JOB name for JOBQ, was getting error in GETUNQMEM   */
/*        because job name started with a number (160CL     )        */
/*    04/25/02  RH   4.16                                            */
/*      - Add parm for minimum variance.                             */
/*    01/29/11  GJA  6.40a                                           */
/*      - Fix: Revised pgm to remove member on exit.                 */
/*    12/20/12  MLB  6.40b                                           */
/*      - Fix: Revised pgm to correct errors that 6.40a mod caused   */
/*        when pgm submitted to batch.                               */
/*    03/15/13  RH   6.50a                                           */
/*      - ENH: Add parm to include linked item slots for summary     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV160CL:    PGM        PARM(&PWHSE &PXCP &PSUM &PVAR &PLNKD +
                          &JOBQ &RETURN &DEV &FORM &MEMBER) /* 650a */
/*                        &RETURN &DEV &FORM &MEMBER)  6.50a */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV160CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV160)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV161)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(IV161)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IV161PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Inventory variance report by item')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing inventory variance report +
                          by item')


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
             DCL        VAR(&PLNKD)      TYPE(*CHAR) LEN(1)  /* 650a */
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PXCP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PSUM)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PVAR)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
                ENDDO

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &PXCP &PSUM &PVAR +
                          &PLNKD &JOBQ &RETURN &DEV &FORM)        /* 650a */
/*                        &JOBQ &RETURN &DEV &FORM)                  650a */


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               DLTOVR     FILE(&FILE)                             /* (640bA) */
               MONMSG     MSGID(CPF9841)                          /* (640bA) */
               RMVM       FILE(&FILE) MBR(&MEMBER)                /* (640bA) */
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)              /* (640bA) */
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PWHSE &PXCP &PSUM +
                          &PVAR &PLNKD &JOBQ &RETURN &DEV &FORM +
/* 650a */                &MEMBER)) +
                          JOB(AAIV160CL)
 /* 4.11                  JOB(&SBMPGM)                             */
/*             GOTO       CMDLBL(GETOUT)                             (640bD) */
               RETURN                                             /* (640bM) */
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:


   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
             ENDDO

             CALL       PGM(IV161) PARM(&PWHSE &PXCP &PSUM &PVAR +
/*6.50a */              &PLNKD)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
/*6.40a      CLRPFM     FILE(&FILE) MBR(&MEMBER)      */
             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             DLTOVR     FILE(&FILE)
/*6.40a */   MONMSG     MSGID(CPF9841)
/*6.40a */   RMVM       FILE(&FILE) MBR(&MEMBER)
/*6.40a */   MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
/*6.40a */                CPF7301 CPF7310 CPF0001)

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

             ENDPGM
