/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PR340CL   Print TPC priority replenishments report - Cone Whse   */
/*  29 October 2007                                                  */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    10/29/07  LMC  5.10a                                           */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PR340CL:    PGM        PARM(&WHSE &WHDP &FAISL &TAISL  +
                          &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR340CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR340)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('TPC Replenishment report - cone whse')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Replenishment report - +
                          cone whse')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FAISL)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&TAISL)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (500aA) */
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&LPGM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LPRT)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&NRPL)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RPLT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(PR341PR)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF         COND(&CLIENT *EQ ' ') THEN(DO)            /* (500aA) */
               RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)       /* (500aA) */
             ENDDO                                                /* (500aA0 */

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &FAISL +
                          &TAISL &JOBQ &DEV &FORM &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &FAISL +
                          &TAISL &DEV &FORM)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:
/*    - Override file to use unique member.           */
             CALL       PGM(GETUNQMEM) PARM(*REUSE PR341 &MEMBER)
             OVRDBF     FILE(PR341) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(PR340S) PARM(&WHSE &WHDP &FAISL &TAISL)

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(PR341) PARM(&WHSE &WHDP &FAISL &TAISL)+

             RMVMSG     CLEAR(*ALL)
             DLTOVR     FILE(PR341)

             IF         COND(&RETURN *EQ '*NONE') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('No +
                          Priority Replenishments Found') +
                          MSGTYPE(*INFO)
             GOTO GETOUT
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE(&LPRT *BCAT 'Priority +
                          Replenishment Report Printed')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA(&MSGDTA) +
                          MSGTYPE(*INFO)

/*  Receive any messages and pass them on  */

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
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             RMVM       FILE(PR341) MBR(&MEMBER) /* 510a */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310) /* 510a */

             ENDPGM
