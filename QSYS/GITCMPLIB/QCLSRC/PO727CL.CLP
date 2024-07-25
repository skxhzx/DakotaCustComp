/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO727CL   FTP export closed receiving P.O.'s - Host executed     */
/*  19 November 1999                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    01/21/00  DAS  4.13                                            */
/*      - Revised to clear export members first. Re: can't clear     */
/*        them at end of program because they still need to be       */
/*        retrieved using ftp by the host ftp script.                */
/*                                                                   */
/*    01/27/00  DAS  4.13a                                           */
/*      - Revised to rename the export members first. Re: for        */
/*        debugging purposes. Normally the code is skipped. To       */
/*        do the rename, comment the GOTO statment.                  */
/*                                                                   */
/*    04/10/03  MLB  4.17                                            */
/*      - Enh: Added support to program to allow PO Exceptions       */
/*        to be exported back to host system using file EXPFPOE.     */
/*                                                                   */
/*    02/19/13  MLB  6.50a                                           */
/*      - Enh: Added support to program to allow PO Licenses         */
/*        to be exported back to host system using file EXPFPOL.     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*    This program can be used in place of Receiving option 20 -     */
/*    Export marked P.O.'s. That program would execute PO726 which   */
/*    would generate and execute an ftp script to send the P.O.      */
/*    export files to the host system.                               */
/*                                                                   */
/*    Now, with this program, the host can perform the ftp export    */
/*    by doing a remote program call.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command sequence                                             */
/*                                                                   */
/*    QUOTE RCMD PIR/FTPLIBL *PROD                                   */
/*    QUOTE RCMD PO727CL ('001' 'P001')                              */
/*    GET PIRF/EXPFPOH.P001 C:\TRANSFER400\IMPFPOH.TXT               */
/*    GET PIRF/EXPFPOD.P001 C:\TRANSFER400\IMPFPOD.TXT               */
/*    GET PIRF/EXPFPOE.P001 C:\TRANSFER400\IMPFPOE.TXT         (417) */
/*    GET PIRF/EXPFPOL.P001 C:\TRANSFER400\IMPFPOL.TXT       (650aA) */
/*    DEL PIRF/EXPFPOH.P001                                          */
/*    DEL PIRF/EXPFPOD.P001                                          */
/*    DEL PIRF/EXPFPOE.P001                                    (417) */
/*    DEL PIRF/EXPFPOL.P001                                  (650aA) */
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

 PO726CL:    PGM        PARM(&WHSE &MBR)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PO726)

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
                          VALUE('EXPFPOL')                        /* (650aA)  */

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

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Rename existing member - for debugging */

   GOTO SKIPRNM

             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&SAVMBR) VALUE('P' *CAT %SST(&WHSE 2 2) +
                          *CAT &NXTNUMA)

             RNMM       FILE(&FILEH) MBR(&MBR) NEWMBR(&SAVMBR)
             MONMSG     MSGID(CPF3178)
             RNMM       FILE(&FILED) MBR(&MBR) NEWMBR(&SAVMBR)
             MONMSG     MSGID(CPF3178)
             RNMM       FILE(&FILEE) MBR(&MBR) NEWMBR(&SAVMBR)       /* (417) */
             MONMSG     MSGID(CPF3178)                               /* (417) */
             RNMM       FILE(&FILEL) MBR(&MBR) NEWMBR(&SAVMBR)     /* (650aA) */
             MONMSG     MSGID(CPF3178)                             /* (650aA) */

SKIPRNM:

/* Create members for export files. Reuse them if they exist. */

             CHKOBJ     OBJ(&FILEH) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEH) +
                          MBR(&MBR))

             CHKOBJ     OBJ(&FILED) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILED) +
                          MBR(&MBR))

             CHKOBJ     OBJ(&FILEE) OBJTYPE(*FILE) MBR(&MBR)         /* (417) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEE) +
                          MBR(&MBR))                                 /* (417) */

             CHKOBJ     OBJ(&FILEL) OBJTYPE(*FILE) MBR(&MBR)       /* (650aA) */
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILEL) +
                          MBR(&MBR))                               /* (650aA) */

/* Clear members  4.13 */

             CLRPFM     FILE(&FILEH) MBR(&MBR)
             CLRPFM     FILE(&FILED) MBR(&MBR)
             CLRPFM     FILE(&FILEE) MBR(&MBR)                       /* (417) */
             CLRPFM     FILE(&FILEL) MBR(&MBR)                     /* (650aA) */

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to export')

             OVRDBF     FILE(POHDR) SHARE(*YES)
             CHGVAR     VAR(&QRYSLT) VALUE('(PHWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (PHUDTE *EQ 0) *AND +
                          (PHSTAT *NE "0") *AND +
                          (%SST(PHPO 8 2) *NE' *BCAT &QUOTE *CAT +
                          'TF' *CAT &QUOTE *CAT ')')
             OPNQRYF    FILE((POHDR)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((PHWHSE) (PHPO))

/*  Call program to move route to export files */

             OVRDBF     FILE(&FILEH) MBR(&MBR)
             OVRDBF     FILE(&FILED) MBR(&MBR)
             OVRDBF     FILE(&FILEE) MBR(&MBR)                       /* (417) */
             OVRDBF     FILE(&FILEL) MBR(&MBR)                     /* (650aA) */

             CALL       PGM(&EXPPGM)

             DLTOVR     FILE(&FILEH &FILED)
             DLTOVR     FILE(&FILEE)                                 /* (417) */
             DLTOVR     FILE(&FILEL)                               /* (650aA) */

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
