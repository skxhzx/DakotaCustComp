/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LAY155CL   Layout Designer - Extract Item Demand Data            */
/*  22 October 2013                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    10/22/13  MLB  6.50                                            */
/*      - Created                                                    */
/*    10/30/13  MLB  6.50a                                           */
/*      - Enh: Revised pgm to generate unique export file name.      */
/*      - Enh: Revised pgm to change file extension to .txt from .csv*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This is not a normal FTP export.                                */
/*   This export uses command SQL2CSV to create an IFS file.         */
/*   The IFS file is in comma-separated format.                      */
/*   The IFS file is FTP'd.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Sample FTP script.                                               */
/*                                                                   */
/* open <FTP Server>                                                 */
/* user <UserName Password>                                          */
/* binary                                                            */
/* namefmt 1                                                         */
/* put <LibraryName/FileName.MemberName> <RemotePathName><RemoteFileName> */
/* quit                                                              */
/*                                                                   */
/*   - For some unknown reason, a file created with SQL2CSV must be  */
/*     transfered in binary to the PC.                               */
/*                                                                   */
/*   - NAMEFMT 1 must be used when working with the IFS.             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Fields in export file (should match SQL statement below)         */
/*                                                                   */
/*    Item number                                                    */
/*    Item type                                                      */
/*    Item description                                               */
/*    Item pack/size                                                 */
/*    Department                                                     */
/*    Item UoM                                                       */
/*    Vendor number                                                  */
/*    Vendor item number                                             */
/*    Item length                                                    */
/*    Item width                                                     */
/*    Item height                                                    */
/*    Item cube                                                      */
/*    Item weight                                                    */
/*    Catchwgt flag Y/N                                              */
/*    Mfr tie                                                        */
/*    Mfr high                                                       */
/*    Avg qty sold per week                                          */
/*    Avg stock qty onhand                                           */
/*    Master item number                                             */
/*    Master pack quantity                                           */
/*    Home slot                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LAY155CL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LAY155)

  /* Export script */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(10) +
                          VALUE(EXPFLAYI)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPLAYI')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPLAYIERR')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DATETIME)   TYPE(*CHAR) LEN(20)      /* (650aA) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(33)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
/*           DCL        VAR(&IFSFILE)    TYPE(*CHAR) LEN(33)        (650aD) */
             DCL        VAR(&IFSFILE)    TYPE(*CHAR) LEN(250)    /* (650aM) */
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
             DCL        VAR(&PATH)       TYPE(*CHAR) LEN(500)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')
             RTVJOBA    DATETIME(&DATETIME)                       /* (650aA) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('LAY155CL')

/*           CHGVAR     VAR(&FILE) VALUE('layoutitm' *CAT +
                          %SST(&WHSE 1 3) *CAT '.csv')               (650aD) */
             CHGVAR     VAR(&FILE) VALUE('layoutitm' *CAT +
                          %SST(&WHSE 1 3) *CAT '_' *cat +
                          %sst(&datetime 1 14) *cat '.txt')       /* (650aM) */

             CHGVAR     VAR(&MBR) VALUE('EXPSLAYI')
             ADDPFM     FILE(EXPSLAYI) MBR(&MBR)
             MONMSG     MSGID(CPF7306) EXEC(DO)
               CLRPFM     FILE(*LIBL/EXPSLAYI) MBR(&MBR)
             Enddo

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create IFS file to export */
             OVRDBF     FILE(EXPSLAYI) TOFILE(EXPSLAYI) MBR(&MBR)
             CALL       PGM(LAY155) PARM(&WHSE)

             CLOF       OPNID(EXPSLAYI)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(EXPSLAYI)
             MONMSG     MSGID(CPF9841)

             MSGBFC     MESSAGE('Selecting records to export')

             CHGVAR     VAR(&IFSFILE) VALUE('/bfctfr/' *CAT &FILE)

/*SQL2CSV SQLSTMT('select +  */
  SQL2CSV SQLSTMT('select lyitem,lytype,lydesc,lypdsc,lywhdp,lyum1,+
                          lyven,lyvitm,lyulen,lyuwdt,lyuhgt,+
                          lycube,lyswgt,lycwgt,lytie,lyhigh,+
                          lyavsl,lyavqy,lymitm,lympck,lydisp +
                          from expslayi +
                          order by lywhdp,lydisp,lyitem') +
                        TOCSV(&IFSFILE)
             CHGVAR     VAR(&PATH) VALUE('/bfctfr/' *cat &file)
             CHGATR     OBJ(&PATH) ATR(*CCSID) VALUE(00819)

/* Check if we should export file to host system */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)
             DLTOVR     FILE(FTPEXPDFT)
             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP)

/* Create members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating export script from +
                          member' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CLRPFM     FILE(FTPEXPLOG) MBR(&MBR)
         /*  MONMSG     MSGID(CPF7306) EXEC(DO)    */
             MONMSG     MSGID(CPF3141 CPF3133 CPF3144) EXEC(DO)
             ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)
             ENDDO
             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(&EXPSCRP) TOMBR(&MBR)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&IFSFILE)

             CHGVAR     VAR(&RMTFILEH) VALUE(&FILE)

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*SLOT')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)

             DLTOVR     FILE(FTPEXPSCRP)

             RMVMSG     CLEAR(*ALL)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export files using FTP for +
                          file' *BCAT &FILE) TOPGMQ(*EXT) +
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

/* This is the place to skip to if script had *NO EXPORT* */ /* 414A */

SKIPFTP:

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP2)

             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
      /*     RMVM       FILE(FTPEXPLOG) MBR(&MBR)   */

SKIPFTP2:

             RMVMSG     CLEAR(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for file' +
                          *BCAT &FILE) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for file' +
                          *BCAT &FILE) MSGTYPE(*INFO) KEYVAR(&MSGKEY)

             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             CHGVAR     VAR(&RTN) VALUE('*PGMQ')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. File' *BCAT &FILE *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. File' *BCAT &FILE *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. File' *BCAT &FILE *TCAT '.') +
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
