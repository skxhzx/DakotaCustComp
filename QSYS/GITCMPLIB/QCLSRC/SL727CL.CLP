/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL727CL   FTP export slotS - Host executed                       */
/*  24 December 2010                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    12/24/10  MLB  6.40                                            */
/*      - Created                                                    */
/*                                                                   */
/*    03/20/18  MLB  7.20                                            */
/*      - Enh: Revised pgm to allow for flexibility for multiple     */
/*        warehouses. Revised cmd, CHGATR to use full path/filename  */
/*        when changing file attrributes.                            */
/*                                                                   */
/*    09/10/19  MLB  7.30                                            */
/*      - Enh: Added SLDESG to fields exported.                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &MBR    -  Member to create. Must start with alpha character.  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    QUOTE RCMD PIR/FTPLIBL *PROD                                   */
/*    QUOTE RCMD SL727CL ('001' 'Q001')                              */
/*    GET /BFCTFR/SLOT001.CSV  C:\TRANSFERBFC\SLOT001.CSV            */
/*    DEL /BFCTFR/SLOT001.csv                                        */
/*                                                                   */
/*    Note: The DEL statements are optional. This program will       */
/*          automatically clear the members before doing the export. */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Member name notes                                                */
/*                                                                   */
/*   - The first character of the member name must be an alpha       */
/*     character.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program is to be used by a host ftp script.                */
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
/* get <LocalPathName><LocalFileName> <RemotePathName><RemoteFileName> */
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
/*    Warehouse                                                      */
/*    Department                                                     */
/*    Slot Display                                                   */
/*    Item                                                           */
/*    Entered Date                                                   */
/*    Expiration Date                                                */
/*    Available Quantity 1                                           */
/*    Available Quantity 2                                           */
/*    Available Quantity 3                                           */
/*    Pick Slot (Y/N)                                        (530 A) */
/*    Reserved Slot (Y/N/V)                                  (530 A) */
/*    Designation                                            (730 A) */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL727CL:    PGM        PARM(&WHSE &MBR)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(NONE)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPSLOT')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPSLOTERR')

  /* Export file */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(33)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&IFSFILE)    TYPE(*CHAR) LEN(33)
             DCL        VAR(&INCL)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
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
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SAVMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('SL727CL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create IFS file to export */

             MSGBFC     MESSAGE('Selecting records to export')

             CHGVAR     VAR(&FILE) VALUE('slot' *CAT +
                          %SST(&WHSE 1 3) *CAT '.csv')
             CHGVAR     VAR(&IFSFILE) VALUE('/bfctfr/' *CAT &FILE)

             SQL2CSV    SQLSTMT('select +
                          slwhse,slwhdp,sldisp,slitem,slentd,slexpd,+
                          slstk1+slrcv1-slalc1-sltfr1-slpck1,+
                          slstk2+slrcv2-slalc2-sltfr2-slpck2,+
                          slstk3+slrcv3-slalc3-sltfr3-slpck3 +
                          ,slpick,slrsrv,sldesg +
                          from slot +
                          order by slwhse,slwhdp,sldisp') +
                        TOCSV(&IFSFILE)                           /* (730 M) */
/*           CHGATR     OBJ('/bfctfr/slot001.csv') ATR(*CCSID) +     (720 D) */
             CHGATR     OBJ(&IFSFILE) ATR(*CCSID) +
                          VALUE(00819)                            /* (720 M) */

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for ' +
                          *BCAT &IFSFILE) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             GOTO BOTTOM

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             CHGVAR     VAR(&RTN) VALUE('*PGMQ')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. File' *BCAT &IFSFILE *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. File' *BCAT &IFSFILE *TCAT '.') +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)

             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

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

        /*  Send '*Escape' message to caller */

               IF COND(&FINISHED = '0') THEN(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing File' +
                          *BCAT &IFSFILE) MSGTYPE(*ESCAPE)
               ENDDO

             ENDPGM
