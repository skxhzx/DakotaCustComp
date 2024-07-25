/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT505CL   FTP Import Item Daily Demand                           */
/*  13 October 2004                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    10/13/04  MLB  5.00                                            */
/*      -Created.                                                    */
/*                                                                   */
/*    10/25/09  MLB  5.30                                            */
/*      - Enh: Revised program to use IMPFPCKQ for processing        */
/*        instead of IMPFDEMD.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Donson's Distributing                   */
/*    10/18/04  MLB  5.00                                            */
/*      -*Temporary Change* Revised program to copy ITEMSLS file     */
/*        to SAVESLS member for backup purposes.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD   -  Run time option.                                     */
/*              *TODAY   - Update daily demand in today's field.     */
/*              *YESTRDY - Update daily demand in yesterday's field. */
/*              *SUN     - Update daily demand in Sunday's field.    */
/*              *MON     - Update daily demand in Monday's field.    */
/*              *TUE     - Update daily demand in Tuesday's field.   */
/*              *WED     - Update daily demand in Wednesday's field. */
/*              *THU     - Update daily demand in Thursday' field.   */
/*              *FRI     - Update daily demand in Friday's field.    */
/*              *SAT     - Update daily demand in Saturday's field.  */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*    &RUN   -  *INTER  Run interactively                            */
/*              *JOBQ   Run on Jobq                                  */
/*    &OUTQ  -  Printer output queue (Default is *JOB)               */
/*    &FORM  -  Printer form (Default is *STD)                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    PUT localitem PIRFTPF/IMPFPCKQ.D123456789               (530 M)*/
/*    QUOTE RCMD PIRFTP/FTPLIBL *PROD                                */
/*    QUOTE RCMD IT505CL (*YESTRDY D123456789 *INTER *JOB *STD)      */
/*                                                                   */
/*     where D123456789 is the unique member name                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - A member should only contain item daily demand for a single   */
/*     warehouse.                                                    */
/*                                                                   */
/*   - Member name must be unique for each PUT operation.  If not,   */
/*     PUT will delete any existing information and replace it       */
/*     with the new information.                                     */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.  It is suggested that 'D' be used for the          */
/*     item daily demand updates.                                    */
/*                                                                   */
/*   - Do not use date and/or time to make the member name unique.   */
/*     There is always a possibility that two terminals processing   */
/*     Item Daily Demand will generate the same date/time.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   FTP daily demand are sent into a special FTP import file. Unlike*/
/*   the normal import where everything goes into a single member,   */
/*   the FTP import files contain multiple members.  The member      */
/*   that is used for a particular session is sent in as a           */
/*   parameter.                                                      */
/*                                                                   */
/*   This is designed to be called from the command line or as a     */
/*   remote command using the FTP Quote command. When called from    */
/*   the command line the user will be prompted for the necessary    */
/*   parameters.  When called as a remote command, the necessary     */
/*   parameters are passed in.                                       */
/*                                                                   */
/*   Normally this program is called as a remote FTP command after   */
/*   the data has been sent.  The option to call this from the       */
/*   command line is mainly for testing and the instances when       */
/*   something goes wrong with the import process.                   */
/*                                                                   */
/*   When called as a remote FTP command the job 'Type' is '0'       */
/*   which means it looks like a batch job.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT505CL:    PGM        PARM(&CMD &MBR &RUN &OUTQ &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT505CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT505)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT506)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(NONE)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import FTP Item Daily Demand')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing FTP Item Daily Demand')

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPDEMD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPDEMDERR')

  /* Import files */

/*           DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFDEMD')                          (530 D) */
             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPCKQ')                       /* (530 M) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGK)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RUN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* See if user wants to run from Jobq. */

             IF (&RUN = '*JOBQ') THEN(DO)
               CHGVAR VAR(&RETURN) VALUE('*JOBQ')
               GOTO CMDLBL(SKIP1)
             ENDDO

/* Don't get options if being run from JOBQ. */

             IF ((&TYPE = '0') *OR (&MBR *NE ' ')) THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&RETURN &MBR &CMD &OUTQ +
                          &FORM)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

 SKIP1:

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
               SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&CMD &MBR '*JOBQ2' +
                          &OUTQ &FORM)) JOB(&SBMPGM)
               RMVMSG     CLEAR(*ALL)
               CHGVAR  VAR(&FINISHED) VALUE('1')
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

             CPYF       FROMFILE(ITEMSLS) TOFILE(ITEMSLS) +
                          FROMMBR(ITEMSLS) TOMBR(SAVESLS) +
                          MBROPT(*REPLACE) FROMRCD(1) /* (DON) */
             MONMSG     MSGID(CPF2817 CPF2869)

/* Make sure &DEV and &FORM are not blank */

               IF (&OUTQ = ' ') +
                 THEN(CHGVAR VAR(&OUTQ) VALUE('*JOB'))
               IF (&FORM = ' ') +
                 THEN(CHGVAR VAR(&FORM) VALUE('*STD'))

/* Clear any existing messages and display working message. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* Override printer file */

             OVRPRTF    FILE(&PRTF) OUTQ(&OUTQ) FORMTYPE(&FORM)

/* Override import files to correct member */

             OVRDBF     FILE(&FILE) TOFILE(*FILE) MBR(&MBR)

/* Import daily demand by item. */

             CALL       PGM(&RPTPGM) PARM(&CMD &RETURN &MSGK)

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVM       FILE(&FILE) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF3203 CPF3273 CPF7301 +
                          CPF7310) /* Ignore not removed. */
             RMVMSG     CLEAR(*ALL)

/*  Send 'Successful message */

             IF COND(&FINISHED = '1') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import successful for' *BCAT &MBR +
                          *TCAT '/' *CAT &RUN +
                          *TCAT '/' *CAT &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)
             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             IF COND(&TYPE = '1') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             ENDDO

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&FTPMSGQ) MSGTYPE(*COMP)

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&FTPERRMSGQ) +
                          MSGTYPE(*COMP)
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

               RCLRSC     LVL(*CALLER)

/*  Send '*Escape' message to caller */

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
             ENDDO

             ENDPGM
