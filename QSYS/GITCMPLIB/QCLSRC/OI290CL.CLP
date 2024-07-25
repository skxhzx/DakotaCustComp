/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OI290CL   Import FTP orders w/Pick Slot Ver 5                    */
/*  22 January 2009                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    01/22/09  MLB  5.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    10/30/09  MLB  5.30                                            */
/*      - Enh: Added DSPJOBLOG *PRINT when Finished = '0' so we      */
/*        have a more complete picture of all the error messages.    */
/*                                                                   */
/*    04/08/13  MLB  6.50                                            */
/*      - Enh: Added client custom code support go pgm.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    04/08/13  MLB  DRY                                             */
/*      - Revised pgm to set &OTYPE = *WILL5 if &OTYPE = *ROUTE5     */
/*        and &RTID01 thru &RTID10 are greater than blanks.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: H&M Wagner                              */
/*                                                                   */
/*    12/31/14  RTR  HMWa                                            */
/*      - Revised pgm to set &OTYPE = *WILL5 if &OTYPE = *ROUTE5     */
/*        and &ORDTYPE returned is 'W'.                              */
/*    01/09/14  RTR  HMWb                                            */
/*      - Revised to call MV conversion for HMW will calls due to    */
/*        showroom picks. This should be temporary.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: S.Bertram                               */
/*                                                                   */
/*    01/25/16  RTR  SBRa                                            */
/*      - Revised to call MV conversion for route 999 will calls.    */
/*        These are special/sample and other items not processed     */
/*        as normal orders.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Jakes Foods                             */
/*                                                                   */
/*    06/26/18  MLB  JFF                                             */
/*      - Revised pgm to set &outq = BFCEXCP so that import detail   */
/*        report doesn't print. Per Jose B. email date 06.26.2018.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*    &OTYPE -  *ROUTE5  Route of customer orders w/pick slot        */
/*    (500aA)   *SARTE5  Route of customer orders w/Host labels.     */
/*              *WILL5   Willcall order(s) w/pick slot               */
/*              *SINGLE5 Single order                                */
/*    &RUN   -  *INTER   Run interactively                           */
/*              *JOBQ    Run on Jobq                                 */
/*    &OUTQ  -  Printer output queue (Default is *JOB)               */
/*    &FORM  -  Printer form (Default is *STD)                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    PUT localordh PIRFTPF/IMPFORDH3.N123456789                     */
/*    PUT localordd PIRFTPF/IMPFORDHM.N123456789                     */
/*    PUT localordd PIRFTPF/IMPFORDD3.N123456789                     */
/*    PUT localordd PIRFTPF/IMPFORDDM.N123456789                     */
/*    QUOTE RCMD PIRFTP/FTPLIBL *PROD                                */
/*    QUOTE RCMD OI290CL (R123456789 *ROUTE5 *INTER *JOB *STD)       */
/*                                                                   */
/*     where R123456789 is the unique member name                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - Member name must be unique for each PUT operation.  If not,   */
/*     PUT will delete any existing information and replace it       */
/*     with the new information.                                     */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.  It is suggested that 'R' be used for a normal     */
/*     route of orders and 'W' be used for a will call order.        */
/*                                                                   */
/*   - Do not use date and/or time to make the member name unique.   */
/*     There is always a possibility that two terminals processing   */
/*     will call orders will generate the same date/time.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   A single member should contain either one route for a single    */
/*   warehouse or one will call order.                               */
/*                                                                   */
/*   FTP orders are sent into a special FTP import file.  Unlike     */
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
/*   which means it looks like a batch jobe.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OI290CL:    PGM        PARM(&MBR &OTYPE &RUN &OUTQ &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (650 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */
             DCL        VAR(&HMWAGNER) TYPE(*CHAR) LEN(10) +
                          VALUE('HMWAGNER')                       /* (HMWaA) */
             DCL        VAR(&SBERTRAM) TYPE(*CHAR) LEN(10) +
                          VALUE('SBERTRAM')                       /* (SBRaA) */
             DCL        VAR(&JAKES) TYPE(*CHAR) LEN(10) +
                          VALUE('JAKESFOODS')                     /* (JFF A) */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OI290CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OI290)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OI295)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(OI295PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import/pick FTP orders w/Pick Slot Ver 5')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing/Picking FTP orders +
                          w/Pick Slot Ver 5')

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPORD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPORDERR')

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFORDH5')
             DCL        VAR(&FILEHM) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFORDHM')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFORDD5')
             DCL        VAR(&FILEDM) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFORDDM')
             DCL        VAR(&FILEL) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFORDL')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (650 A) */
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
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID01)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID02)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID03)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID04)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID05)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID06)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID07)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID08)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID09)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID10)     TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTNAME)     TYPE(*CHAR) LEN(5)       /* (SBRaA) */
             DCL        VAR(&RTTYPE)     TYPE(*CHAR) LEN(1)       /* (SBRaA) */
             DCL        VAR(&RTSTAT)     TYPE(*CHAR) LEN(1)       /* (SBRaA) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRUCK)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE3)      TYPE(*DEC)  LEN(3 0)

/* Get Client ID */                                               /* (650 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (650 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

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

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&RETURN &MBR &OTYPE &OUTQ +
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

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILED) OBJTYPE(*FILE) MBR(&MBR)
             IF         COND(&OTYPE = '*SARTE5') THEN(DO)
               CHKOBJ     OBJ(&FILEL) OBJTYPE(*FILE) MBR(&MBR)
             ENDDO
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
             CHKOBJ     OBJ(&FILED) OBJTYPE(*FILE) MBR(&MBR)
             IF         COND(&OTYPE = '*SARTE5') THEN(DO)
               CHKOBJ     OBJ(&FILEL) OBJTYPE(*FILE) MBR(&MBR)
             ENDDO
             CHGVAR     VAR(&EXIST) VALUE('1')

/* Convert &OTYPE code into &ORDTYPE code */

               CHGVAR VAR(&ORDTYPE) VALUE(' ')
               IF (&OTYPE *EQ '*WILL5') +
                 THEN(CHGVAR VAR(&ORDTYPE) VALUE('W'))
               IF (&OTYPE *EQ '*SINGLE5') +
                 THEN(CHGVAR VAR(&ORDTYPE) VALUE('S'))
               IF (&OTYPE *EQ '*SARTE5') +
                 THEN(CHGVAR VAR(&ORDTYPE) VALUE('A'))

/* Make sure &DEV and &FORM are not blank */

               IF (&OUTQ = ' ') +
                 THEN(CHGVAR VAR(&OUTQ) VALUE('*JOB'))
               IF (&FORM = ' ') +
                 THEN(CHGVAR VAR(&FORM) VALUE('*STD'))

             select                                               /* (JFF A) */
             when       COND(&CLIENT = &JAKES) THEN(DO)           /* (JFF A) */
               CHGVAR     VAR(&OUTQ) VALUE('BFCEXCP')             /* (JFF A) */
             enddo                                                /* (JFF A) */
             endselect                                            /* (JFF A) */

/* Clear any existing messages and display working message. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* Override printer file */

             OVRPRTF    FILE(&PRTF) OUTQ(&OUTQ) FORMTYPE(&FORM)

/* Override import files to correct member */

             OVRDBF     FILE(&FILEH) TOFILE(*FILE) MBR(&MBR)
             OVRDBF     FILE(&FILEHM) TOFILE(*FILE) MBR(&MBR)
             OVRDBF     FILE(&FILED) TOFILE(*FILE) MBR(&MBR)
             OVRDBF     FILE(&FILEDM) TOFILE(*FILE) MBR(&MBR)
             IF         COND(&OTYPE = '*SARTE5') THEN(DO)
               OVRDBF     FILE(&FILEL) TOFILE(*FILE) MBR(&MBR)
             ENDDO

/* Import orders */

             CALL       PGM(&RPTPGM) PARM(&ORDTYPE &WHSE &TRUCK +
                              &RTID01 &RTID02 &RTID03 &RTID04 &RTID05 +
                              &RTID06 &RTID07 &RTID08 &RTID09 &RTID10)
             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */
/*             Reg. route imported, orders converted to will-call.   (DRY A) */
               IF         COND(&RTID01 *GT ' ' *AND &OTYPE *EQ +
                            '*ROUTE5') THEN(DO)                   /* (DRY A) */
                 CHGVAR     VAR(&OTYPE) VALUE('*WILL5')           /* (DRY A) */
               enddo                                              /* (DRY A) */
             enddo                                                /* (DRY A) */
             WHEN       COND(&CLIENT = &HMWAGNER) THEN(DO)        /* (HMWaA) */
/*             Reg. route indicated, but orders are will-call.       (HMWaA) */
               IF         COND(&ORDTYPE *EQ 'W' *AND &OTYPE *EQ +
                            '*ROUTE5') THEN(DO)                   /* (HMWaA) */
                 CHGVAR     VAR(&OTYPE) VALUE('*WILL5')           /* (HMWaA) */
               enddo                                              /* (HMWaA) */
             enddo                                                /* (HMWaA) */
             endselect                                            /* (DRY A) */

/* TEMP MOD for wagner, convert will calls to host picks */       /* (HMWbA) */
             IF (&OTYPE *EQ '*WILL5' *AND +
                 &CLIENT *EQ &HMWAGNER) THEN(DO)                  /* (HMWbA) */
               ADDPFM     FILE(IMPFPCKQ) MBR(&MBR)                /* (HMWbA) */
               OVRDBF     FILE(IMPFPCKQ) MBR(&MBR)                /* (HMWbA) */
               DLTOVR     FILE(IMPFPCKQ)                          /* (HMWbA) */
               CALL       PGM(HQ240CL) +
                            PARM(*PCKADJ &MBR *INTER *JOB *STD)   /* (HMWbA) */
             GOTO       CMDLBL(FINISHED)                          /* (HMWbA) */
             ENDDO                                                /* (HMWbA) */

/* For S.Bertram, if will call route 999, convert to MV adjs.*/   /* (SBRaA) */
             IF (&CLIENT *EQ &SBERTRAM) THEN(DO)                  /* (SBRaA) */
              CHGVAR     VAR(&WHSE3) VALUE(&WHSE)                 /* (SBRaA) */
              CALL       PGM(GETRTEHED) PARM(&WHSE3 +
                           &RTID01 &RTNAME &RTTYPE &RTSTAT)       /* (SBRaA) */
              IF (&RTNAME *EQ '999  ' *AND +
                  &RTTYPE *EQ 'W') THEN(DO)                       /* (SBRaA) */
               ADDPFM     FILE(IMPFPCKQ) MBR(&MBR)                /* (SBRaA) */
               OVRDBF     FILE(IMPFPCKQ) MBR(&MBR)                /* (SBRaA) */
               CALL       PGM(HQ243) PARM(&WHSE3 &RTID01)         /* (SBRaA) */
               DLTOVR     FILE(IMPFPCKQ)                          /* (SBRaA) */
               CALL       PGM(HQ240CL) +
                            PARM(*PCKADJ &MBR *INTER *JOB *STD)   /* (SBRaA) */
               GOTO       CMDLBL(FINISHED)                        /* (SBRaA) */
              ENDDO                                               /* (SBRaA) */
             ENDDO                                                /* (SBRaA) */

/* Allocate, pick and print will call orders. */

             IF (&OTYPE *EQ '*WILL5') THEN(DO)
             CHGVAR     VAR(&COUNT) VALUE(0)
 WLOOP:
             CHGVAR     VAR(&COUNT) VALUE(&COUNT + 1)
             IF (&COUNT *GT 10) THEN(GOTO FINISHED)
             IF (&COUNT *EQ 1) THEN(CHGVAR VAR(&RTID) VALUE(&RTID01))
             IF (&COUNT *EQ 2) THEN(CHGVAR VAR(&RTID) VALUE(&RTID02))
             IF (&COUNT *EQ 3) THEN(CHGVAR VAR(&RTID) VALUE(&RTID03))
             IF (&COUNT *EQ 4) THEN(CHGVAR VAR(&RTID) VALUE(&RTID04))
             IF (&COUNT *EQ 5) THEN(CHGVAR VAR(&RTID) VALUE(&RTID05))
             IF (&COUNT *EQ 6) THEN(CHGVAR VAR(&RTID) VALUE(&RTID06))
             IF (&COUNT *EQ 7) THEN(CHGVAR VAR(&RTID) VALUE(&RTID07))
             IF (&COUNT *EQ 8) THEN(CHGVAR VAR(&RTID) VALUE(&RTID08))
             IF (&COUNT *EQ 9) THEN(CHGVAR VAR(&RTID) VALUE(&RTID09))
             IF (&COUNT *EQ 10) THEN(CHGVAR VAR(&RTID) VALUE(&RTID10))
             IF (&RTID *EQ ' ') THEN(GOTO FINISHED)
             CALL    PGM(RH220) PARM(&WHSE &TRUCK &TYPE &SBMPGM +
                          &RTID &RETURN)
             GOTO WLOOP
             ENDDO

 FINISHED:
             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVM       FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
             RMVM       FILE(&FILEHM) MBR(&MBR)
             MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
             RMVM       FILE(&FILED) MBR(&MBR)
             MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
             RMVM       FILE(&FILEDM) MBR(&MBR)
             MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
             IF         COND(&OTYPE = '*SARTE5') THEN(DO)
               RMVM       FILE(&FILEL) MBR(&MBR)
               MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                            CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
             ENDDO

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
               OVRPRTF    FILE(QPJOBLOG) OUTQ(QEZJOBLOG)          /* (530 A) */
               DSPJOBLOG  OUTPUT(*PRINT)                          /* (530 A) */
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
