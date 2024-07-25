/*-------------------------------------------------------------------*/
/*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   24 N. Washington Ave Suite 203                                  */
/*   Batavia, IL 60510                                               */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PI400CL   Import FTP Purchase Orders - Multi-Warehouse           */
/*  07 March 2012                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    03/11/12  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/09/13  MLB  6.50                                            */
/*      - Enh: Revised program to run cmd DSPJOBLOG *PRINT when      */
/*        pgm, PI405 ends in error. Output will be directed to outq  */
/*        BFCEXCP.                                                   */
/*    08/31/13  MLB  6.50a                                           */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    08/31/13  MLB  DRY                                             */
/*      - Revised pgm to add member to logical files, IMPFPOH2M1     */
/*       and IMPFPOHMM1 and remove them at pgm end. LF's needed      */
/*       due to changes in how JDEdwards sends purchase orders.      */
/*       File IMPFPOD2M will be the primary input file.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD   -  *PO2MP - P/O Import Multi-Warehouse Production       */
/*              *PO2MT - P/O Import Multi-Warehouse Test             */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*    &RUN   -  *INTER  Run interactively                            */
/*              *JOBQ   Run on Jobq                                  */
/*    &OUTQ  -  Printer output queue (Default is *JOB)               */
/*    &FORM  -  Printer form (Default is *STD)                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    PUT localpoh PIRFTPF/IMPFPOH2M.P123456789                      */
/*    PUT localpod PIRFTPF/IMPFPOD2M.P123456789                      */
/*    PUT localpohm PIRFTPF/IMPFPOHMM.P123456789                     */
/*    PUT localpodm PIRFTPF/IMPFPODMM.P123456789                     */
/*    QUOTE RCMD PIRFTP/FTPLIBL *MLTP or *MLTT                       */
/*    QUOTE RCMD PIRFTPIMP (*PO2MP P123456789 *INTER *JOB *STD)      */
/*                                                                   */
/*     where P123456789 is the unique member name                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - Member name must be unique for each PUT operation.  If not,   */
/*     PUT will delete any existing information and replace it       */
/*     with the new information.                                     */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.                                                    */
/*                                                                   */
/*   - Do not use date and/or time to make the member name unique.   */
/*     There is always a possibility that two terminals processing   */
/*     will call orders will generate the same date/time.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   A single member may contain P.O.'s for one or more warehouses.  */
/*   The P.O.'s must all be going to Production or Test environment  */
/*   warehouses.  Test and Production P.O.'s cannot be mixed in      */
/*   the same batch.  Pgm PI410 will perform all of the member add   */
/*   processing prior to writing all of the warehouses' records to   */
/*   the necessary import files. Each warehouse will utilize the     */
/*   same member name that the import batch was renamed prior to     */
/*   PI400CL being called from PIRFTPIMP.                            */
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
/*   which means it looks like a batch job.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PI400CL:    PGM        PARM(&CMD &MBR &RUN &OUTQ &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */

  /* Client ID's.    */                                           /* (650aA) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PI400CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PI400)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PI405)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(PI405PR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) +
                          VALUE(PI4051PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import FTP purchase orders - Multi-Warehouse')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                       VALUE('Importing FTP purchase orders - Multi-Warehouse')

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPPO')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPPOERR')

  /* Import files */

             DCL        VAR(&FILEH2M) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPOH2M')
             DCL        VAR(&FILEH2M1) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPOH2M1')                     /* (DRY A) */
             DCL        VAR(&FILEHMM) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPOHMM')
             DCL        VAR(&FILEHMM1) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPOHMM1')                     /* (DRY A) */
             DCL        VAR(&FILED2M) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPOD2M')
             DCL        VAR(&FILEDMM) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFPODMM')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (650aA) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (650aA) */
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
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
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RUN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (650aA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (650aA) */

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

             CALL       PGM(&OPTPGM) PARM(&RETURN &CMD &MBR &OUTQ &FORM)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

 SKIP1:

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILEH2M) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILED2M) OBJTYPE(*FILE) MBR(&MBR)
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

             CHKOBJ     OBJ(&FILEH2M) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILED2M) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

             IF         COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */
               ADDLFM     FILE(&FILEH2M1) MBR(&MBR)                   +
                            DTAMBRS((&FILEH2M (&MBR)))            /* (DRY A) */
               MONMSG     MSGID(CPF7306) /* Ignore not added.        (DRY A) */
               ADDLFM     FILE(&FILEHMM1) MBR(&MBR) +
                            DTAMBRS((&FILEHMM (&MBR)))            /* (DRY A) */
               MONMSG     MSGID(CPF7306) /* Ignore not added.        (DRY A) */
             enddo                                                /* (DRY A) */

/* Make sure &OUTQ and &FORM are not blank */

               IF (&OUTQ = ' ') +
                 THEN(CHGVAR VAR(&OUTQ) VALUE('*JOB'))
               IF (&FORM = ' ') +
                 THEN(CHGVAR VAR(&FORM) VALUE('*STD'))

/* Clear any existing messages and display working message. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* Override printer file */

             OVRPRTF    FILE(&PRTF) OUTQ(&OUTQ) FORMTYPE(&FORM)

/* Override import files to correct multi-whse member */

             OVRDBF     FILE(&FILEH2M)  TOFILE(&FILEH2M) MBR(&MBR)
             OVRDBF     FILE(&FILEHMM)  TOFILE(&FILEHMM) MBR(&MBR)
             OVRDBF     FILE(&FILED2M)  TOFILE(&FILED2M) MBR(&MBR)
             OVRDBF     FILE(&FILEDMM)  TOFILE(&FILEDMM) MBR(&MBR)

             IF         COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */
               OVRDBF   FILE(&FILEH2M1) TOFILE(&FILEH2M1) MBR(&MBR) +
                                                                  /* (DRY A) */
               OVRDBF   FILE(&FILEHMM1) TOFILE(&FILEHMM1) MBR(&MBR) +
                                                                  /* (DRY A) */
             enddo                                                /* (DRY A) */

/* Import purchase orders - Multi-Warehouse */

             CALL       PGM(&RPTPGM) Parm(&CMD &MBR &OUTQ &FORM)

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             CLOF       OPNID(&FILEH2M)
             MONMSG     MSGID(CPF4519 CPF4520)
             CLOF       OPNID(&FILED2M)
             MONMSG     MSGID(CPF4519 CPF4520)
             CLOF       OPNID(&FILEHMM)
             MONMSG     MSGID(CPF4519 CPF4520)
             CLOF       OPNID(&FILEDMM)
             MONMSG     MSGID(CPF4519 CPF4520)

             IF         COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */
               CLOF     OPNID(&FILEH2M1)                          /* (DRY A) */
               MONMSG     MSGID(CPF4519 CPF4520)                  /* (DRY A) */
               CLOF     OPNID(&FILEHMM1)                          /* (DRY A) */
               MONMSG     MSGID(CPF4519 CPF4520)                  /* (DRY A) */

               RMVM       FILE(&FILEH2M1) MBR(&MBR)               /* (DRY A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (DRY A) */
               RMVM       FILE(&FILEHMM1) MBR(&MBR)               /* (DRY A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (DRY A) */
             enddo                                                /* (DRY A) */

             RMVM       FILE(&FILEH2M) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)
             RMVM       FILE(&FILEHMM) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)
             RMVM       FILE(&FILED2M) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)
             RMVM       FILE(&FILEDMM) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)
             RMVMSG     CLEAR(*ALL)

/*  Send 'Successful message */

             IF COND(&FINISHED = '1') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Mult-Whse Import successful for' *BCAT &MBR +
                          *TCAT '/' *CAT &RUN *TCAT '/' *CAT &JOB +
                          *TCAT '/' *CAT &USER) TOMSGQ(&FTPMSGQ) +
                          MSGTYPE(*INFO)
             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Mult-Whse Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT &JOB *TCAT '/' *CAT +
                          &USER) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Mult-Whse Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT &JOB *TCAT '/' *CAT +
                          &USER) TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)
               OVRPRTF    FILE(QPJOBLOG) OUTQ(BFCEXCP)            /* (650 A) */
               DSPJOBLOG  OUTPUT(*PRINT)                          /* (650 A) */
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
