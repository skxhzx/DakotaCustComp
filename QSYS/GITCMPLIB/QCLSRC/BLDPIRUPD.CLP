/*-----------------------------------------------------------------*/
/*                                                                 */
/*  BLDPIRUPD   Build PIRUPD, PIRUPDS, PIRUPDF libraries           */
/*  31 July 1997                                                   */
/*  Roxanne Harrison                                               */
/*                                                                 */
/*  Revisions                                                      */
/*    10/19/04  RH   4.17                                          */
/*      - Add QCOPYSRC and QSRVSRC                                 */
/*    10/28/04  RH   4.17b                                         */
/*      - Remove QDDSFILESE & QDDSFILESR, all files in QDDSFILES.  */
/*                                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &CLIB     Clear PIRUPD libraries (*YES, *NO)             */
/*        &BASE     Base Library to ues                            */
/*        &EPM      EPM Library to use                             */
/*        &RFR      RFR Library to use                             */
/*        &JOBQ     Jobq option (*YES, *NO)                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

 BLDPIRUPD:  PGM        PARM(&CLIB &BASE &EPM &RFR &JOBQ)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&CLIB)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&BASE)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&BASEF)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&BASES)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&EPM)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&EPMF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&EPMS)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RFR)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&RFRF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RFRS)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSG)      TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

   /* Standard message handling variables */


             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* See if user wants to put report on jobq. */

             RTVJOBA    TYPE(&JOBTYPE)
             IF (&JOBTYPE = '1') THEN(DO)
             IF (&JOBQ = '*YES') THEN(DO)
             SBMJOB     CMD(CALL PGM(BLDPIRUPD) PARM(&CLIB &BASE +
                          &EPM &RFR &JOBQ)) JOB(BLDPIRUPD)
             SNDPGMMSG  MSG('Program has been submitted to jobq') +
                          MSGTYPE(*COMP)
             RETURN
             ENDDO
             ENDDO

/* Clear message queues. */

/*           RMVMSG     MSGQ(PIRUPD) CLEAR(*OLD)        */
/*           RMVMSG     MSGQ(PIRUPDDET) CLEAR(*OLD)     */


/* Clear libraries PIRUPD, PIRUPDS, PIRUPDF */

             IF         COND(&CLIB = '*YES') THEN(DO)
             CLRLIB LIB(PIRUPD)
             CLRLIB LIB(PIRUPDS)
/* Create Q-boxes for PIRUPDS               */
               CRTSRCPF   FILE(PIRUPDS/QCLSRC) TEXT('CL source')
               CRTSRCPF   FILE(PIRUPDS/QCMDSRC) TEXT('CMD source')
               CRTSRCPF   FILE(PIRUPDS/QDDSFILES) TEXT('DDS source for files')
               CRTSRCPF   FILE(PIRUPDS/QDDSSRC) TEXT('DDS source')
               CRTSRCPF   FILE(PIRUPDS/QMENUSRC) TEXT('Menu source')
               CRTSRCPF   FILE(PIRUPDS/QMSGDSRC) TEXT('Message +
                            descriptions source')
               CRTSRCPF   FILE(PIRUPDS/QRPGSRC) TEXT('RPG source')
               CRTSRCPF   FILE(PIRUPDS/QCOPYSRC) TEXT('/COPY source')
               CRTSRCPF   FILE(PIRUPDS/QSRVSRC) TEXT('Binder language source')

             CLRLIB LIB(PIRUPDF)
             ENDDO

/* Create Save File for update merge.                 */
             CHKOBJ     OBJ(QTEMP/UPDSAVF) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 CRTSAVF FILE(QTEMP/UPDSAVF) TEXT('Save File for update merge')
             ENDDO


/* Base Library to use                                */

             IF         COND(&BASE *NE ' ') THEN(DO)
/* Merge Base Objects                                 */
             CHGVAR     VAR(&MSG) VALUE('Merging Base Objects for' +
                          *BCAT &BASE)
             MSGBFC     MESSAGE(&MSG)
/*           MSGBFC     MESSAGE('Merging Base Objects')  */
/* Save Base Objects library and restore to PIRUPD    */

             CLRSAVF    FILE(QTEMP/UPDSAVF)

             SAVLIB     LIB(&BASE) DEV(*SAVF) SAVF(QTEMP/UPDSAVF) +
                          TGTRLS(*CURRENT)
             RSTLIB     SAVLIB(&BASE) DEV(*SAVF) +
                          SAVF(QTEMP/UPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRUPD)
             MONMSG     MSGID(CPF3848 CPF3773)

/*           CPYLIB     FROMLIB(&BASE) TOLIB(PIRUPD) CRTLIB(*NO)    */

/* Merge Base Files                                   */

             CHGVAR     VAR(&BASEF) VALUE(&BASE *TCAT 'F')
             CHKOBJ     OBJ(&BASEF) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 GOTO BASES
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('Merging Base Files' +
                          *BCAT &BASEF)
             MSGBFC     MESSAGE(&MSG)
/* Save Base Files library and restore to PIRUPDF   */

             CLRSAVF    FILE(QTEMP/UPDSAVF)

             SAVLIB     LIB(&BASEF) DEV(*SAVF) SAVF(QTEMP/UPDSAVF) +
                          TGTRLS(*CURRENT)
             RSTLIB     SAVLIB(&BASEF) DEV(*SAVF) +
                          SAVF(QTEMP/UPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRUPDF)
             MONMSG     MSGID(CPF3848 CPF3773)

/*           CPYLIB     FROMLIB(&BASEF) TOLIB(PIRUPDF) CRTLIB(*NO)  */
BASES:

/* Merge Base Source                                  */
             CHGVAR     VAR(&BASES) VALUE(&BASE *TCAT 'S')
             CHKOBJ     OBJ(&BASES) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 GOTO BASEEND
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('Merging Base Source' +
                          *BCAT &BASES)
             MSGBFC     MESSAGE(&MSG)


/* Copy source from BASE Q boxes to PIRUPDS Q boxes   */

             CPYSRCF    FROMFILE(&BASES/QCLSRC) +
                          TOFILE(PIRUPDS/QCLSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QCMDSRC) +
                          TOFILE(PIRUPDS/QCMDSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QDDSFILES) +
                          TOFILE(PIRUPDS/QDDSFILES) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QDDSSRC) +
                          TOFILE(PIRUPDS/QDDSSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QMENUSRC) +
                          TOFILE(PIRUPDS/QMENUSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QMSGDSRC) +
                          TOFILE(PIRUPDS/QMSGDSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QRPGSRC) +
                          TOFILE(PIRUPDS/QRPGSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QCOPYSRC) +
                          TOFILE(PIRUPDS/QCOPYSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&BASES/QSRVSRC) +
                          TOFILE(PIRUPDS/QSRVSRC) FROMMBR(*ALL)

BASEEND:
             ENDDO

/*-----------------------------------------------------------------*/

/* EPM Library to use                                */

             IF         COND(&EPM *NE ' ') THEN(DO)
/* Merge EPM Objects                                 */
             CHGVAR     VAR(&MSG) VALUE('Merging EPM Objects' +
                          *BCAT &EPM)
             MSGBFC     MESSAGE(&MSG)

/* Save EPM Objects library and restore to PIRUPD    */

             CLRSAVF    FILE(QTEMP/UPDSAVF)

             SAVLIB     LIB(&EPM) DEV(*SAVF) SAVF(QTEMP/UPDSAVF) +
                          TGTRLS(*CURRENT)
             RSTLIB     SAVLIB(&EPM) DEV(*SAVF) +
                          SAVF(QTEMP/UPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRUPD)
             MONMSG     MSGID(CPF3848 CPF3773)

/*           CPYLIB     FROMLIB(&EPM) TOLIB(PIRUPD) CRTLIB(*NO) */

/* Merge EPM Files                                   */

             CHGVAR     VAR(&EPMF) VALUE(&EPM *TCAT 'F')
             CHKOBJ     OBJ(&EPMF) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 GOTO EPMS
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('Merging EPM Files' +
                          *BCAT &EPM)
             MSGBFC     MESSAGE(&MSG)
/* Save EPM Files library and restore to PIRUPDF   */

             CLRSAVF    FILE(QTEMP/UPDSAVF)

             SAVLIB     LIB(&EPMF) DEV(*SAVF) SAVF(QTEMP/UPDSAVF) +
                          TGTRLS(*CURRENT)
             RSTLIB     SAVLIB(&EPMF) DEV(*SAVF) +
                          SAVF(QTEMP/UPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRUPDF)
             MONMSG     MSGID(CPF3848 CPF3773)

/*           CPYLIB     FROMLIB(&EPMF) TOLIB(PIRUPDF) CRTLIB(*NO)  */
EPMS:

/* Merge EPM Source                                  */
             CHGVAR     VAR(&EPMS) VALUE(&EPM *TCAT 'S')
             CHKOBJ     OBJ(&EPMS) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 GOTO EPMEND
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('Merging EPM Source' +
                          *BCAT &EPMS)
             MSGBFC     MESSAGE(&MSG)


/* Copy source from EPM QE boxes to PIRUPDS Q boxes   */

             CPYSRCF    FROMFILE(&EPMS/QCLSRCE) +
                          TOFILE(PIRUPDS/QCLSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&EPMS/QCMDSRCE) +
                          TOFILE(PIRUPDS/QCMDSRC) FROMMBR(*ALL)
   /* 417b   CPYSRCF    FROMFILE(&EPMS/QDDSFILESE) +                */
   /*                     TOFILE(PIRUPDS/QDDSFILES) FROMMBR(*ALL)   */
             CPYSRCF    FROMFILE(&EPMS/QDDSSRCE) +
                          TOFILE(PIRUPDS/QDDSSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&EPMS/QMENUSRCE) +
                          TOFILE(PIRUPDS/QMENUSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&EPMS/QMSGDSRCE) +
                          TOFILE(PIRUPDS/QMSGDSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&EPMS/QRPGSRCE) +
                          TOFILE(PIRUPDS/QRPGSRC) FROMMBR(*ALL)

EPMEND:
             ENDDO

/*-----------------------------------------------------------------*/

/* RFR Library to use                                */

             IF         COND(&RFR *NE ' ') THEN(DO)
/* Merge RFR Objects                                 */
             CHGVAR     VAR(&MSG) VALUE('Merging RFR Objects' +
                          *BCAT &RFR)
             MSGBFC     MESSAGE(&MSG)

/* Save RFR Objects library and restore to PIRUPD    */

             CLRSAVF    FILE(QTEMP/UPDSAVF)

             SAVLIB     LIB(&RFR) DEV(*SAVF) SAVF(QTEMP/UPDSAVF) +
                          TGTRLS(*CURRENT)
             RSTLIB     SAVLIB(&RFR) DEV(*SAVF) +
                          SAVF(QTEMP/UPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRUPD)
             MONMSG     MSGID(CPF3848 CPF3773)

/*           CPYLIB     FROMLIB(&RFR) TOLIB(PIRUPD) CRTLIB(*NO)  */

/* Merge RFR Files                                   */

             CHGVAR     VAR(&RFRF) VALUE(&RFR *TCAT 'F')
             CHKOBJ     OBJ(&RFRF) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 GOTO RFRS
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('Merging RFR Files' +
                          *BCAT &RFRF)
             MSGBFC     MESSAGE(&MSG)
/* Save RFR Files library and restore to PIRUPDF   */

             CLRSAVF    FILE(QTEMP/UPDSAVF)

             SAVLIB     LIB(&RFRF) DEV(*SAVF) SAVF(QTEMP/UPDSAVF) +
                          TGTRLS(*CURRENT)
             RSTLIB     SAVLIB(&RFRF) DEV(*SAVF) +
                          SAVF(QTEMP/UPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRUPDF)
             MONMSG     MSGID(CPF3848 CPF3773)

/*           CPYLIB     FROMLIB(&RFRF) TOLIB(PIRUPDF) CRTLIB(*NO)  */
RFRS:

/* Merge RFR Source                                  */
             CHGVAR     VAR(&RFRS) VALUE(&RFR *TCAT 'S')
             CHKOBJ     OBJ(&RFRS) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                 GOTO RFREND
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('Merging RFR Source' +
                          *BCAT &RFRS)
             MSGBFC     MESSAGE(&MSG)


/* Copy source from RFR QR boxes to PIRUPDS Q boxes   */

             CPYSRCF    FROMFILE(&RFRS/QCLSRCR) +
                          TOFILE(PIRUPDS/QCLSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&RFRS/QCMDSRCR) +
                          TOFILE(PIRUPDS/QCMDSRC) FROMMBR(*ALL)
 /* 417b     CPYSRCF    FROMFILE(&RFRS/QDDSFILESR) +                */
 /*                       TOFILE(PIRUPDS/QDDSFILES) FROMMBR(*ALL)   */
             CPYSRCF    FROMFILE(&RFRS/QDDSSRCR) +
                          TOFILE(PIRUPDS/QDDSSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&RFRS/QMENUSRCR) +
                          TOFILE(PIRUPDS/QMENUSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&RFRS/QMSGDSRCR) +
                          TOFILE(PIRUPDS/QMSGDSRC) FROMMBR(*ALL)
             CPYSRCF    FROMFILE(&RFRS/QRPGSRCR) +
                          TOFILE(PIRUPDS/QRPGSRC) FROMMBR(*ALL)

RFREND:
             ENDDO



/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/
 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
