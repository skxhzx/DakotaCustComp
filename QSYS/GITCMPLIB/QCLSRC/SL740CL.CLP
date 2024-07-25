/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL740CL   FTP Export Slot Mster                                  */
/*  30 Sept 2008                                                     */
/*  Chuck Manny                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    09/30/08  CWM  5.20 Created                                    */
/*                                                                   */
/*    12/04/16  MLB  7.00                                            */
/*      - Enh: Added client custom code support to pgm.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: SGC Foodservice                         */
/*                                                                   */
/*    12/05/16  MLB  SGC                                             */
/*      - Revised pgm to call SQL2CSV routine to convert export mbr  */
/*        into .csv format file in /BFCTFR folder in IFS. Needed for */
/*        their new DRY whse addition to slot the items.             */
/*      - Note: These mods are not to be merged into base code.      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &WHDP   -  Warehouse department                                */
/*    &STYP   -  Section type (F,P,B)                                */
/*    &IVRT   -  Include Virtual Slots                               */
/*    &MBR    -  Member Name                                         */
/*    &JOBQ   -  Submit to Job Queue Y/N                             */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will create a unique member name if one is not     */
/*   passed into the program.                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL740CL:    PGM        PARM(&WHSE &WHDP &STYP &IVRT &MBR &JOBQ &PCMD)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (700 A) */

             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')                            /* (SGC A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SL745)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SL740)

  /* Export script */  /* 414A */

             DCL        VAR(&EXPFSLTM) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFSLTM)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPSLTM')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPSLTMERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFSLTM')
             DCL        VAR(&FILE2) TYPE(*CHAR) LEN(100)          /* (SGC A) */

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Exporting Slot Master SL740 ')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Exporting Slot Master SL740 ')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (700 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (700 A) */
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414A */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&IFSFILE)    TYPE(*CHAR) LEN(100)     /* (SGC A) */
             DCL        VAR(&IVRT)       TYPE(*CHAR) LEN(1)
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
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RFLAG)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&STYP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&FTP)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (700 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (700 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('SL740CL')

/*  Get Job Information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* If Called From External Process                     */

             IF (&PCMD = '*HOST   ') THEN(GOTO REPORT)

/*  Do Not Run Options Program if being ran from JOBQ  */

              RTVJOBA    TYPE(&TYPE)
              IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Set Job Options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &STYP &IVRT +
                          &RETURN &JOBQ &FTP)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
             CHGVAR     VAR(&FINISHED) VALUE('1')
             GOTO BOTTOM
             RETURN
             ENDDO

REPORT:

/* Create Member if Doesnt Exist */

             IF COND(&MBR = ' ') THEN(DO)
             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&MBR) VALUE('S' *CAT %SST(&WHSE 2 2) +
                          *CAT &NXTNUMA)
             ENDDO

/* Create members for export files */

             ADDPFM     FILE(&FILE) MBR(&MBR)

             CLRPFM     FILE(&FILE) MBR(&MBR)

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting Slot Master Records to +
                          Member' *BCAT &MBR *TCAT ' in Slot Master +
                          Export file *BCAT &FILE *TCAT') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)


/* Call Program To Create Export File */

             OVRDBF     FILE(&FILE) MBR(&MBR)

             CALL       PGM(&EXPPGM) PARM(&WHSE &WHDP &STYP &IVRT)

             DLTOVR     FILE(&FILE)

             CHGVAR     VAR(&FINISHED) VALUE('1')

/* Check if we should export file to host system */  /* 414 A */

             OVRDBF     FILE(FTPEXPDFT) MBR(&EXPFSLTM)
             CALL       PGM(FTPCHKSCR) PARM(&EXPFLAG)
             DLTOVR     FILE(FTPEXPDFT)

             IF         COND(&EXPFLAG = '*NOEXP') THEN(GOTO SKIPFTP)

/* Create members for ftp files */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating export script from +
                          member' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)

             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(EXPFSLTM) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFSLTM.' *CAT &MBR)

             CHGVAR     VAR(&RMTFILEH) VALUE('EXPFQTY' *CAT +
                          %SST(&WHSE 2 2) *CAT '.Txt')

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*SLOTM')
             OVRDBF     FILE(FTPEXPSCRP) MBR(&MBR)

             CALL       PGM(FTPCRTSCRP) PARM(&EXPTYPE &LCLFILEH +
                          &LCLFILED &LCLFILEC &LCLFILET &RMTFILEH +
                          &RMTFILED &RMTFILEC &RMTFILET)

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
                          &RETURN &MSGKEY)

             DLTOVR     FILE(FTPEXPLOG)

/* If there was an error, just return */

             IF         COND(&RETURN = '*PGMQ') THEN(GOTO GETOUT)

/* This is the place to skip to if script had *NO EXPORT* */ /* 414A */

SKIPFTP:

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')
             CHGVAR     VAR(&RETURN) VALUE('*OK')

             IF         COND(&CLIENT = &SGC) THEN(DO)             /* (SGC A) */
/*             Convert file into .csv format for OptiSlot            (SGC A) */
               OVRDBF     FILE(&FILE) MBR(&MBR)
               CHGVAR     VAR(&FILE2) VALUE('expfsltm' *CAT +
                            %SST(&WHSE 1 3) *CAT '.csv')          /* (SGC A) */
               CHGVAR     VAR(&IFSFILE) VALUE('/bfctfr/' *CAT &FILE2) +
                                                                  /* (SGC A) */
               SQL2CSV    SQLSTMT('select +
                            smwhse,smwhdp,smdisp,smaisl,smloc,smrlvl,smwdth,smlen,smhgt,+
                            smpseq,smpick +
                            from expfsltm +
                            order by smwhse,smwhdp,smdisp') +
                        TOCSV(&IFSFILE)                           /* (SGC A) */
               CHGATR     OBJ(&IFSFILE) ATR(*CCSID) VALUE(00819)  /* (SGC A) */
             enddo                                                /* (SGC A) */

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/* If we skipped FTP then don't delete members */  /* 414 A */

             IF         COND(&EXPFLAG = '*NOEXP') THEN(DO)

             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF0000)
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF0000)
 /*          RMVM       FILE(&FILE) MBR(&MBR) */
 /*          MONMSG     MSGID(CPF0000)        */
             ENDDO

SKIPFTP2:                                                /* 414A */

             RMVMSG     CLEAR(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Slot Master Export successful for +
                          file EXPFSLTM member' *BCAT &MBR) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Slot Master Export successful for +
                          file EXPFSLTM member' *BCAT &MBR) +
                          MSGTYPE(*INFO) KEYVAR(&MSGKEY)

             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:
             IF COND(&FINISHED = '1') THEN(DO)
             CHGVAR     VAR(&RETURN) VALUE('*PGMQ')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('''(''Slot Master Export File +
                          EXPFSLTM created. See following messages. +
                          File member ''*BCAT &MBR *TCAT ''.'')') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
                          ENDDO

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             CHGVAR     VAR(&RETURN) VALUE('*PGMQ')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Slot Master Export FAILED, see +
                          following messages. File EXPFSLTM, +
                          member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Slot Master Export FAILED, see +
                          following messages. File EXPFSLTM. +
                          member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Slot Master Export FAILED, see +
                          following messages. File EXPFSLTM, +
                          Member' *BCAT &MBR *TCAT '.') +
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
