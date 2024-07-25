/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER270CL   Employee management report for an employee             */
/*  19 February, 1996                                                */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*  Note: This program is now replaced by ER360CL   4.13             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER270CL:    PGM        PARM(&PFMDT &PTODT &PWHSE &PEMP# &PDETL +
                          &JOBQ &RETURN &DEV &FORM &MEMBER)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER270CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ER270)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ER271)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER271PR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(ER272PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Employee management report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing employee management report')


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
             DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PEMP#)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
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

             CALL       PGM(&OPTPGM) PARM(&PFMDT &PTODT &PWHSE +
                          &PEMP# &PDETL &JOBQ &RETURN &DEV &FORM)


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PFMDT &PTODT +
                          &PWHSE &PEMP# &PDETL &JOBQ &RETURN &DEV +
                          &FORM &MEMBER)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:

       /* If run from jobq, do the override again.  */

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
             ENDDO

       /* Detail Report */

             IF (&PDETL = 'Y') THEN(DO)
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER271) PARM(&PFMDT &PTODT &PWHSE &PEMP#)
             ENDDO

       /* Summary Report */

             IF (&PDETL = 'N') THEN(DO)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER272) PARM(&PFMDT &PTODT &PWHSE &PEMP#)
             ENDDO

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(&FILE) MBR(&MEMBER)
             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             DLTOVR     FILE(&FILE)

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
