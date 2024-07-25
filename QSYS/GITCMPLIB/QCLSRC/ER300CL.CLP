/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER300CL   Employee management report for an employee(RECV)       */
/*  20 February, 1996                                                */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    01/06/17  MLB  7.00                                            */
/*      - Fix: Revised pgm to add ovrdbf cmd for &file1. Pgm failed  */
/*        when submitted to batch and ER3011 was not found. Also,    */
/*        SBMJOB was going to :GETOUT and removing mbrs before report*/
/*        could execute. Changed GOTO to RETURN.                     */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER300CL:    PGM        PARM(&PFMDT &PTODT &PWHSE &PEMP# &PDETL +
                          &JOBQ &RETURN &DEV &FORM &MEMBER)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (750aA)  */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER300CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ER300)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ER301)
             DCL        VAR(&FILE1)  TYPE(*CHAR) LEN(10) VALUE(ER3011)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER301PR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(ER302PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Employee management report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing employee management report')

/*750aA*/    DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('   Use Web Dakota EPM Task +
                           Summary Plus.  ')
/*750aA*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*750aA*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*750 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*750 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*750 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)


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

/*750aA*/    CHGVAR     VAR(&PGMID) VALUE(ER360CL)
/*750aA*/    RTVJOBA    USER(&PUSR)
/*750aA*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (750aA) */

/*750aA*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
/*750aA*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*750aA*/               SNDPGMMSG  MSG(&NOAUTHRZG)   +
/*750aA*/               MSGTYPE(*INFO)
/*750aA*/    RETURN
/*750aA*/    ENDDO

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
             CALL       PGM(GETWRKMEML) PARM(*REUSE ER3011 ER301 +
                          &MEMBER)
             OVRDBF     FILE(ER3011) MBR(&MEMBER)
                ENDDO

             OVRDBF     FILE(ER301) MBR(&MEMBER)

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
                          &PWHSE &PEMP# &PDETL &JOBQ   +
                          &RETURN &DEV &FORM &MEMBER)) JOB(&SBMPGM)
/*             GOTO       CMDLBL(GETOUT)                             (700 D) */
               RETURN                                             /* (700 M) */
             ENDDO

/*  Otherwise, run program. */


 REPORT:

       /* If run from jobq, do the override again.  */

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(&FILE1) MBR(&MEMBER) SHARE(*YES)     /* (700 A) */
             ENDDO

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             CALL       PGM(ER301A)

             IF (&PDETL = 'Y') THEN(DO)
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER301) PARM(&PFMDT &PTODT &PWHSE &PEMP#)
             ENDDO

       /* Summary Report */

             IF (&PDETL = 'N') THEN(DO)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER302) PARM(&PFMDT &PTODT &PWHSE &PEMP#)
             ENDDO


/*  Clean up before leaving */

/*  Receive any messages and pass them on  */
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

 GETOUT:
             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(&FILE1)
             MONMSG     MSGID(CPF9841 CPF3219)
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841 CPF3219)
             RMVM       FILE(&FILE1) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001 CPF7310)
             RMVM       FILE(&FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001 CPF7310)


             ENDPGM
