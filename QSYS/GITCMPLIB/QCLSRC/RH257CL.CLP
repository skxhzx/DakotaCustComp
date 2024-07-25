/*-------------------------------------------------------------------*/
/*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH257CL   FTP export closed willcall orders - Host executed      */
/*  09 May 2002                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    05/09/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    07/21/06  MLB  5.10                                            */
/*      - Enh: Added client custom code support to program.          */
/*    07/21/06  MLB  5.10a                                           */
/*      - Enh: Added support to program to export to additional      */
/*        files, EXPFORDB, EXPFORDE.                                 */
/*    05/17/07  RBD  5.10b                                           */
/*      - Added new order detail label# export file EXPFORDL.        */
/*    06/20/07  DAS  5.10c                                           */
/*      - Added new order detail piece seq# export file EXPFORDP.    */
/*    04/16/08  RBD  5.20  P#00011                                   */
/*      - Added new order detail ASN SSCC-18 export file EXPFORDASN. */
/*    08/10/12  LMC  6.40                                            */
/*      - Added new order detail LOT export file EXPFORDO.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*    This program can be used instead of having Truck Builder       */
/*    automatically ftp the exported orders to the host system.      */
/*    If this program is used then the EXPORD script should have     */
/*    '*NO EXPORT*' at the top of it to prevent the file from being  */
/*    ftp's from Truck Builder.                                      */
/*                                                                   */
/*    Now, with this program, the host can perform the ftp export    */
/*    by doing a remote program call.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    QUOTE RCMD PIR/FTPLIBL *PROD                                   */
/*    QUOTE RCMD RH157CL ('001')                                     */
/*    GET PIRF/EXPFORDH.WILLCALL C:\TRANSFER400\WILLCALLH.TXT        */
/*    GET PIRF/EXPFORDD.WILLCALL C:\TRANSFER400\WILLCALLD.TXT        */
/*    GET PIRF/EXPFORDC.WILLCALL C:\TRANSFER400\WILLCALLC.TXT        */
/*    GET PIRF/EXPFORDT.WILLCALL C:\TRANSFER400\WILLCALLT.TXT        */
/*    GET PIRF/EXPFORDB.WILLCALL C:\TRANSFER400\ROUTEB.TXT   (510aA) */
/*    GET PIRF/EXPFORDE.WILLCALL C:\TRANSFER400\ROUTEE.TXT   (510aA) */
/*    DEL PIRF/EXPFORDH.WILLCALL                                     */
/*    DEL PIRF/EXPFORDD.WILLCALL                                     */
/*    DEL PIRF/EXPFORDC.WILLCALL                                     */
/*    DEL PIRF/EXPFORDT.WILLCALL                                     */
/*    DEL PIRF/EXPFORDB.WILLCALL                             (510aA) */
/*    DEL PIRF/EXPFORDE.WILLCALL                             (510aA) */
/*                                                                   */
/*    Note: The DEL statements are optional. This program will       */
/*          automatically initialize the ROUTE members.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program is to be used by a host ftp script.                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH257CL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(8) +
                          VALUE('CITYLINE')                       /* (CLD A) */
             DCL        VAR(&EI)     TYPE(*CHAR) LEN(8) +
                          VALUE('EI')                             /* (EI  A) */
             DCL        VAR(&CBI)     TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (510bA) */

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORDERR')

  /* Export files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDD')
             DCL        VAR(&FILEC) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDC')
             DCL        VAR(&FILET) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDT')
             DCL        VAR(&FILEb) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDB')                       /* (510aA) */
             DCL        VAR(&FILEe) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDE')                       /* (510aA) */
             DCL        VAR(&FILEL) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDL')                       /* (510bA) */
             DCL        VAR(&FILEP) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDP')                       /* (510cA) */
             DCL        VAR(&FILEA) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDASN')                     /* (520 A) */
             DCL        VAR(&FILEF) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDO')                       /* (640 A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXISTC)     TYPE(*LGL)
             DCL        VAR(&EXISTD)     TYPE(*LGL)
             DCL        VAR(&EXISTH)     TYPE(*LGL)
             DCL        VAR(&EXISTT)     TYPE(*LGL)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&LOCK)       TYPE(*LGL)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR2GET)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&SAVMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (510 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (510 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member names to be used */

             CHGVAR     VAR(&MBR) VALUE('W' *CAT &WHSE)

             CHGVAR     VAR(&MBR2GET) VALUE('WILLCALL')

/* Lock dataarea to prevent users from exporting routes */

             CHGVAR     VAR(&LOCK) VALUE('0')
             CHKINOUT   TYPE(*IN) DTAARA(EXPORD)
             MONMSG     MSGID(CPF9898) EXEC(DO)
               CHGVAR     VAR(&LOCK) VALUE('1')
             ENDDO

/* Create members for export files. Reuse them if they exist. */

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR2GET)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEH) +
                          MBR(&MBR2GET))

             CHKOBJ     OBJ(&FILED) OBJTYPE(*FILE) MBR(&MBR2GET)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILED) +
                          MBR(&MBR2GET))

             CHKOBJ     OBJ(&FILEC) OBJTYPE(*FILE) MBR(&MBR2GET)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEC) +
                          MBR(&MBR2GET))

             CHKOBJ     OBJ(&FILET) OBJTYPE(*FILE) MBR(&MBR2GET)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILET) +
                          MBR(&MBR2GET))

             CHKOBJ     OBJ(&FILEB) OBJTYPE(*FILE) MBR(&MBR2GET)  /* (510aA) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEB) +
                          MBR(&MBR2GET))                          /* (510aA) */

             CHKOBJ     OBJ(&FILEE) OBJTYPE(*FILE) MBR(&MBR2GET)  /* (510aA) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEE) +
                          MBR(&MBR2GET))                          /* (510aA) */

             CHKOBJ     OBJ(&FILEL) OBJTYPE(*FILE) MBR(&MBR2GET)  /* (510bA) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEL) +
                          MBR(&MBR2GET))                          /* (510bA) */

             CHKOBJ     OBJ(&FILEP) OBJTYPE(*FILE) MBR(&MBR2GET)  /* (510cA) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEP) +
                          MBR(&MBR2GET))                          /* (510cA) */

             CHKOBJ     OBJ(&FILEA) OBJTYPE(*FILE) MBR(&MBR2GET)  /* (520 A) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEA) +
                          MBR(&MBR2GET))                          /* (520 A) */

             CHKOBJ     OBJ(&FILEF) OBJTYPE(*FILE) MBR(&MBR2GET)  /* (640 A) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEF) +
                          MBR(&MBR2GET))                          /* (640 A) */

/* Clear members */

             CLRPFM     FILE(&FILEH) MBR(&MBR2GET)
             CLRPFM     FILE(&FILED) MBR(&MBR2GET)
             CLRPFM     FILE(&FILEC) MBR(&MBR2GET)
             CLRPFM     FILE(&FILET) MBR(&MBR2GET)
             CLRPFM     FILE(&FILEB) MBR(&MBR2GET)                /* (510aA) */
             CLRPFM     FILE(&FILEE) MBR(&MBR2GET)                /* (510aA) */
             CLRPFM     FILE(&FILEL) MBR(&MBR2GET)                /* (510bA) */
             CLRPFM     FILE(&FILEP) MBR(&MBR2GET)                /* (510cA) */
             CLRPFM     FILE(&FILEA) MBR(&MBR2GET)                /* (520 A) */
             CLRPFM     FILE(&FILEF) MBR(&MBR2GET)                /* (640 A) */

/* Can't proceed if export already in progress */

             IF COND(&LOCK) THEN(DO)

               OVRDBF     FILE(&FILEH) MBR(&MBR2GET)
               CALL       PGM(RH157) PARM('*IN USE*')
               DLTOVR     FILE(&FILEH)

               RMVMSG     CLEAR(*ALL)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export in progress. Files cannot +
                          be retrieved at this time') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export in progress. Files cannot +
                          be retrieved at this time') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

               CHGVAR     VAR(&FINISHED) VALUE('1')

               GOTO BOTTOM

             ENDDO

/* Can't proceed if there are no records in header file */

   /* Don't write message. Clutters up message file if host is  */
   /* running a never-ending-job that checks every few minutes. */

             RTVMBRD    FILE(&FILEH) MBR(&MBR) NBRCURRCD(&RECS)
             MONMSG     MSGID(CPF0000) EXEC(CHGVAR VAR(&RECS) VALUE(0))

             IF COND(&RECS = 0) THEN(DO)

               OVRDBF     FILE(&FILEH) MBR(&MBR2GET)
               CALL       PGM(RH157) PARM('*NO RECS*')
               DLTOVR     FILE(&FILEH)

               RMVMSG     CLEAR(*ALL)
          /*   SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) + */
          /*              MSGDTA('Nothing to export') +       */
          /*              TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)     */

          /*   SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) + */
          /*              MSGDTA('Nothing to export') +       */
          /*              TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)  */

               CHGVAR     VAR(&FINISHED) VALUE('1')

               GOTO BOTTOM

             ENDDO

/* Copy records from Truck Builder member into GET member */

             CPYF       FROMFILE(&FILEH) TOFILE(&FILEH) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)

             CPYF       FROMFILE(&FILED) TOFILE(&FILED) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)

             CPYF       FROMFILE(&FILEC) TOFILE(&FILEC) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)

             CPYF       FROMFILE(&FILET) TOFILE(&FILET) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)

             CPYF       FROMFILE(&FILEB) TOFILE(&FILEB) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)                            /* (510aA) */

             CPYF       FROMFILE(&FILEE) TOFILE(&FILEE) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)                            /* (510aA) */

             CPYF       FROMFILE(&FILEL) TOFILE(&FILEL) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)                            /* (510bA) */

             CPYF       FROMFILE(&FILEP) TOFILE(&FILEP) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)                            /* (510cA) */

             CPYF       FROMFILE(&FILEA) TOFILE(&FILEA) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)                            /* (520 A) */

             CPYF       FROMFILE(&FILEF) TOFILE(&FILEF) +
                          FROMMBR(&MBR) TOMBR(&MBR2GET) +
                          MBROPT(*ADD)                            /* (640 A) */

/* Clear Truck Builder members */

             CLRPFM     FILE(&FILEH) MBR(&MBR)
             CLRPFM     FILE(&FILED) MBR(&MBR)
             CLRPFM     FILE(&FILEC) MBR(&MBR)
             CLRPFM     FILE(&FILET) MBR(&MBR)
             CLRPFM     FILE(&FILEB) MBR(&MBR)                    /* (510aA) */
             CLRPFM     FILE(&FILEE) MBR(&MBR)                    /* (510aA) */
             CLRPFM     FILE(&FILEL) MBR(&MBR)                    /* (510bA) */
             CLRPFM     FILE(&FILEP) MBR(&MBR)                    /* (510cA) */
             CLRPFM     FILE(&FILEA) MBR(&MBR)                    /* (520 A) */
             CLRPFM     FILE(&FILEF) MBR(&MBR)                    /* (640 A) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Send Successful message */

             RMVMSG     CLEAR(*ALL)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             GOTO BOTTOM

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

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

/* Unlock dataarea */

             CHKINOUT   TYPE(*OUT) DTAARA(EXPORD)

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

             ENDPGM
