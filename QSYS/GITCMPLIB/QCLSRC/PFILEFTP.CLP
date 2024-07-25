/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PFILEFTP  Truck build picking labels - Export file ftp           */
/*  31 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    8/31/00  DAS  4.14                                             */
/*     - Created                                                     */
/*                                                                   */
/*    09/13/00  DAS  4.14a                                           */
/*      - Revised to use export script EXPFADJ instead of DEFAULT.   */
/*      - Revised to check script for *NO EXPORT*.                   */
/*                                                                   */
/*    12/17/13  RTR  6.50                                            */
/*      - Enh: Added client custom code support to program.          */
/*      - Added parms for whse, rte, rtid.                           */
/*                                                                   */
/*    05/27/16  RTR  7.00a                                           */
/*      - Fix: Changing route to alpha, fixing 650 mod.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:  Chef's Warehouse/Dairyland             */
/*                                                                   */
/*    12/17/13  RTR  DRY                                             */
/*      - Added call to Dairyland export program.                    */
/*    03/06/14  MLB  DRYa                                            */
/*      - Revised pgm to remove export mbr if successful.            */
/*    07/02/15  MLB  DRYb                                            */
/*      - Fix: Revised pgm to pass new &PRTE parm to Dairyland       */
/*        export program. v6.50 mod made &PRTE numeric.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*   Input                                                           */
/*                                                                   */
/*    &MBR    -  Member name                                         */
/*    &PWHSE  -  Warehouse                                           */
/*    &PRTE   -  Customer Route                                      */
/*    &PRTID  -  BFC Route ID                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will ftp an export file member to the host. The    */
/*   member name to be ftp'd is the route name.                      */
/*                                                                   */
/*   The remote file name will be the route name with an extension   */
/*   of PLB.                                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PFILEFTP:   PGM        PARM(&MBR &PWHSE &PRTE &PRTID)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (500 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */

  /* Export script */  /* 414aA */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFPLBL)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPLBL')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPLBLERR')

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPLBL')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414aA */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FRMT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
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
         /*  DCL        VAR(&PRTE)       TYPE(*DEC)  LEN(5 0)        (700aD) */
             DCL        VAR(&PRTE)       TYPE(*CHAR) LEN(5)       /* (700aM) */
             DCL        VAR(&PRTE_DRY)   TYPE(*CHAR) LEN(5)       /* (DRYbA) */
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PWHSE)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RFLAG)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNH)       TYPE(*CHAR) LEN(8)       /* (DRY A) */
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(10)      /* (DRY A) */
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (650 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (650 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('PFILEFTP')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member name */

       /*    CALL       PGM(PIRFTP#) PARM(&NXTNUM)     */
       /*    CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)   */
       /*    CHGVAR     VAR(&MBR) VALUE('L' *CAT %SST(&WHSE 2 2) + */
       /*                 *CAT &RTE)                               */

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
                          FROMMBR(&FILE) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/' *CAT &FILE *TCAT '.' *CAT &MBR)

             CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT '.PLB')

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*PCKLBL')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)

             DLTOVR     FILE(FTPEXPSCRP)

             RMVMSG     CLEAR(*ALL)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export file using FTP for +
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

             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */

               RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&RUNTIMEENV) /*(DRY A) */

/*           Call Dairyland Interface Pgm.                           (DRY A) */
               CHGVAR     VAR(&PRTE_DRY) VALUE(&PRTE)             /* (DRYbA) */
               CALL       PGM(&HOSTLIB/BFCELS01C) PARM(&PWHSE &PRTE_DRY +
                            &PRTID &MBR &RUNTIMEENV &RTNH)        /* (DRYbM) */
               MONMSG     MSGID(CPF0001) EXEC(CHGVAR VAR(&FINISHED) +
                            VALUE('0'))                           /* (DRY A) */
               SELECT                                             /* (DRY A) */
/*             Set flag for export mbr cleanup.                      (DRY A) */
               When       COND(&RTNH *EQ '*OK') THEN(DO)          /* (DRY A) */
                 CHGVAR     VAR(&EXPFLAG) VALUE(&RTNH)            /* (DRY A) */
               ENDDO                                              /* (DRY A) */

/*             Set flag for export failure, leave mbrs behind.       (DRY A) */
               When       COND(&RTNH *NE '*OK') THEN(DO)          /* (DRY A) */
                 CHGVAR     VAR(&FINISHED) VALUE('0')             /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */
               IF         COND(&FINISHED = '0' *OR &RTNH *NE '*OK') +
                            THEN(DO)                              /* (DRY A) */
                 OVRPRTF    FILE(QEZJOBLOG) TOFILE(QEZJOBLOG) OUTQ(BFCEXCP) +
                                                                  /* (DRY A) */
                 DSPJOBLOG  OUTPUT(*PRINT)                        /* (DRY A) */
               ENDDO                                              /* (DRY A) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */  /* 414aA */

             IF         COND(&client  = 'DAIRYLAND') THEN(DO)     /* (DRYaA) */
/*             Chef's Whse wants export mbrs removed after export.   (DRYaA) */
               IF         COND(&finished = '1') THEN(DO)          /* (DRYaA) */
                 CHGVAR     VAR(&EXPFLAG) VALUE('*EXPORT ')       /* (DRYaA) */
               enddo                                              /* (DRYaA) */
             enddo                                                /* (DRYaA) */
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
