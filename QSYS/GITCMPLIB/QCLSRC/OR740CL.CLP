/*-------------------------------------------------------------------*/
/*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR740CL   Export Route Details for Goal Time Calcs               */
/*  29 September 2009                                                */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    09/29/09  MLB  5.20                                            */
/*     - Created.                                                    */
/*     - Includes client custom code support.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Mattingly Foods                         */
/*                                                                   */
/*    09/29/09  MLB  MAT                                             */
/*      - Revised remote file names to exclude the warehouse number. */
/*        Create remote file name in the following format:           */
/*        EXPFGOALxxxx.txt where xxxx is                             */
/*        a unique number.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &PGM    -  Program to send messages back to                    */
/*    &WHSE   -  Warehouse                                           */
/*    &RTETYP -  Route type                                          */
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
/*   by a letter to identify it's type (G). The extension            */
/*   will be RTE.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR740CL:    PGM        PARM(&PGM &WHSE &RTETYP &RTID &RTE &RTN &MSGKEY)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (520 A) */

             DCL        VAR(&MATTINGLY) TYPE(*CHAR) LEN(10) +
                          VALUE('MATTINGLY')                      /* (MAT A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OR745)

  /* Export script */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFGOAL)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPGOAL')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPGOALERR')

  /* Export files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFGOAL')

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
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEB)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEE)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEL)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEP)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEA)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBB)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBP)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBA)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&PATHH)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHD)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHC)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHT)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHB)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHE)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHL)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHP)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&PATHA)      TYPE(*CHAR) LEN(45)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEB)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEE)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEL)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEP)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEA)   TYPE(*CHAR) LEN(20)
             DCL        VAR(&RTETYP)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(4)       /* (MAT A) */
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (520 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (520 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* See if we do the actual ftp to host system */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)
             DLTOVR     FILE(FTPEXPDFT)

/* Create member name */

  /* Create unique member name when we do the ftp */

             IF         COND(&EXPFLAG *NE '*NOEXP') THEN(DO)
             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
             CHGVAR     VAR(&MBR) VALUE('G' *CAT %SST(&WHSEA 2 2) +
                          *CAT &NXTNUMA)
             ENDDO

  /* Create non-unique member name when we don't do the ftp */ /*416A*/

             IF         COND(&EXPFLAG = '*NOEXP') THEN(DO)
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
             CHGVAR     VAR(&MBR) VALUE('G' *CAT &WHSEA)
             ENDDO

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting Goal Info for route ' +
                          *BCAT &RTE *TCAT ' into member' *BCAT +
                          &MBR *TCAT ' in EXPFGOAL') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

/* Create members for export files */

             IF         COND(&EXPFLAG *NE '*NOEXP') THEN(DO)
             ADDPFM     FILE(&FILEH) MBR(&MBR)
             ENDDO

             IF         COND(&EXPFLAG *EQ '*NOEXP') THEN(DO)

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEH) +
                          MBR(&MBR))

             ENDDO

/*  Call program to move Route Goal Info to export file. */

             OVRDBF     FILE(&FILEH) MBR(&MBR)

             CALL       PGM(&EXPPGM) PARM(&WHSE &RTID &RTE &RTN)

             DLTOVR     FILE(&FILEH)

/* Check if we should export file to host system */

   /* &EXPFLAG retreived at beginning of program */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP)

/* Create member for FTP file */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating export script for Goal +
                          Info for route ' *BCAT &RTE *TCAT ' from +
                          member' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)

             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(&EXPSCRP) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILEH) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFGOAL.' *CAT &MBR)

             IF         COND(&CLIENT *EQ &Mattingly) Then(Do)
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&NXTNUMA 4 4)) +
                                                                  /* (MAT A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFGOAL' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (MAT A) */
             ENDDO                                                /* (MAT A) */
             ELSE       CMD(DO)                                  /*  (MAT A) */

               IF         COND(&RTETYP = 'W') THEN(DO)
                 CHGVAR     VAR(&RMTFILEH) VALUE('EXPFGOALW' *CAT %SST(&WHSEA +
                              2 2) *CAT '.Txt')
               ENDDO
               ELSE       CMD(DO)
                 CHGVAR     VAR(&RMTFILEH) VALUE('EXPFGOALR' *CAT %SST(&WHSEA +
                              2 2) *CAT '.Txt')
               ENDDO
             ENDDO                                               /* (MAT A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*GOALTIM')

             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                          &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                          &PATHD &PATHC &PATHT &PATHB &PATHE +
                          &LCLFILEL &RMTFILEL &PATHL +
                          &LCLFILEP &RMTFILEP &PATHP +
                          &LCLFILEA &RMTFILEA &PATHA)

             DLTOVR     FILE(FTPEXPSCRP)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export file using FTP for +
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

             CHGVAR     VAR(&EXPTYPE) VALUE('*GOAL')
             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR &PGM +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* This is the place to skip to if script had *NO EXPORT* */

SKIPFTP:

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP2)

             RMVM       FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)

             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)

             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)

SKIPFTP2:

             RMVMSG     CLEAR(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for Goal Info +
                          for route ' *BCAT &RTE *TCAT '(FTP Mbr' +
                          *BCAT &MBR *TCAT ').') TOMSGQ(&FTPMSGQ) +
                          MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for Goal Info +
                          for route ' *BCAT &RTE *TCAT '(FTP Mbr' +
                          *BCAT &MBR *TCAT ').') MSGTYPE(*INFO) +
                          KEYVAR(&MSGKEY)

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
