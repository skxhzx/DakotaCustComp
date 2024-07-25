/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH155CL   FTP export closed customer orders                      */
/*  05 March 1999                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    06/11/99  DAS  4.11                                            */
/*     - Revised to put warehouse number in positions 2 & 3          */
/*       of member names.                                            */
/*                                                                   */
/*    09/14/00  DAS  4.14                                            */
/*      - Revised to use export script EXPFADJ instead of DEFAULT.   */
/*      - Revised to check script for *NO EXPORT*.                   */
/*                                                                   */
/*    09/19/00  DAS  QLT                                             */
/*      - Revised to use static member name of Rnnn, where nnn is    */
/*        the warehouse code.                                        */
/*      - Added MONMSG after ADDPFM commands to trap error if        */
/*        member already exists.                                     */
/*      - * IMPORTANT * It is assumed that the script has            */
/*        '* NO EXPORT *' in it because the actual FTP is done with  */
/*        a separate program created by Dan. This revision allows    */
/*        multiple routes to go into a single member. Program        */
/*        RH150A has been modified to make sure that Dan's FTP       */
/*        process is not running when trying to export.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &PGM    -  Program to send messages back to                    */
/*    &WHSE   -  Warehouse                                           */
/*    &RTID   -  Route id                                            */
/*    &RTE    -  Host route                                          */
/*    &RTN    -  Return code                                         */
/*    &MSGKEY -  Message id for *PGMQ                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will create a unique member name and then create   */
/*   new members in all of the export files and in the FTP script    */
/*   and log files.                                                  */
/*                                                                   */
/*   The remote file name will start with the member name followed   */
/*   by a letter to identify it's type (H,D,C,T). The extension      */
/*   will be RTE.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH255CL:    PGM        PARM(&PGM &WHSE &RTID &RTE &RTN &MSGKEY)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(RH155)

  /* Export script */  /* 414A */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFORD)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORDERR')

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDD')
             DCL        VAR(&FILEC) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDC')
             DCL        VAR(&FILET) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDT')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(4)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414A */
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
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)   /* 411 A */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Create member name */

       /*    CALL       PGM(PIRFTP#) PARM(&NXTNUM)                  QLT D */
       /*    CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)                QLT D */
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)                 /* 411 A */
       /*    CHGVAR     VAR(&MBR) VALUE('W' *CAT &NXTNUMA)          411 D */
       /*    CHGVAR     VAR(&MBR) VALUE('R' *CAT %SST(&WHSEA 2 2) + QLT D */
       /*                 *CAT &NXTNUMA)                            QLT D */
             CHGVAR     VAR(&MBR) VALUE('R' *CAT &WHSEA)         /* QLT M */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting route' *BCAT &RTE *TCAT +
                          ' into member' *BCAT &MBR *TCAT ' in +
                          order export files') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/* Create members for export files */

             ADDPFM     FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF7306)            /* QLT A */
             ADDPFM     FILE(&FILED) MBR(&MBR)
             MONMSG     MSGID(CPF7306)            /* QLT A */
             ADDPFM     FILE(&FILEC) MBR(&MBR)
             MONMSG     MSGID(CPF7306)            /* QLT A */
             ADDPFM     FILE(&FILET) MBR(&MBR)
             MONMSG     MSGID(CPF7306)            /* QLT A */

/*  Call program to move route to export files */

             OVRDBF     FILE(&FILEH) MBR(&MBR)
             OVRDBF     FILE(&FILED) MBR(&MBR)
             OVRDBF     FILE(&FILEC) MBR(&MBR)
             OVRDBF     FILE(&FILET) MBR(&MBR)

             CALL       PGM(&EXPPGM) PARM(&WHSE &RTID &RTE &RTN)

             DLTOVR     FILE(&FILEH &FILED &FILEC &FILET)

/* Check if we should export file to host system */  /* 414 A */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)
             DLTOVR     FILE(FTPEXPDFT)
             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP)

/* Create members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating export script for route' +
                          *BCAT &RTE *TCAT ' from member' *BCAT +
                          &MBR) TOPGMQ(*EXT) MSGTYPE(*STATUS)

             ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)
             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILEH) MBR(&MBR) RTNLIB(&LIBH)
             RTVMBRD    FILE(&FILED) MBR(&MBR) RTNLIB(&LIBD)
             RTVMBRD    FILE(&FILEC) MBR(&MBR) RTNLIB(&LIBC)
             RTVMBRD    FILE(&FILET) MBR(&MBR) RTNLIB(&LIBT)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFORDH.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILED) VALUE(&LIBD *TCAT +
                          '/EXPFORDD.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILEC) VALUE(&LIBC *TCAT +
                          '/EXPFORDC.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILET) VALUE(&LIBC *TCAT +
                          '/EXPFORDT.' *CAT &MBR)

    /*       CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT 'H.ORD')   */
    /*       CHGVAR     VAR(&RMTFILED) VALUE(&MBR *TCAT 'D.ORD')   */
    /*       CHGVAR     VAR(&RMTFILEC) VALUE(&MBR *TCAT 'C.ORD')   */
    /*       CHGVAR     VAR(&RMTFILET) VALUE(&MBR *TCAT 'T.ORD')   */
             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFORD' *CAT %SST(&WHSEA +
                          2 2) *CAT 'H.Txt')
             CHGVAR     VAR(&RMTFILED) VALUE('EXPFORD' *CAT %SST(&WHSEA +
                          2 2) *CAT 'D.Txt')
             CHGVAR     VAR(&RMTFILEC) VALUE('EXPFORD' *CAT %SST(&WHSEA +
                          2 2) *CAT 'C.Txt')
             CHGVAR     VAR(&RMTFILET) VALUE('EXPFORD' *CAT %SST(&WHSEA +
                          2 2) *CAT 'T.Txt')

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*ORD')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)

             DLTOVR     FILE(FTPEXPSCRP)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export files using FTP for +
                          member' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             OVRDBF     FILE(INPUT) TOFILE(*LIBL/FTPEXPSCRP) MBR(&MBR)
             OVRDBF     FILE(OUTPUT) TOFILE(*LIBL/FTPEXPLOG) MBR(&MBR)

             FTP        RMTSYS(DUMMYSYSTEM)

             DLTOVR     FILE(INPUT OUTPUT)

/* Now check FTP log file for errors */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking FTP log for errors') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXPTYPE) VALUE('*ORD')
             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR &PGM +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(RETURN)

/* This is the place to skip to if script had *NO EXPORT* */ /* 414A */

SKIPFTP:

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */  /* 414 A */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP2)

             RMVM       FILE(&FILEH) MBR(&MBR)
             RMVM       FILE(&FILED) MBR(&MBR)
             RMVM       FILE(&FILEC) MBR(&MBR)
             RMVM       FILE(&FILET) MBR(&MBR)
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)

SKIPFTP2:                                                /* 414A */

             RMVMSG     CLEAR(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for route' +
                          *BCAT &RTE *TCAT '(FTP Mbr' *BCAT &MBR +
                          *TCAT ').') TOMSGQ(&FTPMSGQ) +
                          MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for route' +
                          *BCAT &RTE *TCAT '(FTP Mbr' *BCAT &MBR +
                          *TCAT ').') MSGTYPE(*INFO) KEYVAR(&MSGKEY)

             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             CHGVAR     VAR(&RTN) VALUE('*PGMQ')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Route' *BCAT &RTE *TCAT '(FTP +
                          Mbr' *BCAT &MBR *TCAT ').') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Route' *BCAT &RTE *TCAT '(FTP +
                          Mbr' *BCAT &MBR *TCAT ').') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Route' *BCAT &RTE *TCAT '(FTP +
                          Mbr' *BCAT &MBR *TCAT ').') +
                          MSGTYPE(*INFO) KEYVAR(&MSGKEY)
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

             ENDPGM
