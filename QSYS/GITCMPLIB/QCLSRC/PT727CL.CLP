/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT727CL   FTP export closed transactions - Host executed         */
/*  02 September 2003                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*      - Revised to clear export members first. Re: can't clear     */
/*        them at end of program because they still need to be       */
/*        retrieved using ftp by the host ftp script.                */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
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
/*    QUOTE RCMD PT727CL ('001' 'T001')                              */
/*    GET PIRF/EXPFTRN.P001 C:\TRANSFER400\IMPFPOH.TXT               */
/*    DEL PIRF/EXPFTRN.P001                                    (417) */
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

 PT727CL:    PGM        PARM(&WHSE &MBR &GTRN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT727)
  /* RE-Export program. */

             DCL        VAR(&REXPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT727B)

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPO')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPPOERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFTRN')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

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

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

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
             IF (&GTRN =' ') DO
             OVRDBF     FILE(PT727) TOFILE(PIRTRAN) SHARE(*YES)
             CHGVAR     VAR(&QRYSLT) VALUE('PTSTAT *EQ "4"')
             OPNQRYF    FILE((PIRTRAN) (FLGTRAN)) +
                          FORMAT(*LIBL/PT727) QRYSLT(&QRYSLT) +
                          KEYFLD((PTTRN#)) JFLD((PIRTRAN/PTTRN# +
                          FLGTRAN/FGTRN# *EQ)) JDFTVAL(*ONLYDFT)
                ENDDO
/* Select for RE-EXPORT                                */
             IF (&GTRN >' ') DO
             OVRDBF     FILE(PT727) TOFILE(PIRTRAN) SHARE(*YES)
             CHGVAR     VAR(&QRYSLT) VALUE('FGGTRN *EQ ' *CAT &GTRN)
             OPNQRYF    FILE((PIRTRAN) (FLGTRAN)) +
                          FORMAT(*LIBL/PT727) QRYSLT(&QRYSLT) +
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

             DLTOVR     FILE(&FILE)                                 /*  (417) */

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
