/*-------------------------------------------------------------------*/
/*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  GT150CL   Import Picked Route Goal Times                         */
/*  06 October 2009                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    10/06/09  MLB  5.20                                            */
/*      - Created.                                                   */
/*      - Client custom code support included in pgm.                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*    &OTYPE -  *GOALTIM  Import Picked Route Goal Times              */
/*    &RUN   -  *INTER  Run interactively                            */
/*              *JOBQ   Run on Jobq                                  */
/*    &OUTQ  -  Printer output queue (Default is *JOB)               */
/*    &FORM  -  Printer form (Default is *STD)                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    PUT localordh PIRFTPF/IMPFGOAL.G123456789                      */
/*    QUOTE RCMD PIRFTP/FTPLIBL *PROD                                */
/*    QUOTE RCMD GT150CL (G123456789 *GOALTIM *INTER *JOB *STD)      */
/*                                                                   */
/*     where G123456789 is the unique member name                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - Member name must be unique for each PUT operation.  If not,   */
/*     PUT will delete any existing information and replace it       */
/*     with the new information.                                     */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.  It is suggested that 'G' be used for a normal     */
/*     route of orders and 'W' be used for a will call order.        */
/*                                                                   */
/*   - Do not use date and/or time to make the member name unique.   */
/*     There is always a possibility that two terminals processing   */
/*     will call orders will generate the same date/time.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   A single member can contain goal times for one or more routes.  */
/*                                                                   */
/*   FTP orders are sent into a special FTP import file.             */
/*   The member that is used for a particular session is sent        */
/*   in as a parameter.                                              */
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
/*   which means it looks like a batch jobe.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 GT150CL:    PGM        PARM(&MBR &OTYPE &RUN &OUTQ &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(GT150CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(GT150)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(GT155)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(GT155PR)

  /* Client ID's.                                                            */

             DCL        VAR(&clientvar) TYPE(*CHAR) LEN(10) +
                          VALUE(clientid)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import Picked Route Goal Times')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing Picked Route Goal Times')

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPGOAL')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPGOALERR')

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFGOAL')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&cmd)        TYPE(*char) LEN(10)
             DCL        VAR(&COUNT)      TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&ORDTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&OTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RUN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

/*           MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))             */
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*  Get client code                                                          */

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)
             CHGJOB     LOGCLPGM(*YES)

/* See if user wants to run from Jobq. */

             IF (&RUN = '*JOBQ') THEN(DO)
               CHGVAR VAR(&RETURN) VALUE('*JOBQ')
               GOTO CMDLBL(SKIP1)
             ENDDO

/* Don't get options if being run from JOBQ. */

             IF ((&TYPE = '0') *OR (&MBR *NE ' ')) THEN(GOTO REPORT)

/*  Get import options. */

             CALL       PGM(&OPTPGM) PARM(&OTYPE &MBR &OUTQ +
                          &FORM &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

 SKIP1:

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
               SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&MBR &OTYPE '*JOBQ2' +
                          &OUTQ &FORM)) JOB(&SBMPGM)
               RMVMSG     CLEAR(*ALL)
               CHGVAR  VAR(&FINISHED) VALUE('1')
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

/* Make sure &DEV and &FORM are not blank */

               IF (&OUTQ = ' ') +
                 THEN(CHGVAR VAR(&OUTQ) VALUE('*JOB'))
               IF (&FORM = ' ') +
                 THEN(CHGVAR VAR(&FORM) VALUE('*STD'))

/* Clear any existing messages and display working message. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* Override printer file */


/* Override import files to correct member */

             OVRDBF     FILE(&FILEH) TOFILE(*FILE) MBR(&MBR)

/* Import orders */

             CALL       PGM(&RPTPGM) PARM(&OTYPE &WHSE)

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVM       FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)

             RMVMSG     CLEAR(*ALL)

/*  Send 'Successful message */

             IF COND(&FINISHED = '1') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import successful for' *BCAT &MBR +
                          *TCAT '/' *CAT &OTYPE *TCAT '/' *CAT &RUN +
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
                          &OTYPE *TCAT '/' *CAT &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &OTYPE *TCAT '/' *CAT &RUN *TCAT '/' *CAT +
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
