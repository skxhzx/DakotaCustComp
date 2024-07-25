/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP235CL   Retry customer order FTP export from member           */
/*  08 March 1999                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    07/04/99  DAS  4.11b                                           */
/*      - Added logic to create log member if it doesn't exist.      */
/*    07/14/06  MLB  5.10                                            */
/*      - Enh: Added client custom code support to program.          */
/*    07/14/06  MLB  5.10a                                           */
/*      - Enh: Added MONMSG's to all RMVM's at end of pgm.           */
/*    10/08/06  MLB  5.10b                                           */
/*      - Enh: Added 6 new return parms on call to FTPCRTSCRP        */
/*        program to return path statement created for export files. */
/*    05/17/07  RBD  5.10c                                           */
/*      - Added new export file EXPFORDL.                            */
/*      - NOTE: Missing parts of 5.10c mod added in from RH155CL.    */
/*    05/20/07  DAS  5.10d                                           */
/*      - Added new order detail piece seq# export file EXPFORDP.    */
/*      - NOTE: Missing parts of 5.10d mod added in from RH155CL.    */
/*                                                                   */
/*    03/26/08  MLB  5.20                                            */
/*      - Fix: Revised CPYSRC cmd to use &EXPSCRP for MBR parm       */
/*        instead of DEFAULT.                                        */
/*                                                                   */
/*    02/19/08  MLB  5.20a  P#00011                                  */
/*      - Added new order detail ASN SSCC-18 export file EXPFORDASN. */
/*      - Added call to pgm XM157 which creates XML ASN (advanced    */
/*        ship notice) files and export file EXPFORDASN.             */
/*      - Defined length of variable &RMTFILEA as 20.                */
/*      - NOTE: Missing parts of 5.20a mod added in from RH155CL.    */
/*                                                                   */
/*    02/05/10  MLB  5.30                                            */
/*      - Enh: Revised pgm to add If &finished = '1' then remove     */
/*        mbrs from export files.                                    */
/*                                                                   */
/*    05/07/12  MLB  6.40                                            */
/*      - Fix: Changed TFRNEEDED to 8 from 6 to match number of      */
/*        files being sent to Host system.                           */
/*                                                                   */
/*    08/10/12  LMC  6.40                                            */
/*      - Added new order detail LOT export file EXPFORDO.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC                                     */
/*                                                                   */
/*    02/22/07  MLB  TPC                                             */
/*      - Revised program to call GETEXP# for use in creating        */
/*        remote export file name.                                   */
/*    04/17/07  MLB  TPCa                                            */
/*      - Revised program to copy data from EXPFPOH, EXPFPOD to      */
/*        extended length files, EXPFPOHSPK and EXPFPODSPK.          */
/*        TPC's host software, Stanpack requires specific length     */
/*        files.                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    02/02/10  MLB  DRY                                             */
/*      - Revised program to call BFCECO01C to process exported      */
/*        route.                                                     */
/*    02/03/10  MLB  DRYa                                            */
/*      - Revised remote file names to exclude the warehouse number. */
/*        Create remote file name in the following format:           */
/*        EXPFORDHxxxx.txt where xxxx is                             */
/*        a unique number. This format will be used for all four     */
/*        files exported: EXPFORDD, EXPFORC and EXPFORDT.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: European Imports                        */
/*                                                                   */
/*    04/11/12  MLB  EI                                              */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFORDxxxx.txt where xxxx is            */
/*        a unique number. All export order files will have the      */
/*        same format.                                               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fischer Foods                           */
/*                                                                   */
/*    04/08/10  MLB  FFC                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFORDxxxx.txt where xxxx is            */
/*        a unique number. All export order files will have the      */
/*        same format.                                               */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP235CL:   PGM

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(8) +
                          VALUE('PACKERS ')                       /* (PAK A) */
             DCL        VAR(&TPC)     TYPE(*CHAR) LEN(8) +
                          VALUE('TPC')                            /* (TPC A) */
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */
             DCL        VAR(&EI )     TYPE(*CHAR) LEN(10) +
                          VALUE('EI ')                            /* (EI  A) */
             DCL        VAR(&FISCHER) TYPE(*CHAR) LEN(10) +
                          VALUE('FISCHER')                        /* (FFCaA) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Retry customer order export')

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORD')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPORDERR')

  /* Import files */

             DCLF       FILE(EXPFORDH)                            /* (DRY A) */
             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDD')
             DCL        VAR(&FILEC) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDC')
             DCL        VAR(&FILET) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDT')
             DCL        VAR(&FILEL) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDL')                       /* (510cA) */
             DCL        VAR(&FILEb) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDB')                       /* (510bA) */
             DCL        VAR(&FILEe) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDE')                       /* (510bA) */
             DCL        VAR(&FILEP) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDP')                       /* (510dA) */
             DCL        VAR(&FILEA) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDASN')                     /* (520aA) */
             DCL        VAR(&FILEF) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDO')                       /* (640 A) */

  /* Number of 'Transfer complete' messages to look for */

/*           DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(4) (640 D) */
             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(8) /*(640 M)*/

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFNBR)    TYPE(*CHAR) LEN(1)       /* (TPC A) */
             DCL        VAR(&EXPSCRP)    TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFORD)                          /* (520 A) */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)       /* (530aA) */
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEL)   TYPE(*CHAR) LEN(33)      /* (510cA) */
             DCL        VAR(&LCLFILEB)   TYPE(*CHAR) LEN(33)      /* (510bA) */
             DCL        VAR(&LCLFILEE)   TYPE(*CHAR) LEN(33)      /* (510bA) */
             DCL        VAR(&LCLFILEP)   TYPE(*CHAR) LEN(33)      /* (510dA) */
             DCL        VAR(&LCLFILEA)   TYPE(*CHAR) LEN(33)      /* (520aA) */
             DCL        VAR(&LCLFILEF)   TYPE(*CHAR) LEN(33)      /* (640 A) */
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(10)      /* (510cA) */
             DCL        VAR(&LIBB)       TYPE(*CHAR) LEN(10)      /* (510bA) */
             DCL        VAR(&LIBE)       TYPE(*CHAR) LEN(10)      /* (510bA) */
             DCL        VAR(&LIBP)       TYPE(*CHAR) LEN(10)      /* (510dA) */
             DCL        VAR(&LIBA)       TYPE(*CHAR) LEN(10)      /* (520aA) */
             DCL        VAR(&LIBF)       TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&PATHH)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHD)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHC)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHT)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHB)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHE)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHL)      TYPE(*CHAR) LEN(45)      /* (510cA) */
             DCL        VAR(&PATHP)      TYPE(*CHAR) LEN(45)      /* (510dA) */
             DCL        VAR(&PATHA)      TYPE(*CHAR) LEN(45)      /* (520aA) */
             DCL        VAR(&PATHF)      TYPE(*CHAR) LEN(45)      /* (640 A) */
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEL)   TYPE(*CHAR) LEN(16)      /* (510cA) */
             DCL        VAR(&RMTFILEB)   TYPE(*CHAR) LEN(16)      /* (510bA) */
             DCL        VAR(&RMTFILEE)   TYPE(*CHAR) LEN(16)      /* (510bA) */
             DCL        VAR(&RMTFILEP)   TYPE(*CHAR) LEN(16)      /* (510dA) */
             DCL        VAR(&RMTFILEA)   TYPE(*CHAR) LEN(20)      /* (520aA) */
             DCL        VAR(&RMTFILEF)   TYPE(*CHAR) LEN(20)      /* (640 A) */
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)       /* (DRY A) */
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)       /* (DRY A) */
             DCL        VAR(&RTNH)       TYPE(*CHAR) LEN(8)       /* (DRY A) */
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(4)       /* (DRY A) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(4)       /* (EI  A) */
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (510 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (510 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(FTP235) PARM(&MBR &RTN)

/*  See if user wants to proceed. */

             IF         COND((&RTN *EQ '*CANCEL') *OR (&RTN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/* See if we do the actual ftp to host system                     /* (530aA) */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPSCRP)             /* (530aA) */
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)             /* (530aA) */
             DLTOVR     FILE(FTPEXPDFT)                           /* (530aA) */

/*  Make sure members exist                                          */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking for member' *BCAT &MBR +
                          *TCAT ' in export files') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILED) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILEC) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILET) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILEL) OBJTYPE(*FILE) MBR(&MBR)      /* (510cA) */
             CHKOBJ     OBJ(&FILEB) OBJTYPE(*FILE) MBR(&MBR)      /* (510bA) */
             CHKOBJ     OBJ(&FILEE) OBJTYPE(*FILE) MBR(&MBR)      /* (510bA) */
             CHKOBJ     OBJ(&FILEP) OBJTYPE(*FILE) MBR(&MBR)      /* (510dA) */
             CHKOBJ     OBJ(&FILEA) OBJTYPE(*FILE) MBR(&MBR)      /* (520aA) */
             CHKOBJ     OBJ(&FILEF) OBJTYPE(*FILE) MBR(&MBR)      /* (640 A) */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(DO)        /* (530aA) */
               GOTO SKIPFTP                                       /* (530aA) */
             ENDDO                                                /* (530aA) */

/* Initializing members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Initializing member' *BCAT &MBR +
                          *TCAT ' in FTP script and log files') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF3141) EXEC(DO)
               ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)
             ENDDO

/*           CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)               (520 D) */
             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(&EXPSCRP) TOMBR(&MBR)           /* (520 M) */
             RMVMSG     CLEAR(*ALL)

/*  Copy members to extended length export files for TPC.            (TPCaA) */
             IF         COND(&client *eq &TPC) THEN(DO)           /* (TPCaA) */
               CPYF       FROMFILE(&FILEH) TOFILE(EXPFORDHSP) +
                            FROMMBR(&MBR) TOMBR(&MBR) +
                            MBROPT(*REPLACE) FMTOPT(*MAP)         /* (TPCaA) */
               MONMSG     MSGID(CPF2869 CPF2817)                  /* (TPCaA) */
               CPYF       FROMFILE(&FILED) TOFILE(EXPFORDDSP) +
                            FROMMBR(&MBR) TOMBR(&MBR) +
                           MBROPT(*REPLACE) FMTOPT(*MAP)          /* (TPCaA) */
               MONMSG     MSGID(CPF2869 CPF2817)                  /* (TPCaA) */
               CPYF       FROMFILE(&FILEC) TOFILE(EXPFORDCSP) +
                            FROMMBR(&MBR) TOMBR(&MBR) +
                           MBROPT(*REPLACE) FMTOPT(*MAP)          /* (TPCaA) */
               MONMSG     MSGID(CPF2869 CPF2817)                  /* (TPCaA) */
               CPYF       FROMFILE(&FILET) TOFILE(EXPFORDTSP) +
                            FROMMBR(&MBR) TOMBR(&MBR) +
                           MBROPT(*REPLACE) FMTOPT(*MAP)          /* (TPCaA) */
               MONMSG     MSGID(CPF2869 CPF2817)                  /* (TPCaA) */
             enddo                                                /* (TPCaA) */

/* Retrieve library names for files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating FTP export script') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RTVMBRD    FILE(&FILEH) MBR(&MBR) RTNLIB(&LIBH)
             RTVMBRD    FILE(&FILED) MBR(&MBR) RTNLIB(&LIBD)
             RTVMBRD    FILE(&FILEC) MBR(&MBR) RTNLIB(&LIBC)
             RTVMBRD    FILE(&FILET) MBR(&MBR) RTNLIB(&LIBT)
             RTVMBRD    FILE(&FILEL) MBR(&MBR) RTNLIB(&LIBL)      /* (510cA) */
             RTVMBRD    FILE(&FILEB) MBR(&MBR) RTNLIB(&LIBB)      /* (510bA) */
             RTVMBRD    FILE(&FILEE) MBR(&MBR) RTNLIB(&LIBE)      /* (510bA) */
             RTVMBRD    FILE(&FILEP) MBR(&MBR) RTNLIB(&LIBP)      /* (510dA) */
             RTVMBRD    FILE(&FILEA) MBR(&MBR) RTNLIB(&LIBA)      /* (520aA) */
             RTVMBRD    FILE(&FILEF) MBR(&MBR) RTNLIB(&LIBF)      /* (640 A) */

/* Create FTP local and remote file names */

             if cond(&client = &TPC) THEN(DO)                     /* (TPCaA) */
               CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                            '/EXPFORDHSP.' *CAT &MBR)             /* (TPCaA) */
               CHGVAR     VAR(&LCLFILED) VALUE(&LIBD *TCAT +
                            '/EXPFORDDSP.' *CAT &MBR)             /* (TPCaA) */
               CHGVAR     VAR(&LCLFILEC) VALUE(&LIBC *TCAT +
                          '/EXPFORDCSP.' *CAT &MBR)               /* (TPCaA) */
               CHGVAR     VAR(&LCLFILET) VALUE(&LIBT *TCAT +
                          '/EXPFORDTSP.' *CAT &MBR)               /* (TPCaA) */
             ENDDO                                                /* (TPCaA) */
             else cmd(DO)                                         /* (PAK A) */
             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFORDH.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILED) VALUE(&LIBD *TCAT +
                          '/EXPFORDD.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILEC) VALUE(&LIBC *TCAT +
                          '/EXPFORDC.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILET) VALUE(&LIBC *TCAT +
                          '/EXPFORDT.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILEL) VALUE(&LIBL *TCAT +
                          '/EXPFORDL.' *CAT &MBR)                 /* (510cA) */
             CHGVAR     VAR(&LCLFILEB) VALUE(&LIBB *TCAT +
                          '/EXPFORDB.' *CAT &MBR)                 /* (510bA) */
             CHGVAR     VAR(&LCLFILEE) VALUE(&LIBE *TCAT +
                          '/EXPFORDE.' *CAT &MBR)                 /* (510bA) */
             CHGVAR     VAR(&LCLFILEP) VALUE(&LIBP *TCAT +
                          '/EXPFORDP.' *CAT &MBR)                 /* (510dA) */
             CHGVAR     VAR(&LCLFILEA) VALUE(&LIBA *TCAT +
                          '/EXPFORDASN.' *CAT &MBR)               /* (520aA) */
             CHGVAR     VAR(&LCLFILEF) VALUE(&LIBF *TCAT +
                          '/EXPFORDO.' *CAT &MBR)                 /* (640 A) */
             ENDDO                                                /* (PAK A) */

   /*        CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT 'H.ORD')  */
   /*        CHGVAR     VAR(&RMTFILED) VALUE(&MBR *TCAT 'D.ORD')  */
   /*        CHGVAR     VAR(&RMTFILEC) VALUE(&MBR *TCAT 'C.ORD')  */
   /*        CHGVAR     VAR(&RMTFILET) VALUE(&MBR *TCAT 'T.ORD')  */

             IF         COND(&client *eq &TPC) THEN(DO)           /* (TPC A) */
               CALL       PGM(GETEXP#) PARM('*ORD' &EXPFNBR)      /* (TPC A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('wmch' *CAT &expfnbr) +
                                                                  /* (TPC A) */
               CHGVAR     VAR(&RMTFILED) VALUE('wmcd' *CAT &expfnbr) +
                                                                  /* (TPC A) */
               CHGVAR     VAR(&RMTFILEC) VALUE('wmcw' *CAT &expfnbr) +
                                                                  /* (TPC A) */
               CHGVAR     VAR(&RMTFILET) VALUE('wmct' *CAT &expfnbr) +
                                                                  /* (TPC A) */
             ENDDO                                                /* (TPC A) */
                                                                  /* (EI  A) */
             Else if cond(&client = &EI  +
                      *or &client = &FISCHER) THEN(DO)            /* (FFCaM) */
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&MBR 7 4))   /* (EI  A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFORDH' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILED) VALUE('EXPFORDD' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEC) VALUE('EXPFORDC' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILET) VALUE('EXPFORDT' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEB) VALUE('EXPFORDB' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEE) VALUE('EXPFORDE' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEL) VALUE('EXPFORDL' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEP) VALUE('EXPFORDP' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEA) VALUE('EXPFORDASN' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (EI  A) */
               CHGVAR     VAR(&RMTFILEF) VALUE('EXPFORDO' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (640 A) */
             ENDDO                                                /* (EI  A) */

             else cmd(DO)                                         /* (PAK A) */

             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFORDH.Txt')
             CHGVAR     VAR(&RMTFILED) VALUE('EXPFORDD.Txt')
             CHGVAR     VAR(&RMTFILEC) VALUE('EXPFORDC.Txt')
             CHGVAR     VAR(&RMTFILET) VALUE('EXPFORDT.Txt')
             CHGVAR     VAR(&RMTFILEL) VALUE('EXPFORDL.Txt')      /* (510cA) */
             CHGVAR     VAR(&RMTFILEB) VALUE('EXPFORDB.Txt')      /* (510bA) */
             CHGVAR     VAR(&RMTFILEE) VALUE('EXPFORDE.Txt')      /* (510bA) */
             CHGVAR     VAR(&RMTFILEP) VALUE('EXPFORDP.Txt')      /* (510dA) */
             CHGVAR     VAR(&RMTFILEA) VALUE('EXPFORDASN.Txt')    /* (520aA) */
             CHGVAR     VAR(&RMTFILEF) VALUE('EXPFORDO.Txt')      /* (640 A) */
             ENDDO                                                /* (PAK A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*ORD')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +            */
/*                        &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +          */
/*                        &RMTFILED &RMTFILEC &RMTFILET)             (510bD) */
             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                          &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                          &PATHD &PATHC &PATHT &PATHB &PATHE +
                          &LCLFILEL &RMTFILEL &PATHL +
                          &LCLFILEP &RMTFILEP &PATHP +
         /*640 M */       &LCLFILEA &RMTFILEA &PATHA +
                          &LCLFILEF &RMTFILEF &PATHF)             /* (640 A) */
/*                        &PATHD &PATHC &PATHT &PATHB &PATHE)     /* (510dD) */
         /*640 D          &LCLFILEA &RMTFILEA &PATHA +            */

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

             CHGVAR     VAR(&EXPTYPE) VALUE('*ORD')
             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR 'FTP235CL' +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* This is the place to skip to if script had *NO EXPORT*         /* (530aA) */

SKIPFTP:                                                          /* (530aA) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */

               RTVMBRD    FILE(&FILEH) MBR(&MBR) RTNLIB(&LIBH)    /* (DRY A) */
               IF         COND(&LIBH = 'PIRF') THEN(CHGVAR +
                            VAR(&RUNTIMEENV) VALUE('PROD'))       /* (DRY A) */
               ELSE  CMD(CHGVAR VAR(&RUNTIMEENV) VALUE('TEST'))   /* (DRY A) */

/*           Read EXPFORDH file to retrieve needed info.             (DRY A) */
               OVRDBF     FILE(EXPFORDH) MBR(&MBR)                /* (DRY A) */
               RCVF                                               /* (DRY A) */
               CHGVAR     VAR(&WHSE) VALUE(&OEHWHS)               /* (DRY A) */
               CHGVAR     VAR(&RTE)  VALUE(&OEHRTE)               /* (DRY A) */
               CLOF       OPNID(EXPFORDH)                         /* (DRY A) */
               MONMSG     MSGID(CPF4519 CPF4520)                  /* (DRY A) */
               DLTOVR     FILE(EXPFORDH)                          /* (DRY A) */
               MONMSG     MSGID(CPF9841)                          /* (DRY A) */

/*           Call Dairyland Interface Pgm.                           (DRY A) */
               CALL       PGM(&HOSTLIB/BFCECO01C) PARM(&WHSE &RTE +
                            &RTID &MBR &RUNTIMEENV &RTNH)         /* (DRY A) */
               MONMSG     MSGID(CPF0001) EXEC(CHGVAR VAR(&FINISHED) +
                            VALUE('0'))                           /* (DRY A) */
               SELECT                                             /* (DRY A) */
/*             Set flag for export failure, leave mbrs behind.       (DRY A) */
               When       COND(&RTNH *NE '*OK') THEN(DO)          /* (DRY A) */
                 CHGVAR     VAR(&FINISHED) VALUE('0')             /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             IF         COND(&FINISHED = '1') THEN(DO)            /* (530 A) */

             RMVM       FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILED) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILEC) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILET) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILEB) MBR(&MBR)                    /* (510bA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510bA) */
             RMVM       FILE(&FILEE) MBR(&MBR)                    /* (510bA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510bA) */
             RMVM       FILE(&FILEL) MBR(&MBR)                    /* (510cA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510cA) */
             RMVM       FILE(&FILEP) MBR(&MBR)                    /* (510dA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510dA) */
             RMVM       FILE(&FILEA) MBR(&MBR)                    /* (520aA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (520aA) */
             RMVM       FILE(&FILEF) MBR(&MBR)                    /* (640 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */

             Enddo                                                /* (530 A) */

             IF         COND(&client *eq &TPC) THEN(DO)           /* (TPCaA) */
               rmvm     FILE(EXPFORDHSP) MBR(mbr)                 /* (TPCaA) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (TPCaA) */
               rmvm     FILE(EXPFORDDSP) MBR(mbr)                 /* (TPCaA) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (TPCaA) */
               rmvm     FILE(EXPFORDCSP) MBR(mbr)                 /* (TPCaA) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (TPCaA) */
               rmvm     FILE(EXPFORDTSP) MBR(mbr)                 /* (TPCaA) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (TPCaA) */
             enddo                                                /* (TPCaA) */
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
