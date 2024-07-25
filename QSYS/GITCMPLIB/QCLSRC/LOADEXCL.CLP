/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADEXCL  Route Loading Exception History audit report.          */
/*  July 5, 2007                                                     */
/*                                                                   */
/*  Jose Duque            UNFINISHED <--- 0 0                        */
/*                                         J                         */
/*  Revisions                              ~                         */
/*                                                                   */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    MM/DD/YY  CBI-XXX                                              */
/*      Text.....................                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADEXCL:   PGM        PARM(&WHSE &FDATE &TDATE &FDTE6 &TDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADEXCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADR20)


             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LDRHHDR)


  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Route Status History Audit')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Printing ''Route Loading History Audit')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&FDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&FILNAM)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RTE#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 OPTNS:

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &FDATE &TDATE &FDTE6 +
                          &TDTE6 &RETURN &VP &JOBQ &DEV &FORM &RTE# +
                          &SORT)


/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO


/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
                SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &FDATE +
                &TDATE &FDTE6 &TDTE6 &RETURN &VP &JOBQ &DEV &FORM)) +
                JOB(&SBMPGM)
                GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

             MSGBFC     MESSAGE('Selecting records')

   /* Create selection criteria string. */

SELECT:
             CHGVAR     VAR(&QRYSLT) VALUE('LHHWHS *EQ ' *CAT &WHSE)

             IF         COND(&RTE# *NE *ALL)                       +
             THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LHHRTE  +
                        *EQ ' *CAT &RTE#))
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                         '((LHHSTD *EQ %RANGE('  *CAT &FDATE +
                         *BCAT &TDATE *CAT ')))')


             OVRDBF     FILE(&FILE) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                        SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

  /*                    KEYFLD((LHHWHS) (LHHSTD) (LHHSTT) +
                        (LHHRTE)) SEQONLY(*NO) OPTIMIZE(*FIRSTIO)   */


             CALL       PGM(GETUNQMEM) PARM(*REUSE RTESUMH2 &MEMBER)
             OVRDBF     FILE(RTESUMH2) MBR(&MEMBER)
             CALL       PGM(LOADR20B) PARM(&FDATE &TDATE)



PRINTRPT:

             /*  By Route */

             IF (&SORT = '1') THEN(DO)
             RUNQRY     QRY(RTESUMMA) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)
             ENDDO


             /*  By Loader */

             IF (&SORT = '2') THEN(DO)
             RUNQRY     QRY(RTESUMMB) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)
             ENDDO


             /*  By Loader-Pallet Dtl */

             RUNQRY     QRY(RTESUMMC)

             RUNQRY     QRY(RTESUMMD) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)

/*  Receive any messages and pass them on  */

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
 NOMSG:

/*  Clean up before leaving */

             RMVM       FILE(RTESUMH2) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)
             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
