/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER360CL   Print Management report for a selector                 */
/*  16 March, 2000                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*  09/18/09  GJA  5.30                                              */
/*    - Cleaned up and revamped for suspended transactions.          */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*-------------------------------------------------------------------*/

 ER360CL:    PGM        PARM(&FMDT &ENDT &WHSE &EMP# &JOBQ &RETURN +
                          &DEV &FORM &TODT &MRG &ZNDP &VYN &FMTM +
                          &TOTM &TBD)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

/*CLD A*/    DCL        VAR(&CITYLINX) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINX  ')
  /* Name of this program. */
             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER360CL)

  /* Option program. */
             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER360)

  /* Report program and printer file name. */
             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRTRAN)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER361PR)

  /* Informational message. */
             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Management report for a selector')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Management report for a selector')

/*750aA*/    DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('   Use Web Dakota EPM Selection +
                           Crew Report.')
/*750aA*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*750aA*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*750 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*750 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*750 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&EMP#)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&ENDT)       TYPE(*CHAR) LEN(8)
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
             DCL        VAR(&FMTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TOTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&ZORD)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&ZNDP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VYN)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&TBD)        TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
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

/*  Don't get options, if being run from JOBQ. */
             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */
             CALL       PGM(&OPTPGM) PARM(&FMDT &ENDT &WHSE &EMP#  +
                  &JOBQ &RETURN &DEV &FORM &TODT &MRG &ZNDP &VYN &TBD +
                  &FMTM &TOTM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO
/* See if user wants to put report on jobq. */
             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&FMDT &ENDT &WHSE +
                          &EMP# &JOBQ &RETURN &DEV &FORM &TODT &MRG +
                          &ZNDP &VYN &FMTM &TOTM &TBD)) JOB(*JOBD)
             RETURN
             ENDDO

/*  Otherwise, run program. */

 REPORT:

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

       /* POPULATE FILE */

/*           CLRPFM     FILE(ER361A)                                    (417) */
/*    - Get unique member to use.                                       (417) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE ER361A &MEMBER)
             OVRDBF     FILE(ER361A) MBR(&MEMBER)

             CALL       PGM(GETUNQMEM) PARM(*REUSE ER361 &MEMBER)
             OVRDBF     FILE(ER361) MBR(&MEMBER)


             CALL       PGM(ER360A) PARM(&FMDT &ENDT &WHSE &EMP# +
                        &MRG &FMTM &TOTM &VYN)
             CALL       PGM(ER361A) PARM(&FMDT &ENDT &WHSE &EMP# +
                          &MRG &ZNDP &VYN &TBD &FMTM &TOTM)

       /* Detail Report */

/*5.20a      IF (&PDETL = 'Y') THEN(DO)           */
             OVRPRTF    FILE(ER361PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER361) PARM(&FMDT &TODT &WHSE &EMP# +
                          &ZNDP &FMTM &TOTM &MRG)
/*  5.20a    ENDDO     */

       /* Summary Report */

/*   5.20a   IF (&PDETL = 'N') THEN(DO)                            */
/*           OVRPRTF    FILE(ER362PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)                          */
/*           CALL       PGM(ER362) PARM(&FMDT &TODT &WHSE &EMP#)   */
/*           ENDDO            */


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

             CLOF       OPNID(ER361A)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(ER361A) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             CLOF       OPNID(ER361)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(ER361) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             RMVM       FILE(ER361A) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
             RMVM       FILE(ER361) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)

             ENDPGM
