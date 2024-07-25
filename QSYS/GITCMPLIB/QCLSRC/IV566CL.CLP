/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV566CL   FTP Export Pre-Post Inventory Quantity                 */
/*  03 November 2009                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    11/03/09  MLB  5.30                                            */
/*      - Created.                                                   */
/*      - Included client custom code support in program.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Saval Foods                             */
/*                                                                   */
/*    11/07/09  MLB  SVL                                             */
/*      - Revised program to create remote file name in the          */
/*        following format: EXPFINVSxxxx.txt where xxxx is           */
/*        a unique number.                                           */
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
/*   new member in the export files and in the FTP script and        */
/*   log files.                                                      */
/*                                                                   */
/*   The remote file name will start with the member name and        */
/*   have an extension of TXT.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV566CL:    PGM        PARM(&WHSE &WHDP &SECTN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */

             DCL        VAR(&SAVALFOODS) TYPE(*CHAR) LEN(10) +
                          VALUE('SAVALFOODS')                     /* (SVL A) */

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV565)

  /* Export script */

             DCL        VAR(&EXPSCRP) TYPE(*CHAR) LEN(8) +
                          VALUE(EXPFINVS)

  /* Message queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPINVS')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPINVSERR')

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFINVS')

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(1)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
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
             DCL        VAR(&RMTFILEC)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILED)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILEH)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RMTFILET)   TYPE(*CHAR) LEN(16)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SHORTNUMA)  TYPE(*CHAR) LEN(4)       /* (SVL A) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGM) VALUE('IV566CL')

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member name */

             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&MBR) VALUE('V' *CAT %SST(&WHSE 2 2) +
                          *CAT &NXTNUMA)

/* Create members for export files */

             ADDPFM     FILE(&FILE) MBR(&MBR)

             RMVMSG     CLEAR(*ALL)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting pre-post inventory +
                          quantity into member' *BCAT &MBR *TCAT ' +
                          in qty export files') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)


/*  Call program to move route to export files */

             OVRDBF     FILE(&FILE) MBR(&MBR)

             CALL       PGM(&EXPPGM) PARM(&WHSE &WHDP &SECTN)

             DLTOVR     FILE(&FILE)

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

             ADDPFM     FILE(FTPEXPLOG) MBR(&MBR)
             CPYSRCF    FROMFILE(FTPEXPDFT) TOFILE(FTPEXPSCRP) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)

/* Retrieve library names for files */

             RTVMBRD    FILE(&FILE) MBR(&MBR) RTNLIB(&LIBH)

/* Create FTP local and remote file names */

             CHGVAR     VAR(&LCLFILEH) VALUE(&LIBH *TCAT +
                          '/EXPFINVS.' *CAT &MBR)

/* Create Unique Remote Host file names.                             (SVL A) */

             IF COND(&CLIENT *EQ &SAVALFOODS +
                                                ) THEN(DO)        /* (SVL A) */
               CHGVAR     VAR(&SHORTNUMA) VALUE(%SST(&NXTNUMA 4 4)) +
                                                                  /* (SVL A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFINVS' *CAT &SHORTNUMA +
                                                 *Tcat '.TXT')    /* (SVL A) */
             ENDDO                                                /* (SVL A) */

             ELSE       CMD(DO)                                   /* (SVL A) */
               CHGVAR     VAR(&RMTFILEH) VALUE('EXPFINVS' *CAT +
                            %SST(&WHSE 2 2) *CAT '.Txt')
             ENDDO                                                /* (SVL A) */

/* Call program to create script */

             CHGVAR     VAR(&EXPTYPE) VALUE('*INVS')
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

             RMVM       FILE(&FILE) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310 CPF0001)
             RMVM       FILE(FTPEXPSCRP) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310 CPF0001)
             RMVM       FILE(FTPEXPLOG) MBR(&MBR)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310 CPF0001)

SKIPFTP2:

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
               OVRPRTF    FILE(QPJOBLOG) OUTQ(QEZJOBLOG)
               DSPJOBLOG  OUTPUT(*PRINT)
               DLTOVR     FILE(QPJOBLOG)
               MONMSG     MSGID(CPF9841)
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
