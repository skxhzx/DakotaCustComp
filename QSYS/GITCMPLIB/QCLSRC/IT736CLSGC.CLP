/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT736CLSGC   FTP Export Item Hits/Avg Qty Picked SGC             */
/*  08 December 2016                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    12/08/16  MLB  SGC                                             */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &WHDP   -  Warehouse department                                */
/*    &SECTN  -  Section type (F,P,B)                                */
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

 IT736CLSGC:    PGM        PARM(&WHSE &WHDP &SECTN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (510 A) */
             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')                            /* (SGC A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT736SGC)

  /* Export script */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(10) +
                          VALUE(EXPFQTYSGC)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPQTY')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPQTYERR')

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFITMSGC')
             DCL        VAR(&FILE2) TYPE(*CHAR) LEN(100)          /* (SGC A) */

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414A */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&IFSFILE)    TYPE(*CHAR) LEN(100)     /* (SGC A) */
             DCL        VAR(&INCL)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEB)   TYPE(*CHAR) LEN(33)      /* (640aA) */
             DCL        VAR(&LCLFILEE)   TYPE(*CHAR) LEN(33)      /* (640aA) */
             DCL        VAR(&LCLFILEL)   TYPE(*CHAR) LEN(33)      /* (640aA) */
             DCL        VAR(&LCLFILEP)   TYPE(*CHAR) LEN(33)      /* (640aA) */
             DCL        VAR(&LCLFILEA)   TYPE(*CHAR) LEN(33)      /* (640aA) */
             DCL        VAR(&LCLFILEF)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&LIBB)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&LIBE)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&LIBP)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&LIBA)       TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&PATHH)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHD)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHC)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHT)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHB)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHE)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHL)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHP)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHA)      TYPE(*CHAR) LEN(45)      /* (640aA) */
             DCL        VAR(&PATHF)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RFLAG)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEB)   TYPE(*CHAR) LEN(16)      /* (640aA) */
             DCL        VAR(&RMTFILEE)   TYPE(*CHAR) LEN(16)      /* (640aA) */
             DCL        VAR(&RMTFILEL)   TYPE(*CHAR) LEN(16)      /* (640aA) */
             DCL        VAR(&RMTFILEP)   TYPE(*CHAR) LEN(16)      /* (640aA) */
             DCL        VAR(&RMTFILEA)   TYPE(*CHAR) LEN(20)      /* (640aA) */
             DCL        VAR(&RMTFILEF)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
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

             CHGVAR     VAR(&PGM) VALUE('IT736CLSGC')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member name */

             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&MBR) VALUE('Q' *CAT %SST(&WHSE 2 2) +
                          *CAT &NXTNUMA)

/* Create members for export files */

             ADDPFM     FILE(&FILE) MBR(&MBR)

             RMVMSG     CLEAR(*ALL)

SELECTRCDS:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting item hits/velocity into +
                          member' *BCAT &MBR *TCAT ' in item export +
                          files') TOPGMQ(*EXT) MSGTYPE(*STATUS)


/*  Call program to move route to export files */

             OVRDBF     FILE(&FILE) MBR(&MBR)

             CALL       PGM(&EXPPGM) PARM(&WHSE &WHDP &SECTN &INCL &RFLAG)

             DLTOVR     FILE(&FILE)

/* Check if we should export file to host system */  /* 414 A */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)
             DLTOVR     FILE(FTPEXPDFT)
             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP)

/* Create members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating export script from +
                          member' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF7306) EXEC(DO)                   /* (GFS A) */
               CLRPFM     FILE(FTPEXPLOG) MBR(&MBR)               /* (GFS A) */
             ENDDO                                                /* (GFS A) */
             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFQTY.' *CAT &MBR)

             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFQTY' *CAT +
                          %SST(&WHSE 2 2) *CAT '.Txt')

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*QTY')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)             (640aD) */
/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                          &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                          &PATHD &PATHC &PATHT &PATHB &PATHE +
                          &LCLFILEL &RMTFILEL &PATHL +
                          &LCLFILEP &RMTFILEP &PATHP +
                          &LCLFILEA &RMTFILEA &PATHA)             /* (650 D) */
               CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                            &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                            &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                            &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                            &PATHD &PATHC &PATHT &PATHB &PATHE +
                            &LCLFILEL &RMTFILEL &PATHL +
                            &LCLFILEP &RMTFILEP &PATHP +
                            &LCLFILEA &RMTFILEA &PATHA +
                            &LCLFILEF &RMTFILEF &PATHF)           /* (650 M) */

             DLTOVR     FILE(FTPEXPSCRP)

             RMVMSG     CLEAR(*ALL)

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

             IF         COND(&CLIENT = &SGC) THEN(DO)             /* (SGC A) */
/*             Convert file into .csv format for OptiSlot            (SGC A) */
               OVRDBF     FILE(&FILE) MBR(&MBR)
               CHGVAR     VAR(&FILE2) VALUE('expfitmsgc' *CAT +
                            %SST(&WHSE 1 3) *CAT '.csv')          /* (SGC A) */
               CHGVAR     VAR(&IFSFILE) VALUE('/bfctfr/' *CAT &FILE2) +
                                                                  /* (SGC A) */
               SQL2CSV    SQLSTMT('select * +
                            from expfitmsgc +
                            order by qewhse,qewhdp,qeitem') +
                        TOCSV(&IFSFILE)                           /* (SGC A) */
               CHGATR     OBJ(&IFSFILE) ATR(*CCSID) VALUE(00819)  /* (SGC A) */
             enddo                                                /* (SGC A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */  /* 414 A */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP2)

             RMVM       FILE(&FILE) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */

SKIPFTP2:                                                /* 414A */

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
