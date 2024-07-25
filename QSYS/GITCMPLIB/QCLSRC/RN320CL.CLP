/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN320CL   Print Customer Returns Analysis                        */
/*  28 August 2002                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*  08/28/02  MLB  4.16                                              */
/*    - Created.                                                     */
/*                                                                   */
/*  10/31/05  RLP  5.00b                                             */
/*    - ENH: Re-enable/modify W1DETL line, also adding *ALL or       */
/*           specific return code W1RCOD to options.                 */
/*    - ENH: adding new report RN326 to print when (S)ummary is      */
/*           entered for w1detl field, will default to 'S' and       */
/*           will print current report RN325 when (D)etail is        */
/*           entered for W1DETL.                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RN320CL:    PGM        PARM(&WHSE &FMDT &TODT &CREW &EMP# &PDETL +
                          &JOBQ &RETURN &DEV &FORM &PRCOD)  /* 500b  */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN320CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN320)

  /* Report program and printer file name. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ORRTN)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(RN325PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Customer Returns Analysis')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Customer Returns Anaylsis')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CREW)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PRCOD)      TYPE(*CHAR) LEN(4)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &FMDT &TODT &CREW &EMP# +
                          &PRCOD &PDETL &JOBQ &RETURN &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &FMDT &TODT +
                          &CREW &EMP# &PDETL &JOBQ &RETURN &DEV +
                          &FORM &PRCOD)) JOB(RN320CL) /* 500b */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/* 500b start  */

             IF (&PDETL = 'D') THEN(DO)
             OVRPRTF    FILE(RN325PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN325) PARM(&WHSE &FMDT &TODT &CREW +
                          &EMP# &PDETL &PRCOD)
             ENDDO

             IF (&PDETL = 'S') THEN(DO)
             OVRPRTF    FILE(RN326PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN326) PARM(&WHSE &FMDT &TODT &CREW +
                          &EMP# &PDETL &PRCOD)
             ENDDO

             IF (&PDETL = 'B') THEN(DO)
             OVRPRTF    FILE(RN325PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN325) PARM(&WHSE &FMDT &TODT &CREW +
                          &EMP# &PDETL &PRCOD)
             OVRPRTF    FILE(RN326PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN326) PARM(&WHSE &FMDT &TODT &CREW +
                          &EMP# &PDETL &PRCOD)
             ENDDO

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
