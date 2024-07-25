/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP255CL   Retry item adjustment FTP export from member          */
/*  04 July 1999                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    08/31/09  MLB  5.20                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Springfield Grocery                     */
/*                                                                   */
/*    08/31/09  MLB  SGC                                             */
/*      - Revised program to use EXPFADJS instead of EXPFADJ.        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: European Imports                        */
/*                                                                   */
/*    04/11/12  MLB  EI                                              */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFADJxxxx.txt where xxxx is            */
/*        a unique number.                                           */
/*    08/31/09  MLB  EIa                                             */
/*      - Revised program to use EXPFADJS instead of EXPFADJ.        */
/*      - Added EIa to SGC mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Colony Foods                            */
/*                                                                   */
/*    07/19/18  MLB  CFI                                             */
/*      - Revised program to use EXPFADJS instead of EXPFADJ.        */
/*      - Added CFI to SGC mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP255CL:   PGM

  /* Client ID's.    */                                           /* (520 A) */

             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')                            /* (SGC A) */
             DCL        VAR(&EI )     TYPE(*CHAR) LEN(10) +
                          VALUE('EI ')                            /* (EI  A) */
             DCL        VAR(&CFI)     TYPE(*CHAR) LEN(10) +
                          VALUE('COLONYFOOD')                     /* (CFI A) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Retry item adjustment export')

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPADJ')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPADJERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFADJ')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(4)       /* (EI  A) */
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (520 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (520 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(FTP255) PARM(&MBR &RTN)

/*  See if user wants to proceed. */

             IF         COND((&RTN *EQ '*CANCEL') *OR (&RTN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  Make sure members exist                                          */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking for member' *BCAT &MBR +
                          *TCAT ' in export files') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/*           If         COND(&CLIENT = &SGC) THEN(DO)             /* (EI  D) */
             If         COND(&CLIENT = &SGC +
                        *or  &CLIENT = &CFI +
                        *or  &CLIENT = &EI) THEN(DO)              /* (CFI M) */
               CHGVAR     VAR(&FILE) VALUE('EXPFADJS')            /* (SGC A) */
             Enddo                                                /* (SGC A) */
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)

/* Initializing members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Initializing member' *BCAT &MBR +
                          *TCAT ' in FTP script and log files') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF3141) EXEC(DO)
               ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)
             ENDDO

             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             RMVMSG     CLEAR(*ALL)

/* Retrieve library names for files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating FTP export script') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             IF         COND(&CLIENT *EQ &EI +
                                                ) THEN(DO)        /* (EI  A) */
               CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                            '/EXPFADJS.' *CAT &MBR)               /* (EI  A) */
             ENDDO                                                /* (EI  A) */
             ELSE CMD(DO)                                         /* (EI  A) */
             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFADJ.' *CAT &MBR)
             ENDDO                                                /* (EI  A) */

             IF         COND(&CLIENT *EQ &EI +
                                                ) THEN(DO)        /* (EI  A) */
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&MBR 7 4))   /* (EI  A) */
                                                                  /* (EI  A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFADJ' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
             ENDDO                                                /* (EI  A) */
             ELSE CMD(DO)                                         /* (EI  A) */
       /*    CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT '.Adj')  */
             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFADJ.Txt')
             ENDDO                                                /* (EI  A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*ADJ')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)

             DLTOVR     FILE(FTPEXPSCRP)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking FTP export log') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             OVRDBF     FILE(INPUT) TOFILE(*LIBL/FTPEXPSCRP) MBR(&MBR)
             OVRDBF     FILE(OUTPUT) TOFILE(*LIBL/FTPEXPLOG) MBR(&MBR)

             FTP        RMTSYS(DUMMYSYSTEM)

             DLTOVR     FILE(INPUT OUTPUT)

/* Now check FTP log file for errors */

             CHGVAR     VAR(&EXPTYPE) VALUE('*ADJ')
             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR 'FTP255CL' +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVM       FILE(&FILE) MBR(&MBR)
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             RMVMSG     CLEAR(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR) +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR) +
                          MSGTYPE(*INFO)
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

             RCLRSC     LVL(*CALLER)
             ENDPGM
