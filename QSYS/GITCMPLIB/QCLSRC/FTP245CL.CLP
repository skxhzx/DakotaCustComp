/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP245CL   Retry purchase order FTP export from member           */
/*  08 March 1999                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    07/04/99  DAS  4.11b                                           */
/*      - Added logic to create log member if it doesn't exist.      */
/*                                                                   */
/*    07/14/06  MLB  5.10                                            */
/*      - Enh: Added client custom code support to program.          */
/*    07/14/06  MLB  5.10a                                           */
/*      - Enh: Added MONMSG's to all RMVM's at end of pgm.           */
/*    10/08/06  MLB  5.10b                                           */
/*      - Enh: Added 6 new return parms on call to FTPCRTSCRP        */
/*        program to return path statement created for export files. */
/*    04/23/07  MLB  5.10c                                           */
/*      - Fix: Changed parm passed to FTPCRTSCRP to *PO from *ORD.   */
/*                                                                   */
/*    03/26/08  MLB  5.20                                            */
/*      - Fix: Revised CPYSRC cmd to use &EXPSCRP for MBR parm       */
/*        instead of DEFAULT.                                        */
/*                                                                   */
/*    02/01/13  MLB  6.50                                            */
/*      - Fix: Revised program to add missing parms for Lcl/Rmt/Path */
/*        file A, Lcl/Rmt/Path file F.                               */
/*                                                                   */
/*    02/19/13  RTR  6.50a                                           */
/*      - Enh: Added file EXPFPOL - PO License Export.               */
/*    04/11/13  RTR  6.50b                                           */
/*      - Fix: corrected parm order for FTPCRTSCRP.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                      */
/*                                                                   */
/*    10/08/06  MLB  PAKa                                            */
/*      - Revised program to use CPYTOIMPF command to send SAPEXP    */
/*        file to shared folder instead of using FTP. Messages       */
/*        will still be sent to the FTP message queues.              */
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
/*  Client Custom Revisions: Springfield Grocery                     */
/*                                                                   */
/*    03/25/08  MLB  SGC                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFPOHxxxx.txt where xxxx is            */
/*        a unique number. The purchase order detail file will       */
/*        have the same format.                                      */
/*    03/26/08  MLB  SGCa                                            */
/*      - Revised program to export receiving exceptions file        */
/*        back to Host system. Use LclFileE/RmtFileE to send file.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Halsey Foodservice                      */
/*                                                                   */
/*    10/13/09  MLB  HAL                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFPOHxxxx.txt where xxxx is            */
/*        a unique number. The purchase order detail file will       */
/*        have the same format.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    12/15/10  MLB  DRY                                             */
/*      - Revised program to call BFCEPO01C to process exported      */
/*        purchase orders.                                           */
/*    12/15/10  MLB  DRYa                                            */
/*      - Revised mod, DRY to pass retrieved Dakota data files       */
/*        library name to Host interface program.                    */
/*    07/22/11  MLB  DRYb                                            */
/*      - Revised program to call Dairyland program, MTHENDCHKR      */
/*        to see if any period end processes are active. If pgm      */
/*        returns value of 1=Period end processing active, send      */
/*        message to user and cancel export. Per email from Kelly R. */
/*    08/31/11  MLB  DRYc                                            */
/*      - Revised mod, DRY to retrieve number of rcds in EXPFPOH.    */
/*        Only call BFCEPO01C if export hdr rcds greater than zero.  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: European Imports                        */
/*                                                                   */
/*    08/27/11  MLB  EI                                              */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFPOHxxxx.txt where xxxx is            */
/*        a unique number. The purchase order detail file will       */
/*        have the same format.                                      */
/*      - Added EI to SGC mod.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cash Wa                                 */
/*                                                                   */
/*    04/20/13  MLB  CWD                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFPOHxxxx.txt where xxxx is            */
/*        a unique number. The purchase order detail file will       */
/*        have the same format.                                      */
/*      - Added CWD to SGC mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Grenleaf Produce                        */
/*                                                                   */
/*    03/01/13  MLB  GLP                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFPOHxxxx.txt where xxxx is            */
/*        a unique number. The purchase order detail file will       */
/*        have the same format.                                      */
/*      - Added GLP to SGC mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: HM Wagner                               */
/*                                                                   */
/*    03/01/13  MLB  GLP                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFPOHxxxx.txt where xxxx is            */
/*        a unique number. The purchase order detail file will       */
/*        have the same format.                                      */
/*      - Added HMW to SGC mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP245CL:   PGM

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */
             DCL        VAR(&HALSEY) TYPE(*CHAR) LEN(10) +
                          VALUE('HALSEY    ')                     /* (HAL A) */
             DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(8) +
                          VALUE('PACKERS ')                       /* (PAK A) */
             DCL        VAR(&SGC)     TYPE(*CHAR) LEN(8) +
                          VALUE('SGC')                            /* (SGC A) */
             DCL        VAR(&TPC)     TYPE(*CHAR) LEN(8) +
                          VALUE('TPC')                            /* (TPC A) */
             DCL        VAR(&EI )     TYPE(*CHAR) LEN(10) +
                          VALUE('EI ')                            /* (EI  A) */
             DCL        VAR(&CASHWA)  TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA')                         /* (CWD A) */
             DCL        VAR(&GREENLEAF)     TYPE(*CHAR) LEN(10) +
                          VALUE('GREENLEAF ')                     /* (GLP A) */
             DCL        VAR(&HMWAGNER)      TYPE(*CHAR) LEN(10) +
                          VALUE('HMWAGNER  ')                     /* (HMW A) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Retry purchase order export')

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPO')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPOERR')

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOD')
             DCL        VAR(&FILEE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOE')                          /* (417)  */
             DCL        VAR(&FILEL) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOL')                          /* (650)  */

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(2)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&CURDTYYMD)  TYPE(*CHAR) LEN(8)       /* (PAK A) */
             DCL        VAR(&CURDTMDY)   TYPE(*CHAR) LEN(6)       /* (PAK A) */
             DCL        VAR(&CURTIME)    TYPE(*CHAR) LEN(6)       /* (PAK A) */
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)       /* (DRYcA) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFNBR)    TYPE(*CHAR) LEN(1)       /* (TPC A) */
             DCL        VAR(&EXPSCRP)    TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFPO)                           /* (520 A) */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEE)   TYPE(*CHAR) LEN(33)         /* (417) */
             DCL        VAR(&LCLFILEL)   TYPE(*CHAR) LEN(33)      /* (650aA) */
             DCL        VAR(&LCLFILEP)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEB)   TYPE(*CHAR) LEN(33)      /* (510bA) */
             DCL        VAR(&LCLFILEA)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LCLFILEF)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBE)       TYPE(*CHAR) LEN(10)         /* (417) */
             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(10)      /* (650aA) */
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)      /* (510bA) */
             DCL        VAR(&LIBB)       TYPE(*CHAR) LEN(10)      /* (510bA) */
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)      /* (510bA) */
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MonthEnd)   TYPE(*CHAR) LEN(1)       /* (DRYbA) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NBRCURRCDS) TYPE(*DEC)  LEN(10 0)    /* (DRYcA) */
             DCL        VAR(&PATHH)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHD)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHC)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHT)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHB)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHE)      TYPE(*CHAR) LEN(45)      /* (510bA) */
             DCL        VAR(&PATHL)      TYPE(*CHAR) LEN(45)      /* (650aA) */
             DCL        VAR(&PATHP)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&PATHA)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&PATHF)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEE)   TYPE(*CHAR) LEN(16)         /* (417) */
             DCL        VAR(&RMTFILEL)   TYPE(*CHAR) LEN(16)      /* (650aA) */
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEB)   TYPE(*CHAR) LEN(16)      /* (510bA) */
             DCL        VAR(&RMTFILEP)   TYPE(*CHAR) LEN(16)      /* (650 A) */
             DCL        VAR(&RMTFILEA)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&RMTFILEF)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNH)       TYPE(*CHAR) LEN(8)       /* (DRY A) */
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(10)      /* (DRYaM) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(4)       /* (SGC A) */
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEN)      TYPE(*DEC)  LEN(3 0)     /* (DRY A) */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (510 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (510 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

             SELECT                                               /* (DRYbA) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRYbA) */

               CALL       PGM(&HOSTLIB/MTHENDCHKR)  PARM('00' +
                            &MonthEnd)                            /* (DRY A) */
               Select                                             /* (DRYbA) */
/*             Period end processing active, cancel export.          (DRYbA) */
               When       COND(&MonthEnd *eq '1') THEN(DO)        /* (DRYbA) */
                 SNDPGMMSG  MSG('Period end processing active. Export +
                              purchase orders Cancelled.') TOPGMQ(*EXT) +
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

             CALL       PGM(FTP245) PARM(&MBR &RTN)

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

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             CHKOBJ     OBJ(&FILED) OBJTYPE(*FILE) MBR(&MBR)

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

/*  Get current date/time to create SAP FTP remote file name.        (PAK A) */
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               RTVSYSVAL  SYSVAL(QDATE) RTNVAR(&CURDTMDY)         /* (PAK A) */
               RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&CURTIME)          /* (PAK A) */
               CVTDAT   DATE(&CURDTMDY) TOVAR(&CURDTYYMD) +
                          FROMFMT(*MDY) TOFMT(*YYMD) TOSEP(*NONE) /* (PAK A) */
             ENDDO                                                /* (PAK A) */

/*  Copy members to extended length export files for TPC.            (TPCaA) */
             IF         COND(&client *eq &TPC) THEN(DO)           /* (TPCaA) */
               CPYF       FROMFILE(&FILEH) TOFILE(EXPFPOHSPK) +
                            FROMMBR(&MBR) TOMBR(&MBR) +
                            MBROPT(*REPLACE) FMTOPT(*MAP)         /* (TPCaA) */
               CPYF       FROMFILE(&FILED) TOFILE(EXPFPODSPK) +
                            FROMMBR(&MBR) TOMBR(&MBR) +
                           MBROPT(*REPLACE) FMTOPT(*MAP)          /* (TPCaA) */
             enddo                                                /* (TPCaA) */

/* Retrieve library names for files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating FTP export script') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               RTVMBRD    FILE(SAPEXP) MBR(&MBR) RTNLIB(&LIBH)    /* (PAK A) */
             ENDDO                                                /* (PAK A) */
             ELSE       CMD(DO)                                   /* (PAK A) */
             RTVMBRD    FILE(&FILEH) MBR(&MBR) RTNLIB(&LIBH)
             RTVMBRD    FILE(&FILED) MBR(&MBR) RTNLIB(&LIBD)
             RTVMBRD    FILE(&FILEE) MBR(&MBR) RTNLIB(&LIBE)         /* (417) */
             RTVMBRD    FILE(&FILEL) MBR(&MBR) RTNLIB(&LIBL)      /* (650aA) */
             ENDDO                                                /* (PAK A) */

/* Create FTP local and remote file names */

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                            '/SAPEXP.' *CAT &MBR)                 /* (PAK A) */
             ENDDO                                                /* (PAK A) */
             Else if cond(&client = &TPC) THEN(DO)                /* (TPCaA) */
               CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                            '/EXPFPOHSPK.' *CAT &MBR)             /* (TPCaA) */
               CHGVAR     VAR(&LCLFILED) VALUE(&LIBD *TCAT +
                            '/EXPFPODSPK.' *CAT &MBR)             /* (TPCaA) */
               CHGVAR     VAR(&LCLFILEE) VALUE(&LIBE *TCAT +
                          '/EXPFPOE.' *CAT &MBR)                  /* (TPCaA) */
             ENDDO                                                /* (TPCaA) */
             else cmd(DO)                                         /* (PAK A) */
             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFPOH.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILED) VALUE(&LIBD *TCAT +
                          '/EXPFPOD.' *CAT &MBR)
             CHGVAR     VAR(&LCLFILEE) VALUE(&LIBE *TCAT +
                          '/EXPFPOE.' *CAT &MBR)                     /* (417) */
             CHGVAR     VAR(&LCLFILEL) VALUE(&LIBL *TCAT +
                          '/EXPFPOL.' *CAT &MBR)                  /* (650aA) */
             ENDDO                                                /* (PAK A) */

      /*     CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT 'H.PO')   */
      /*     CHGVAR     VAR(&RMTFILED) VALUE(&MBR *TCAT 'D.PO')   */

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               CHGVAR     VAR(&RMTFILEH) VALUE(&CURDTYYMD *CAT &CURTIME)
                                                                  /* (PAK A) */
             ENDDO                                                /* (PAK A) */

             Else if cond(&client = &TPC) THEN(DO)                /* (TPC A) */
               CALL       PGM(GETEXP#) PARM('*PO' &EXPFNBR)       /* (TPC A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('wmph' *CAT &expfnbr) +
                                                                  /* (TPC A) */
               CHGVAR     VAR(&RMTFILED) VALUE('wmpd' *CAT &expfnbr) +
                                                                  /* (TPC A) */
             ENDDO                                                /* (TPC A) */
                                                                  /* (SGC A) */
/*           Else if cond(&client = &SGC) THEN(DO)                /* (EI  D) */
             Else if cond(&client = &SGC +
                      *or &client = &HALSEY +
                      *or &client = &Greenleaf +
                      *or &client = &HMWagner +
                      *or &client = &Cashwa +
                      *or &client = &EI) THEN(DO)                 /* (CWD M) */
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&MBR 7 4))   /* (SGC A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFPOH' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (SGC A) */
               CHGVAR     VAR(&RMTFILED) VALUE('EXPFPOD' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (SGC A) */

                 CHGVAR     VAR(&TFRNEEDED) VALUE(3)              /* (SGCaA) */
                 IF         COND(&CLIENT = &CASHWA) THEN(DO)      /* (CWD A) */
                   CHGVAR     VAR(&TFRNEEDED) VALUE(2)            /* (CWD A) */
                 ENDDO                                            /* (CWD A) */
                 CHGVAR     VAR(&RMTFILEE) VALUE('EXPFPOE' *CAT &SHORTNUMA +
                                                   *Tcat '.TXT')  /* (SGC A) */
             ENDDO                                                /* (650aA) */

             else cmd(DO)                                         /* (PAK A) */

             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFPOH.Txt')
             CHGVAR     VAR(&RMTFILED) VALUE('EXPFPOD.Txt')
             CHGVAR     VAR(&RMTFILEE) VALUE('EXPFPOE.TXT')       /* (417 A) */
             CHGVAR     VAR(&RMTFILEL) VALUE('EXPFPOL.TXT')       /* (650aA) */
      ENDDO                                                       /* (PAK A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*PO ')               /* (510cM) */
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +            */
/*                        &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +          */
/*                        &RMTFILED &RMTFILEC &RMTFILET)             (510bD) */
/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                          &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                          &PATHD &PATHC &PATHT &PATHB &PATHE)        (650 D) */
               CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                            &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                            &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                            &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                            &PATHD &PATHC &PATHT &PATHB &PATHE +
                            &LCLFILEL &RMTFILEL &PATHL +
                            &LCLFILEP &RMTFILEP &PATHP +
                            &LCLFILEA &RMTFILEA &PATHA +
                            &LCLFILEF &RMTFILEF &PATHF)           /* (650aM) */

             DLTOVR     FILE(FTPEXPSCRP)

/* Execute FTP */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Checking FTP export log') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             IF         COND(&CLIENT *EQ &PACKERS) THEN(DO)       /* (PAKaA) */

/*             Send file to IFS instead of using FTP.                (PAKaA) */
               CPYTOIMPF  FROMFILE(*LIBL/SAPEXP &MBR) +
                            TOSTMF(&PATHH) MBROPT(*REPLACE) +
                            STMFCODPAG(*PCASCII) RCDDLM(*CRLF) +
                            DTAFMT(*FIXED)                        /* (PAKaA) */
               MONMSG     MSGID(CPF2817) EXEC(DO)                 /* (PAKaA) */
                 CHGVAR     VAR(&RTN) VALUE('*PGMQ')              /* (PAKaA) */
               ENDDO                                              /* (PAKaA) */

             ENDDO                                                /* (PAKaA) */

             ELSE       CMD(DO)                                   /* (PAKaA) */

             OVRDBF     FILE(INPUT) TOFILE(*LIBL/FTPEXPSCRP) MBR(&MBR)
             OVRDBF     FILE(OUTPUT) TOFILE(*LIBL/FTPEXPLOG) MBR(&MBR)

             FTP        RMTSYS(DUMMYSYSTEM)

             DLTOVR     FILE(INPUT OUTPUT)

/* Now check FTP log file for errors */

             CHGVAR     VAR(&EXPTYPE) VALUE('*PO')
             OVRDBF     FILE(FTPEXPLOG) MBR(&MBR)

             CALL       PGM(FTPCHKLOG) PARM(&TFRNEEDED &MBR 'FTP245CL' +
                          &RTN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

             ENDDO                                                /* (PAKaA) */

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */

               RTVMBRD    FILE(&FILEH) MBR(&MBR) RTNLIB(&RUNTIMEENV) +
                            NBRCURRCD(&NBRCURRCDS)                /* (DRYcM) */

/*           Call Dairyland Interface Pgm.                           (DRY A) */
             IF         COND(&NBRCURRCDS > 0) THEN(DO)            /* (DRYcA) */
                                                                  /* (DRYcA) */
               CHGVAR     VAR(&WHSEN) VALUE(&WHSE)                /* (DRY A) */
               CALL       PGM(&HOSTLIB/BFCEPO01C) PARM(&WHSEN +
                            &MBR &RUNTIMEENV &RTNH)               /* (DRY A) */
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
                 GOTO GETOUT                                      /* (DRY A) */
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRYcA) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVM       FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILED) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILEE) MBR(&MBR)                       /* (417) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(&FILEL) MBR(&MBR)                    /* (650aA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (650aA) */
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (510aA) */
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               rmvm     FILE(SAPEXP) mbr(&mbr)                    /* (PAK A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (PAK A) */
             enddo                                                /* (PAK A) */
             IF         COND(&client *eq &TPC) THEN(DO)           /* (TPCaA) */
               rmvm     FILE(EXPFPOHSPK) mbr(&mbr)                /* (TPCaA) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (TPCaA) */
               rmvm     FILE(EXPFPODSPK) mbr(&mbr)                /* (TPCaA) */
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
