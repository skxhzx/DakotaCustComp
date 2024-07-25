/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT731CL   FTP export closed transfer/putaway trans - Host execute*/
/*  13 January 2004                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    05/06/08  MLB  5.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fox River Foods                         */
/*                                                                   */
/*    04/17/08  CWM  FRF                                             */
/*      - New   Get PIRCLIENT DTAATA                                 */
/*      - New   OPNQRY for FRF to select only PUTEMP records         */
/*      - New   PT731R FOR FRF                                       */
/*      - Chg   ORIGINAL OPNQRYF TO SELECT ONLY TRANSACTIONS WITH    */
/*              TASK CODES: PUTRTN, PUTEMP, REPL, REPLBK & REPLTF    */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Springfield Grocery                     */
/*                                                                   */
/*    05/07/08  MLB  SGC                                             */
/*      - Add SGC to FRF mod to select only transactions with        */
/*        task codes: PUTRTN, PUTEMP, REPL, REPLBK, REPLTF & TFRMOV. */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*    This program is the same as PT729CL except that the file       */
/*    used for export has all zoned decimal fields instead of        */
/*    packed decimal fields in EXPFTRN.                              */
/*                                                                   */
/*    Revised to clear export members first. Re: can't clear         */
/*    them at end of program because they still need to be           */
/*    retrieved using ftp by the host ftp script.                    */
/*                                                                   */
/*    This program can be used in place of normal export.            */
/*    That program would execute a program which                     */
/*    would generate and execute an ftp script to send the           */
/*    export files to the host system.                               */
/*                                                                   */
/*    Now, with this program, the host can perform the ftp export    */
/*    by doing a remote program call.                                */
/*                                                                   */
/*    &GTRN is used to re-export transactions with the trans group #.*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &MBR    -  Member to create. Must start with alpha character.  */
/*    &GTRN   -  Group transaction # to resend for export.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    QUOTE RCMD PIR/FTPLIBL *PROD                                   */
/*    QUOTE RCMD PT731CL ('001' 'T001')                              */
/*    GET PIRF/EXPFTRN2.P001 C:\TRANSFER400\IMPFTRN2.TXT             */
/*    DEL PIRF/EXPFTRN2.P001                                         */
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
/*-------------------------------------------------------------------*/

 PT731CL:    PGM        PARM(&WHSE &MBR &GTRN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's (520)  */

/*FRF A*/    DCL        VAR(&FOXRIVER) TYPE(*CHAR) LEN(10) +
                          VALUE('FRF       ')
/*SGC A*/    DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC       ')

/* Export program.    */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT731)
/* RE-Export program. */

             DCL        VAR(&REXPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT731B)

/* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPTRN')

             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPTRNERR')

/* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFTRN2')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&SAVMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&GTRN)       TYPE(*CHAR) LEN(7)

 /*FRF A*/   DCL        VAR(&PSTAT) TYPE(*CHAR) LEN(1) VALUE('4')
 /*FRF A*/   DCL        VAR(&PTRTN) TYPE(*CHAR) LEN(6) VALUE('PUTRTN')
 /*FRF A*/   DCL        VAR(&PTEMP) TYPE(*CHAR) LEN(6) VALUE('PUTEMP')
 /*FRF A*/   DCL        VAR(&PREPL) TYPE(*CHAR) LEN(6) VALUE('REPL  ')
 /*FRF A*/   DCL        VAR(&PPLBK) TYPE(*CHAR) LEN(6) VALUE('REPLBK')
 /*FRF A*/   DCL        VAR(&PPLTF) TYPE(*CHAR) LEN(6) VALUE('REPLTF')
 /*FRF A*/   DCL        VAR(&PTFR)  TYPE(*CHAR) LEN(6) VALUE('TFRMOV')


             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*FRF A*/    CALL GETCLIENT PARM(&CLIENT &CLIENTLOC)

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create members for export files. Reuse them if they exist. */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILE) +
                          MBR(&MBR))

/* Clear members       */

             CLRPFM     FILE(&FILE) MBR(&MBR)

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to export')

/* Select for EXPORT                                   */

/* Begin Fox River Foods */

 /*FRF A*/   IF         COND(&CLIENT *EQ &FOXRIVER)  THEN(DO)

 /*FRF A*/     OVRDBF     FILE(PT731) TOFILE(PIRTRAN) SHARE(*YES)
 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE('PTTASK *EQ &PTEMP')
 /*FRF A*/     OPNQRYF    FILE((PIRTRAN) (FLGTRANR)) +
 /*FRF A*/                  FORMAT(*LIBL/PT731) QRYSLT(&QRYSLT) +
 /*FRF A*/                  KEYFLD((PTTRN#)) JFLD((PIRTRAN/PTTRN# +
 /*FRF A*/                  FLGTRANR/FGTRN# *EQ)) JDFTVAL(*ONLYDFT)
 /*FRF A*/     CALL       PGM(PT731R)
 /*FRF A*/
 /*FRF A*/   ENDDO

/* End Fox River Foods */

             IF (&GTRN =' ') DO

   /* Create selection criteria string. */
/*FRF A*/    IF         COND(&CLIENT *EQ &FOXRIVER +
                        *or  &CLIENT *EQ &SGC)       THEN(DO)

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE('(PTTASK *EQ ' *CAT &QUOTE +
                            *CAT &PTRTN *CAT &QUOTE)

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK +
                            *EQ ' *BCAT &QUOTE *CAT &PTEMP *CAT &QUOTE)

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK +
                            *EQ ' *BCAT &QUOTE *CAT &PREPL *CAT &QUOTE)

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK +
                            *EQ ' *BCAT &QUOTE *CAT &PPLBK *CAT &QUOTE)

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK +
                            *EQ ' *BCAT &QUOTE *CAT &PPLTF *CAT &QUOTE)

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK +
                            *EQ ' *BCAT &QUOTE *CAT &PTFR *CAT &QUOTE *CAT ')')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

 /*FRF A*/     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSTAT  +
                            *EQ ' *BCAT &QUOTE *CAT &PSTAT *CAT &QUOTE)
 /*FRF A*/   ENDDO

 /*FRF A*/   ELSE       CMD(DO)

               CHGVAR     VAR(&QRYSLT) VALUE('PTSTAT *EQ "4"')
 /*FRF A*/   ENDDO

               OVRDBF     FILE(PT731) TOFILE(PIRTRAN) SHARE(*YES)
               OPNQRYF    FILE((PIRTRAN) (FLGTRAN)) +
                            FORMAT(*LIBL/PT731) QRYSLT(&QRYSLT) +
                            KEYFLD((PTTRN#)) JFLD((PIRTRAN/PTTRN# +
                            FLGTRAN/FGTRN# *EQ)) JDFTVAL(*ONLYDFT)
             ENDDO

/* Select for Re-Export                                */

             IF (&GTRN >' ') DO
               OVRDBF     FILE(PT731) TOFILE(PIRTRAN) SHARE(*YES)
               CHGVAR     VAR(&QRYSLT) VALUE('FGGTRN *EQ ' *CAT &GTRN)
               OPNQRYF    FILE((PIRTRAN) (FLGTRAN)) +
                            FORMAT(*LIBL/PT731) QRYSLT(&QRYSLT) +
                            KEYFLD((PTTRN#)) JFLD((PIRTRAN/PTTRN# +
                            FLGTRAN/FGTRN# *EQ))
             ENDDO

/*  Call program to move records to export files */

             OVRDBF     FILE(&FILE) MBR(&MBR)

             IF (&GTRN = ' ') DO
               CALL       PGM(&EXPPGM)
             ENDDO

             IF (&GTRN > ' ') DO
               CALL       PGM(&REXPGM)
             ENDDO

             DLTOVR     FILE(&FILE)

/* We finished without error */

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

/*  Send Successful message */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export successful for member' +
                          *BCAT &MBR) TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             GOTO BOTTOM

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Export FAILED, see following +
                          messages. Member' *BCAT &MBR *TCAT '.') +
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
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
               ENDDO

             ENDPGM
