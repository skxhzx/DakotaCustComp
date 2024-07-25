/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER390CL   Task Summary by Crew                                   */
/*  08 December 2009                                                 */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER390CL:    PGM        PARM(&PFMDT &PTODT &PWHSE &PEMP# &PCREW +
                          &PENDT &PBTIM &PETIM &PDETL &JOBQ &RETURN +
                          &DEV &FORM &MEMBER &MRG)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (750aA)  */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER390CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ER390)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ER391A)
             DCL        VAR(&FILE2) TYPE(*CHAR) LEN(10) VALUE(WORKOPT)
             DCL        VAR(&FILE3) TYPE(*CHAR) LEN(10) VALUE(ER391)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Task Summary by Crew')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating task summary by crew')


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
             DCL        VAR(&MEMBER2) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER3)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PEMP#)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PENDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PBTIM)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PETIM)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PVYN)       TYPE(*CHAR) LEN(1)

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

 AGAIN:

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &PEMP# &PFMDT +
                          &PTODT &RETURN &PCREW &PBTIM &PETIM +
                          &PENDT &PVYN &MRG &DEV &FORM &JOBQ)

/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PFMDT &PTODT +
                          &PWHSE &PEMP# &PCREW &PENDT &PBTIM &PETIM +
                          &PDETL &JOBQ &RETURN &DEV &FORM &MEMBER +
                          &MRG)) JOB(&SBMPGM)
               RETURN
             ENDDO

/*  Otherwise, run program. */

 REFRESH:
             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)

             CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE2 &MEMBER2)
             OVRDBF     FILE(&FILE2) MBR(&MEMBER2) SHARE(*YES)

             CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE3 &MEMBER3)
             OVRDBF     FILE(&FILE3) MBR(&MEMBER3) SHARE(*YES)

             CALL       PGM(ER390A) PARM(&PFMDT &PTODT &PBTIM &PETIM +
                          &PVYN &PEMP# &PWHSE &PCREW &MRG)

             CALL       PGM(ER391A) PARM(&PFMDT &PTODT &PBTIM &PETIM +
                          &MRG)

             CALL       PGM(ER391B) PARM(&PWHSE &PEMP# &PCREW &PFMDT +
                          &PTODT &PBTIM &PETIM)

             OVRPRTF    FILE(ER391PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(ER391) PARM(&PWHSE &PEMP# &PCREW &PFMDT &PTODT +
                          &PBTIM &PETIM &MRG) /*(5.30a */

             IF COND(&PCMD = '*REFRESH') THEN(DO)
             GOTO REFRESH
             ENDDO

             IF COND(&PCMD = '*CANCEL ') THEN(DO)
             RCLRSC     LVL(*CALLER)
             GOTO AGAIN
             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:
   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)


             RMVM       FILE(&FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)

             RMVM       FILE(&FILE2) MBR(&MEMBER2)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)

             RMVM       FILE(&FILE3) MBR(&MEMBER3)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)

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
