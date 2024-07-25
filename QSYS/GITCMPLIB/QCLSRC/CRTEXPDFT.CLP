/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTEXPDFT   Create default FTP scripts                           */
/*  11 September 2000                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    9/11/00  DAS  4.14                                             */
/*     - Created                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTEXPDFT:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Default script file */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('FTPEXPDFT')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Create general default script DEFAULT */

             CHGVAR     VAR(&MBR) VALUE('DEFAULT')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating general default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Default')
               OVRDBF     FILE(FTPEXPDFT) MBR(&MBR)
               CALL       PGM(CRTDEFAULT)
               DLTOVR     FILE(FTPEXPDFT)
             ENDDO

/* Create default script EXPFADJ  */

             CHGVAR     VAR(&MBR) VALUE('EXPFADJ')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Inventory Adjustments')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO


/* Create default script EXPFCNT  */

             CHGVAR     VAR(&MBR) VALUE('EXPFCNT')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Inventory Counts')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO


/* Create default script EXPFORD */

             CHGVAR     VAR(&MBR) VALUE('EXPFORD')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Customer Orders')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO

/* Create default script EXPFPLBL */

             CHGVAR     VAR(&MBR) VALUE('EXPFPLBL')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Picking Labels')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO


/* Create default script EXPFPO */

             CHGVAR     VAR(&MBR) VALUE('EXPFPO')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Purchase Orders')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO

/* Create default script EXPFQTY */

             CHGVAR     VAR(&MBR) VALUE('EXPFQTY')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Item Quantities')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO

/* Create default script EXPFRTN */

             CHGVAR     VAR(&MBR) VALUE('EXPFRTN')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating default export +
                          script' *BCAT &MBR) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE(1)
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE(0))

             IF         COND(&EXIST *EQ 0) THEN(DO)
               ADDPFM     FILE(FTPEXPDFT) MBR(&MBR) +
                          TEXT('FTP export script - Customer Returns')
               CPYSRCF    FROMFILE(&FILE) TOFILE(&FILE) +
                          FROMMBR(DEFAULT) TOMBR(&MBR)
             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

             RCLRSC     LVL(*CALLER)

             ENDPGM
