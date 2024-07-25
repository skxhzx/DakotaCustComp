/*-------------------------------------------------------------------*/
/*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR736CL   FTP export customer returns                            */
/*  06 July 1999                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    09/13/00  DAS  4.14                                            */
/*      - Revised to use export script EXPFADJ instead of DEFAULT.   */
/*      - Revised to check script for *NO EXPORT*.                   */
/*                                                                   */
/*    10/19/01  MLB  4.16                                            */
/*      - Revised &QRYSLT to include return records with             */
/*        ORTYPE = 'U', Return records changed during close.         */
/*    08/19/02  RH   4.16a                                           */
/*      - Revised &QRYSLT to not use return type ORTYPE.             */
/*        ORTYPE='Q', Quick returns use an export option.            */
/*                                                                   */
/*    09/28/06  MLB  5.10                                            */
/*      - Enh: Added client custom code support to program.          */
/*    10/08/06  MLB  5.10a                                           */
/*      - Enh: Added 6 new return parms on call to FTPCRTSCRP        */
/*        program to return path statement created for export files. */
/*    02/21/07  MLB  5.10b                                           */
/*      - Enh: Revised program to retrieve number of records from    */
/*        export mbr. If records = 0, then skip export.              */
/*                                                                   */
/*    12/31/10  MLB  6.40                                            */
/*      - Enh: Added DSPJOBLOG OUTPUT(*PRINT) if export fails.       */
/*      - Enh: Added MONMSG's to all RMVM's at end of pgm.           */
/*                                                                   */
/*    01/31/13  MLB  6.50                                            */
/*      - Enh: Added 12 new return parms on call to FTPCRTSCRP       */
/*        program to return path statement created for export files. */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line                               */
/*                                                                   */
/*    10/27/04  MLB  CTY                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                      */
/*                                                                   */
/*    09/28/06  MLB  PAK                                             */
/*      - Revised program to add member to SAPEXP file for           */
/*        SAP unique export file for purchase orders.                */
/*    10/08/06  MLB  PAKa                                            */
/*      - Revised program to use CPYTOIMPF command to send SAPEXP    */
/*        file to shared folder instead of using FTP. Messages       */
/*        will still be sent to the FTP message queues.              */
/*    12/04/06  MLB  PAKb                                            */
/*      - Revised program to add CHGAUT command, to file created     */
/*        in SAPBFCPP IFS directory.                                 */
/*    02/21/06  MLB  PAKc                                            */
/*      - Revised program to check SAPEXP file for zero records. if  */
/*        zero records then skip ftp processing.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC                                     */
/*                                                                   */
/*    02/22/07  MLB  TPC                                             */
/*      - Revised program to call GETEXP# for use in creating        */
/*        remote export file name.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Halsey Foodservice                      */
/*                                                                   */
/*    10/22/09  MLB  HAL                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added Halsey to CTY mod.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Capitol City Produce                    */
/*                                                                   */
/*    04/22/10  MLB  CCP                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added client to CTY mod.                                   */
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
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: European Imports                        */
/*                                                                   */
/*    07/16/11  MLB  EI                                              */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added EI to CTY mod.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Stern Produce                           */
/*                                                                   */
/*    12/07/12  MLB  SPI                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added SPI to CTY mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Get Fresh Sales                         */
/*                                                                   */
/*    01/31/13  MLB  GFS                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added GFS to CTY mod.                                      */
/*    01/31/13  MLB  GFSa                                            */
/*      - Revised program to loop two times. First time, look for    */
/*        rtn's that start with Gxxxxxxxx. Second time, will be to   */
/*        look for rtn's that start with Fxxxxxxxx. The export files */
/*        will be placed into a separate folder for each company.    */
/*        BFCExpPrd/G01 or BFCExpPrd/F02 for production or           */
/*        BFCExpTst/G01 or BFCExpTst/F02 for test.                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cashwa                                  */
/*                                                                   */
/*    02/18/13  LMC  CWD                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added CWD to CTY mod.                                      */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Greenleaf                               */
/*                                                                   */
/*    02/27/13  MLB  GLP                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added GLP to CTY mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Springfield Grocery                     */
/*                                                                   */
/*    10/22/13  MLB  SGC                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added SGC to CTY mod.                                      */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fischer Foods                           */
/*                                                                   */
/*    12/08/14  RTR  FFC                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added FFC to CTY mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Colony Foods                            */
/*                                                                   */
/*    04/19/18  RTR  CFIa                                            */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added to CTY mod.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Accardi Foods                           */
/*                                                                   */
/*    09/06/18  RTR  ACCa                                            */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFRTNxxxxx.txt where xxxxx is          */
/*        a unique number.                                           */
/*      - Added to ACC mod.                                          */
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
/*   The remote file name will start with the member name followed   */
/*   by a letter to identify it's type (H,D). The extension          */
/*   will be PO.                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR736CL:    PGM        PARM(&WHSE &ORDTYPE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (510 A) */

             DCL        VAR(&CAPITOLCTY) TYPE(*CHAR) LEN(10) +
                          VALUE('CAPITOLCTY')                     /* (CCP A) */
             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(8) +
                          VALUE('CITYLINE')                       /* (CTY A) */
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */
             DCL        VAR(&EuroImport) TYPE(*CHAR) LEN(10) +
                          VALUE('EI')                             /* (EI  A) */
             DCL        VAR(&GETFRESH)  TYPE(*CHAR) LEN(10) +
                          VALUE('GETFRESH')                       /* (GFS A) */
             DCL        VAR(&HALSEY) TYPE(*CHAR) LEN(10) +
                          VALUE('HALSEY')                         /* (HAL A) */
             DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(8) +
                          VALUE('PACKERS ')                       /* (PAK A) */
             DCL        VAR(&TPC)     TYPE(*CHAR) LEN(8) +
                          VALUE('TPC')                            /* (TPC A) */
             DCL        VAR(&STERN)     TYPE(*CHAR) LEN(10) +
                          VALUE('STERN')                          /* (SPI A) */
             DCL        VAR(&CASHWA)    TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA')                         /* (CWD A) */
             DCL        VAR(&GREENLEAF)  TYPE(*CHAR) LEN(10) +
                          VALUE('GREENLEAF ')                     /* (GLP A) */
             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')                            /* (SGC A) */
             DCL        VAR(&FISCHER)  TYPE(*CHAR) LEN(10) +
                          VALUE('FISCHER   ')                     /* (FFC A) */
             DCL        VAR(&COLONY)    TYPE(*CHAR) LEN(10) +
                          VALUE('COLONYFOOD')                     /* (CFIaA) */
             DCL        VAR(&ACCARDI)   TYPE(*CHAR) LEN(10) +
                          VALUE('ACCARDI')                        /* (ACCaA) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OR736)

  /* Export script */  /* 414A */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFRTN)

  /* Message queues */

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

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (510 A) */
             DCL        VAR(&CURDTYYMD)  TYPE(*CHAR) LEN(8)       /* (PAK A) */
             DCL        VAR(&CURDTMDY)   TYPE(*CHAR) LEN(6)       /* (PAK A) */
             DCL        VAR(&CURTIME)    TYPE(*CHAR) LEN(6)       /* (PAK A) */
             DCL        VAR(&CmpId)      TYPE(*CHAR) LEN(1) +
                                              VALUE('G')          /* (GFSaA) */
             DCL        VAR(&CmpNbr)     TYPE(*CHAR) LEN(2) +
                                              VALUE('01')         /* (GFSaA) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFNBR)    TYPE(*CHAR) LEN(1)       /* (TPC A) */
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414A */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&HOSTLIB)    TYPE(*CHAR) LEN(10) +
                                              VALUE('DARLIB_TST') /* (DRY A) */
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&LCLFILEC)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILED)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEH)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILET)   TYPE(*CHAR) LEN(33)
             DCL        VAR(&LCLFILEE)   TYPE(*CHAR) LEN(33)      /* (510aA) */
             DCL        VAR(&LCLFILEB)   TYPE(*CHAR) LEN(33)      /* (510aA) */
             DCL        VAR(&LCLFILEL)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LCLFILEP)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LCLFILEA)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LCLFILEF)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&LIBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBH)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBB)       TYPE(*CHAR) LEN(10)      /* (510aA) */
             DCL        VAR(&LIBC)       TYPE(*CHAR) LEN(10)      /* (510aA) */
             DCL        VAR(&LIBE)       TYPE(*CHAR) LEN(10)      /* (510aA) */
             DCL        VAR(&LIBT)       TYPE(*CHAR) LEN(10)      /* (510aA) */
             DCL        VAR(&Loop)       TYPE(*DEC)  LEN(2 0) +
                                              VALUE(01)           /* (GFSaA) */
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&ORDTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&ORDTYPEU)   TYPE(*CHAR) LEN(1) VALUE('U') /*(416)*/
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&PATHH)      TYPE(*CHAR) LEN(45)      /* (510aA) */
             DCL        VAR(&PATHD)      TYPE(*CHAR) LEN(45)      /* (510aA) */
             DCL        VAR(&PATHC)      TYPE(*CHAR) LEN(45)      /* (510aA) */
             DCL        VAR(&PATHT)      TYPE(*CHAR) LEN(45)      /* (510aA) */
             DCL        VAR(&PATHB)      TYPE(*CHAR) LEN(45)      /* (510aA) */
             DCL        VAR(&PATHE)      TYPE(*CHAR) LEN(45)      /* (510aA) */
             DCL        VAR(&PATHL)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&PATHP)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&PATHA)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&PATHF)      TYPE(*CHAR) LEN(45)      /* (650 A) */
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RECS)       TYPE(*DEC)  LEN(10 0)    /* (510bA) */
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEE)   TYPE(*CHAR) LEN(16)      /* (510aA) */
             DCL        VAR(&RMTFILEB)   TYPE(*CHAR) LEN(16)      /* (510aA) */
             DCL        VAR(&RMTFILEL)   TYPE(*CHAR) LEN(16)      /* (650 A) */
             DCL        VAR(&RMTFILEP)   TYPE(*CHAR) LEN(16)      /* (650 A) */
             DCL        VAR(&RMTFILEA)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&RMTFILEF)   TYPE(*CHAR) LEN(33)      /* (650 A) */
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNH)       TYPE(*CHAR) LEN(8)       /* (DRY A) */
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(10)      /* (DRYaM) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(5)       /* (CTY A) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHSEN)      TYPE(*DEC)  LEN(3 0)     /* (DRY A) */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (510 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (510 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('OR736CL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/*  Get current date/time to create SAP FTP remote file name.        (PAK A) */
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               RTVSYSVAL  SYSVAL(QDATE) RTNVAR(&CURDTMDY)         /* (PAK A) */
               RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&CURTIME)          /* (PAK A) */
               CVTDAT   DATE(&CURDTMDY) TOVAR(&CURDTYYMD) +
                          FROMFMT(*MDY) TOFMT(*YYMD) TOSEP(*NONE) /* (PAK A) */
             ENDDO                                                /* (PAK A) */

/* Create member name */

             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&MBR) VALUE('R' *CAT %SST(&WHSE 2 2) +
                          *CAT &NXTNUMA)

/* Create members for export files */

             ADDPFM     FILE(&FILE) MBR(&MBR)

/*  Create SAP Export Sales Orders file member.                      (PAK A) */
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */

               ADDPFM     FILE(SAPEXP) MBR(&MBR)                  /* (PAK A) */
               MONMSG     MSGID(CPF7306) EXEC(DO)
/*               Ignore member not added at this time.               (PAK A) */
/*               Clrpfm file(SAPEXP) mbr(&MBR)                       (PAK A) */
               Enddo                                              /* (PAK A) */

             enddo                                                /* (PAK A) */

/* Use OPNQRYF to select and order the records we need */

Selectrcds:                                                       /* (GFSaA) */
             MSGBFC     MESSAGE('Selecting records to export')

             OVRDBF     FILE(ORRTN) SHARE(*YES)
             CHGVAR     VAR(&QRYSLT) VALUE('(ORWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (ORUDTE *EQ 0)')    /* 416a      */
/*           CHGVAR     VAR(&QRYSLT) VALUE('(ORWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (ORUDTE *EQ 0) *AND (ORTYPE +
                          *EQ' *BCAT &QUOTE *CAT &ORDTYPE *CAT +
                          &QUOTE *CAT ')')                 (416) */
 /*          CHGVAR     VAR(&QRYSLT) VALUE('(ORWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (ORUDTE *EQ 0) *AND (ORTYPE +
                          *EQ' *BCAT &QUOTE *CAT &ORDTYPE *CAT +
                          &QUOTE *BCAT '*OR ORTYPE *EQ' *BCAT +
                          &QUOTE *CAT &ORDTYPEU *CAT &QUOTE *CAT +
                          ')')  (416a) /*    /*  (416) */

             IF         COND(&CLIENT = &GETFRESH) THEN(DO)        /* (GFSaA) */
               CHGVAR     VAR(&QRYSLT) VALUE(&qryslt *Bcat '*And +
                            (%SST(ORITEM 1 1) *EQ' *BCAT &QUOTE *CAT +
                            &CmpID *CAT &QUOTE *CAT ')' )         /* (GFSaA) */
             ENDDO                                                /* (GFSaA) */

             OPNQRYF    FILE((ORRTN)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((ORWHSE) (ORORD) (ORITEM) (ORRDTE) +
                          (ORRTIM))

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting returns into +
                          member' *BCAT &MBR *TCAT ' in adj export +
                          files') TOPGMQ(*EXT) MSGTYPE(*STATUS)


/*  Call program to move route to export files */

             OVRDBF     FILE(&FILE) MBR(&MBR)
/*  Override to SAP Export file member.                              (PAK A) */
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               OVRDBF     FILE(SAPEXP) MBR(&MBR)                  /* (PAK A) */
             ENDDO                                                /* (PAK A) */

             CALL       PGM(&EXPPGM)

             DLTOVR     FILE(&FILE)
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               dltovr     FILE(SAPEXP)                            /* (PAK A) */
             enddo                                                /* (PAK A) */

/* If no records were exported, delete member and get out */      /* (510bA) */

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAKcA) */
               RTVMBRD    FILE(SAPEXP) MBR(&MBR) NBRCURRCD(&RECS) /* (PAKcA) */
             ENDDO                                                /* (PAKcA) */
             ELSE       CMD(DO)                                   /* (PAKcA) */
               RTVMBRD    FILE(&FILE) MBR(&MBR) NBRCURRCD(&RECS)  /* (510bA) */
             ENDDO                                                /* (PAKcA) */

             IF         COND(&RECS = 0) THEN(DO)                  /* (510bA) */

             SELECT                                               /* (GFSaA) */
             WHEN       COND(&CLIENT = &Getfresh) THEN(DO)        /* (GFSaA) */

               CHGVAR     VAR(&LOOP) VALUE(&Loop + 1)             /* (GFSaA) */
               Select                                             /* (GFSaA) */
               When       COND(&LOOP = 2) THEN(DO)                /* (GFSaA) */
                 CLOF       OPNID(ORRTN)                          /* (GFSaA) */
                 MONMSG     MSGID(CPF4519 CPF4520)                /* (GFSaA) */
                 CLOF       OPNID(&FILE)                          /* (GFSaA) */
                 MONMSG     MSGID(CPF4519 CPF4520)                /* (GFSaA) */

                 CHGVAR     VAR(&CMPID) VALUE('F')                /* (GFSaA) */
                 CHGVAR     VAR(&CMPNBR) VALUE('02')              /* (GFSaA) */
                 GOTO       CMDLBL(SELECTRCDS)                    /* (GFSaA) */
               ENDDO                                              /* (GFSaA) */
               ENDSELECT                                          /* (GFSaA) */
             ENDDO                                                /* (GFSaA) */
             ENDSELECT                                            /* (GFSaA) */

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAKcA) */
               RMVM       FILE(sapexp) MBR(&MBR)                  /* (PAKcA) */
             ENDDO                                                /* (PAKcA) */
             ELSE       CMD(DO)                                   /* (PAKcA) */
               RMVM       FILE(&FILE) MBR(&MBR)                   /* (510bA) */
             ENDDO                                                /* (510bA) */
             RMVMSG     CLEAR(*ALL)                               /* (510bA) */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) MSGDTA('No +
                          records to export in member' *BCAT &MBR) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)         /* (510bA) */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) MSGDTA('No +
                          records to export in member' *BCAT &MBR) +
                          MSGTYPE(*INFO) KEYVAR(&MSGKEY)          /* (510bA) */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) +
                          MSGTYPE(*INFO)                          /* (510bA) */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) MSGTYPE(*INFO) +
                          KEYVAR(&MSGKEY)                         /* (510bA) */

             DLTOVR     FILE(*ALL)                                /* (510bA) */
             CHGVAR     VAR(&RTN) VALUE('*OK')                    /* (510bA) */
             RETURN                                               /* (510bA) */

             ENDDO                                                /* (510bA) */

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

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               RTVMBRD    FILE(SAPEXP) MBR(&MBR) RTNLIB(&LIBH)    /* (PAK A) */
             ENDDO                                                /* (PAK A) */
             ELSE       CMD(DO)                                   /* (PAK A) */
             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)
             ENDDO                                                /* (PAK A) */

/* Create FTP local and remote file names */

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                            '/SAPEXP.' *CAT &MBR)                 /* (PAK A) */
             ENDDO                                                /* (PAK A) */
             else cmd(DO)                                         /* (PAK A) */
             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFRTN.' *CAT &MBR)
             ENDDO                                                /* (PAK A) */

    /*       CHGVAR     VAR(&RMTFILEH) VALUE(&MBR *TCAT '.Rtn')  */

             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               CHGVAR     VAR(&RMTFILEH) VALUE(&CURDTYYMD *CAT &CURTIME)
                                                                  /* (PAK A) */
             ENDDO                                                /* (PAK A) */

/* Create Unique Remote Host file names.                             (CTY A) */

             ELSE       CMD(IF COND(&CLIENT *EQ &CITYLINE +
                                *OR &CLIENT *EQ &EUROIMPORT +
                                *OR &CLIENT *EQ &CAPITOLCTY +
                                *OR &CLIENT *EQ &STERN +
                                *OR &CLIENT *EQ &GETFRESH +
                                *OR &CLIENT *EQ &CASHWA +
                                *OR &CLIENT *EQ &GREENLEAF +
                                *OR &CLIENT *EQ &SGC +
                                *OR &CLIENT *EQ &FISCHER +
                                *OR &CLIENT *EQ &COLONY  +
                                *OR &CLIENT *EQ &Accardi +
                                *OR &CLIENT *EQ &HALSEY) THEN(DO)) /* (CFIaM)*/
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&NXTNUMA 4 4)) +
                                                                  /* (CTY A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFRTN' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (CTY A) */
             ENDDO                                                /* (CTY A) */

             ELSE       CMD(IF COND(&CLIENT *EQ &TPC) THEN(DO))   /* (TPC M) */
               CALL       PGM(GETEXP#) PARM('*RETURNS' &EXPFNBR)  /* (TPC A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('wmrh' *CAT &expfnbr) +
                                                                  /* (TPC A) */
             ENDDO                                                /* (TPC A) */

             else cmd(DO)                                         /* (PAK A) */

             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFRTN' *CAT %SST(&WHSE 2 2) +
                          *CAT '.Txt')
             ENDDO                                                /* (PAK A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*RETURNS')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +            */
/*                        &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +          */
/*                        &RMTFILED &RMTFILEC &RMTFILET)             (510aD) */
             SELECT                                               /* (GFSaA) */
             WHEN       COND(&CLIENT = &GETFRESH) THEN(DO)        /* (GFSaA) */
               CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                            &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                            &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                            &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                            &PATHD &PATHC &PATHT &PATHB &PATHE +
                            &LCLFILEL &RMTFILEL &PATHL +
                            &LCLFILEP &RMTFILEP &PATHP +
                            &LCLFILEA &RMTFILEA &PATHA +
                            &LCLFILEF &RMTFILEF &PATHF +
                            &Cmpid &CmpNbr)                       /* (GFSaA) */
             enddo                                                /* (GFSaA) */
             OTHERWISE  CMD(DO)                                   /* (GFSaA) */
/*           CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                          &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                          &PATHD &PATHC &PATHT &PATHB &PATHE)     /* (650 D) */
               CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                            &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                            &RMTFILED &RMTFILEC &RMTFILET &LCLFILEB +
                            &RMTFILEB &LCLFILEE &RMTFILEE &PATHH +
                            &PATHD &PATHC &PATHT &PATHB &PATHE +
                            &LCLFILEL &RMTFILEL &PATHL +
                            &LCLFILEP &RMTFILEP &PATHP +
                            &LCLFILEA &RMTFILEA &PATHA +
                            &LCLFILEF &RMTFILEF &PATHF)           /* (650 M) */
             ENDDO                                                /* (GFSaA) */
             ENDSELECT                                            /* (GFSaA) */

             DLTOVR     FILE(FTPEXPSCRP)

             RMVMSG     CLEAR(*ALL)

/* Execute FTP */

             IF         COND(&CLIENT *EQ &PACKERS) THEN(DO)       /* (PAKaA) */

/*             Send file to IFS instead of using FTP.                (PAKaA) */
               CPYTOIMPF  FROMFILE(*LIBL/SAPEXP &MBR) +
                            TOSTMF(&PathH) MBROPT(*REPLACE) +
                            STMFCODPAG(*PCASCII) RCDDLM(*CRLF) +
                            DTAFMT(*FIXED)                        /* (PAKaA) */
               MONMSG     MSGID(CPF2817) EXEC(DO)                 /* (PAKaA) */
                 CHGVAR     VAR(&RTN) VALUE('*PGMQ')              /* (PAKaA) */
               ENDDO                                              /* (PAKaA) */
               CHGAUT     OBJ(&PATHH) USER(*PUBLIC) DTAAUT(*RWX) +
                            OBJAUT(*ALL)                          /* (PAKbA) */

             ENDDO                                                /* (PAKaA) */

             ELSE       CMD(DO)                                   /* (PAKaA) */

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

             ENDDO                                                /* (PAKaA) */

/* If there was an error, just return */

             IF         COND(&RTN = '*PGMQ') THEN(GOTO GETOUT)

/* This is the place to skip to if script had *NO EXPORT* */ /* 414A */

             SELECT                                               /* (GFSaA) */
             WHEN       COND(&CLIENT = &Getfresh) THEN(DO)        /* (GFSaA) */

               CHGVAR     VAR(&LOOP) VALUE(&Loop + 1)             /* (GFSaA) */
               Select                                             /* (GFSaA) */
               When       COND(&LOOP = 2) THEN(DO)                /* (GFSaA) */
                 CLOF       OPNID(ORRTN)                          /* (GFSaA) */
                 MONMSG     MSGID(CPF4519 CPF4520)                /* (GFSaA) */
                 CLOF       OPNID(&FILE)                          /* (GFSaA) */
                 MONMSG     MSGID(CPF4519 CPF4520)                /* (GFSaA) */

                 CLRPFM     FILE(&FILE) MBR(&MBR)                 /* (GFSaA) */

                 CHGVAR     VAR(&CMPID) VALUE('F')                /* (GFSaA) */
                 CHGVAR     VAR(&CMPNBR) VALUE('02')              /* (GFSaA) */
                 GOTO       CMDLBL(SELECTRCDS)                    /* (GFSaA) */
               ENDDO                                              /* (GFSaA) */
               ENDSELECT                                          /* (GFSaA) */
             ENDDO                                                /* (GFSaA) */
             ENDSELECT                                            /* (GFSaA) */

SKIPFTP:

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RTN) VALUE('*OK')

             SELECT                                               /* (DRY A) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */

               RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&RUNTIMEENV) /*(DRYaM)*/

/*           Call Dairyland Interface Pgm.                           (DRY A) */
               CHGVAR     VAR(&WHSEN) VALUE(&WHSE)                /* (DRY A) */
               CALL       PGM(&HOSTLIB/BFCERT01C) PARM(&WHSEN +
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
               ENDDO                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */

             ENDDO                                                /* (DRY A) */
             ENDSELECT                                            /* (DRY A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */  /* 414 A */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP2)

             RMVM       FILE(&FILE) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */
             IF         COND(&client *eq &packers) THEN(DO)       /* (PAK A) */
               rmvm     FILE(SAPEXP) mbr(&mbr)                    /* (PAK A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (PAK A) */
             enddo                                                /* (PAK A) */

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
             OVRPRTF    FILE(QPJOBLOG) OUTQ(BFCEXCP)              /* (640 A) */
             DSPJOBLOG  OUTPUT(*PRINT)                            /* (640 A) */
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
