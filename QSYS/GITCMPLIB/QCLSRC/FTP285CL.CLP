/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP285CL   Retry returns FTP export from member                  */
/*  07 July 1999                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    02/20/13  MLB  6.50                                            */
/*      - Enh: Added client custom code support to program.          */
/*    02/21/13  MLB  6.50a                                           */
/*      - Fix: Added logic to pgm to bypass actual FTP processing    */
/*        if module setup for *NO EXPORT*.                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    12/31/10  MLB  DRY                                             */
/*      - Revised program to call BFCERT01C to process exported      */
/*        cutomer returns.                                           */
/*    12/31/10  MLB  DRYa                                            */
/*      - Revised mod, DRY to pass retrieved Dakota data files       */
/*        library name to Host interface program.                    */
/*    07/22/11  MLB  DRYb                                            */
/*      - Revised program to call Dairyland program, MTHENDCHKR      */
/*        to see if any period end processes are active. If pgm      */
/*        returns value of 1=Period end processing active, send      */
/*        message to user and cancel export. Per email from Kelly R. */
/*    08/31/11  MLB  DRYc                                            */
/*      - Revised mod, DRY to retrieve number of rcds in EXPFRTN.    */
/*        Only call BFCERT01C if export RTN rcds greater than zero.  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP285CL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (650 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Retry returns export')

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPRTN')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPRTNERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFRTN')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)       /* (650aA) */
             DCL        VAR(&EXPSCRP)    TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFRTN)                          /* (650aA) */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MonthEnd)   TYPE(*CHAR) LEN(1)       /* (DRYbA) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NBRCURRCDS) TYPE(*DEC)  LEN(10 0)    /* (DRYcA) */
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNH)       TYPE(*CHAR) LEN(8)       /* (DRY A) */
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(10)      /* (DRYaM) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEN)      TYPE(*DEC)  LEN(3 0)     /* (DRY A) */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (650 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (650 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

             SELECT                                               /* (DRYbA) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRYbA) */

               CALL       PGM(&HOSTLIB/MTHENDCHKR)  PARM('00' +
                            &MonthEnd)                            /* (DRYbA) */
               Select                                             /* (DRYbA) */
/*             Period end processing active, cancel export.          (DRYbA) */
               When       COND(&MonthEnd *eq '1') THEN(DO)        /* (DRYbA) */
                 SNDPGMMSG  MSG('Period end processing active. Export +
                              customer returns Cancelled.') TOPGMQ(*EXT) +
                                                                  /* (DRYbA) */
                Return                                            /* (DRYbA) */
               ENDDO                                              /* (DRYbA) */
               ENDSELECT                                          /* (DRYbA) */

             ENDDO                                                /* (DRYbA) */
             ENDSELECT                                            /* (DRYbA) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(FTP285) PARM(&MBR &RTN)

/*  See if user wants to proceed. */

             IF         COND((&RTN *EQ '*CANCEL') *OR (&RTN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/* See if we do the actual ftp to host system                     /* (650aA) */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)             /* (650aA) */
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)             /* (650aA) */
             DLTOVR     FILE(FTPEXPDFT)                           /* (650aA) */

/*  Make sure members exist                                          */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking for member' *BCAT &MBR +
                          *TCAT ' in export files') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             IF         COND(&EXPFLAG = '*NOEXP') THEN(DO)        /* (650aA) */
               GOTO SKIPFTP                                       /* (650aA) */
             ENDDO                                                /* (650aA) */

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

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFRTN.' *CAT &MBR)

    /*       CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT '.Qty')  */
             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFRTN.Txt')

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*RETURNS')
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

             CHGVAR     VAR(&EXPTYPE) VALUE('*RETURNS')
             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR 'FTP285CL' +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* This is the place to skip to if script had *NO EXPORT*         /* (650aA) */

SKIPFTP:                                                          /* (650aA) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */

               RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&RUNTIMEENV) +
                            NBRCURRCD(&NBRCURRCDS)                /* (DRYcM) */

/*           Call Dairyland Interface Pgm.                           (DRY A) */
             IF         COND(&NBRCURRCDS > 0) THEN(DO)            /* (DRYcA) */
                                                                  /* (DRYcA) */
               CHGVAR     VAR(&WHSEN) VALUE(&WHSE)                /* (DRY A) */
               CALL       PGM(&HOSTLIB/BFCERT01C) PARM(&WHSEN +
                            &MBR &RUNTIMEENV &RTNH)               /* (DRY A) */
               MONMSG     MSGID(CPF0001) EXEC(CHGVAR VAR(&FINISHED) +
                            VALUE('0'))                           /* (DRY A) */
               SELECT                                             /* (DRY A) */
/*             Set flag for export mbr cleanup.                      (DRY A) */
               When       COND(&RTNH *EQ '*OK') THEN(DO)          /* (DRY A) */
                 CHGVAR     VAR(&FINISHED) VALUE('1')             /* (DRY A) */
                 CHGVAR     VAR(&EXPFLAG) VALUE(&RTNH)            /* (DRY A) */
               ENDDO                                              /* (DRY A) */

/*             Set flag for export failure, leave mbrs behind.       (DRY A) */
               When       COND(&RTNH *NE '*OK') THEN(DO)          /* (DRY A) */
                 CHGVAR     VAR(&FINISHED) VALUE('0')             /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRYcA) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

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
