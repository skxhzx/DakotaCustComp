/*-------------------------------------------------------------------*/
/*   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV531CL   Post inventory counts - FTP export - Send              */
/*  02 March 2000                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    4/27/00  DAS  4.14                                             */
/*     - Fixed check for file FTPEXPLOG                              */
/*                                                                   */
/*    09/13/00  DAS  4.14a                                           */
/*      - Revised to use export script EXPFADJ instead of DEFAULT.   */
/*      - Revised to check script for *NO EXPORT*.                   */
/*                                                                   */
/*    07/14/06  MLB  5.10                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC                                     */
/*                                                                   */
/*    02/22/07  MLB  TPC                                             */
/*      - Revised program to call GETEXP# for use in creating        */
/*        remote export file name.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Coastal Sunbelt Produce                 */
/*                                                                   */
/*    04/26/10  MLB  CSP                                             */
/*      - Revised program to create a unique remote file name when   */
/*        sending the physical inventory counts to the Host.         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will create a unique member name and then create   */
/*   new members in all of the export files and in the FTP script    */
/*   and log files.                                                  */
/*                                                                   */
/*   The remote file name will start with the member name and        */
/*   have an extension of QTY.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV531CL:    PGM        PARM(&WHSE &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&TPC)     TYPE(*CHAR) LEN(8) +
                          VALUE('TPC')                            /* (TPC A) */
             DCL        VAR(&CoastalSun) TYPE(*CHAR) LEN(10) +
                          VALUE('COASTALSUN')                     /* (CSP A) */

  /* Export script */  /* 414aA */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFCNT)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPCNT')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPCNTERR')

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFCNT')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFNBR)    TYPE(*CHAR) LEN(1)       /* (TPC A) */
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414aA */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FRMT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&INCL)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RFLAG)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(4)       /* (CSP A) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (510 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (510 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('IV531CL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member name */

             IF         COND(&CLIENT = &COASTALSUN) THEN(DO)      /* (CSP A) */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)              /* (CSP A) */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)            /* (CSP A) */
               CHGVAR     VAR(&MBR) VALUE('C' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                        /* (CSP A) */
             ENDDO                                                /* (CSP A) */
             Else cmd(DO)                                         /* (CSP A) */
       /*    CALL       PGM(PIRFTP#) PARM(&NXTNUM)     */
       /*    CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)   */
             CHGVAR     VAR(&MBR) VALUE('C' *CAT &WHSE)
             ENDDO                                                /* (CSP A) */

/* Check if we should export file to host system */  /* 414aA */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)
             DLTOVR     FILE(FTPEXPDFT)
             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP)

/* Create members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating export script from +
                          member' *BCAT &MBR) TOPGMQ(*PRV) +
                          MSGTYPE(*STATUS)

     /*      CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)  414D */
             CHKOBJ     OBJ(FTPEXPLOG) OBJTYPE(*FILE) MBR(&MBR) /* 414M */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(FTPEXPLOG) +
                          MBR(&MBR))
             CLRPFM     FILE(FTPEXPLOG) MBR(&MBR)
             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/' *CAT &FILE *TCAT '.' *CAT &MBR)

             IF         COND(&client *eq &TPC) THEN(DO)           /* (TPC A) */
               CALL       PGM(GETEXP#) PARM('*INVCNT' &EXPFNBR)   /* (TPC A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('wmih' *CAT &expfnbr) +
                                                                  /* (TPC A) */
             ENDDO                                                /* (TPC A) */

             ELSE       CMD(IF COND(&CLIENT *EQ &COASTALSUN) THEN(DO)) +
                                                                  /* (CSP A) */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)              /* (CSP A) */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)            /* (CSP A) */
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&NXTNUMA 4 4)) +
                                                                  /* (CSP A) */
               CHGVAR     VAR(&RMTFILEH) VALUE(&file *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (CSP A) */
             ENDDO                                                /* (CSP A) */
             else cmd(DO)                                         /* (TPC A) */

             CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT '.Qty')
    /*       CHGVAR     VAR(&RMTFILEH) VALUE(&FILE *TCAT +       */
    /*                    %SST(&WHSE 2 2) *CAT '.Txt')           */
      ENDDO                                                       /* (TPC A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*INVCNT')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)

             DLTOVR     FILE(FTPEXPSCRP)

             RMVMSG     CLEAR(*ALL)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export files using FTP for +
                          member' *BCAT &MBR) TOPGMQ(*PRV) +
                          MSGTYPE(*STATUS)

             OVRDBF     FILE(INPUT) TOFILE(*LIBL/FTPEXPSCRP) MBR(&MBR)
             OVRDBF     FILE(OUTPUT) TOFILE(*LIBL/FTPEXPLOG) MBR(&MBR)

             FTP        RMTSYS(DUMMYSYSTEM)

             DLTOVR     FILE(INPUT OUTPUT)

/* Now check FTP log file for errors */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking FTP log for errors') +
                          TOPGMQ(*PRV) MSGTYPE(*STATUS)

             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR &PGM +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* This is the place to skip to if script had *NO EXPORT* */ /* 414A */

SKIPFTP:

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */  /* 414aA */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP2)

             RMVM       FILE(&FILE) MBR(&MBR)
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)

SKIPFTP2:                                                /* 414aA */

             RMVMSG     CLEAR(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) MSGTYPE(*INFO) KEYVAR(&MSGKEY)

             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             CHGVAR     VAR(&RTN) VALUE('*PGMQ')
             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOPGMQ(*SAME (IV505)) MSGTYPE(*INFO) +
                          KEYVAR(&MSGKEY)
             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) MSGTYPE(*COMP)

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

             IF COND(&TYPE = '0') THEN(DO)

               RCLRSC     LVL(*CALLER)

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

             ENDDO

             ENDPGM
