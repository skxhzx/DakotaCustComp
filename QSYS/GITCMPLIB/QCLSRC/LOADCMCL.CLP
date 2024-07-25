/*-------------------------------------------------------------------*/
/*  LOADCMCL: Loader Module - Route Comment History audit View/Print */
/*            Executed from Menu: Pirloadr/Opt 10-->Pirldrpt/Opt 6   */
/*                                                                   */
/*  September 4, 2007                                                */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
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

 LOADCMCL:   PGM        PARM(&WHSE &FDATE &TDATE &FDTE6 &TDTE6  +
                             &RETURN &VP &JOBQ &DEV &FORM &RTE# +
                             &COMTYP &RCODE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADCMCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADR26)


             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LDRHCOM)


  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Route Comment History Audit')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Printing ''Route Comment History Audit')

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
             DCL        VAR(&MEMBER2)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER3)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER4)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RTE#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RCODE)      TYPE(*CHAR) LEN(2)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&COMTYP)     TYPE(*CHAR) LEN(2)
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
                          &COMTYP &SORT &RCODE)


/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO


/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
                SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &FDATE +
                &TDATE &FDTE6 &TDTE6 &RETURN &VP &JOBQ &DEV &FORM   +
                &RTE# &COMTYP &RCODE)) +
                JOB(&SBMPGM)
                GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

             MSGBFC     MESSAGE('Selecting records')

   /* Create selection criteria string. */

SELECT:
             CHGVAR     VAR(&QRYSLT) VALUE('LCHWHS *EQ ' *CAT &WHSE)

             IF         COND(&RTE# *NE *ALL)                       +
             THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LCHRTE  +
                        *EQ ' *CAT &RTE#))
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                         '((LCHSTD *EQ %RANGE('  *CAT &FDATE +
                         *BCAT &TDATE *CAT ')))')


             OVRDBF     FILE(&FILE) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                        SEQONLY(*NO) OPTIMIZE(*FIRSTIO)


             CALL       PGM(GETUNQMEM) PARM(*REUSE RTECOMM  &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE RTECOMTY &MEMBER2)
             CALL       PGM(GETUNQMEM) PARM(*REUSE RTECOMMW &MEMBER3)

             OVRDBF     FILE(RTECOMM) MBR(&MEMBER)
             OVRDBF     FILE(RTECOMTY) MBR(&MEMBER2)
             CALL       PGM(LOADR27) PARM(&FDATE &TDATE &COMTYP &RCODE)

/*-------------------------------------------------------------------*/
/* If viewing the report */

             IF         COND(&VP *EQ 'V') THEN(DO)

             CALL       PGM(LOADR28) PARM(&FDTE6 &TDTE6 &RETURN)

             IF (&RETURN = '*CANCEL') THEN(GOTO NOMSG)

/*           IF (&RETURN = '*CANCEL') THEN(DO)                       */
/*           CHGVAR     VAR(&RETURN)  VALUE('       ')               */
/*           RCLRSC     LVL(*CALLER)                                 */
/*           RMVM       FILE(RTECOMM) MBR(&MEMBER)                   */
/*           MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)                       */
/*           RMVM       FILE(RTECOMTY) MBR(&MEMBER2)                 */
/*           MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)                       */
/*           RMVM       FILE(RTECOMTY) MBR(&MEMBER2)                 */
/*           MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)                       */
/*           GOTO OPTNS                                              */
/*           ENDDO                                                   */

             IF (&RETURN = '*EXIT') THEN(DO)
             CHGVAR     VAR(&RETURN)  VALUE('       ')
             GOTO       CMDLBL(NOMSG)
             ENDDO

             IF         (&RETURN = '*F21') GOTO CMDLBL(PRINTRPT)
             ELSE       GOTO CMDLBL(NOMSG)
             ENDDO


/*-------------------------------------------------------------------*/
PRINTRPT:
/* Printing the report */



/* Comments sorted by 'Written by'                                   */

             IF (&SORT = '2') THEN(DO)
             RUNQRY     QRY(RTECOMMW) OUTTYPE(*OUTFILE) +
                                      OUTFILE(RTECOMMW &MEMBER3)

             OVRDBF     FILE(RTECOMMW) TOFILE(RTECOMMW) MBR(&MEMBER3)

             OVRPRTF    FILE(LOAD30PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(LOADR30) PARM(&COMTYP &FDTE6 &TDTE6)
             ENDDO

             ELSE       (DO)

             OVRPRTF    FILE(LOAD29PR) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             CALL       PGM(LOADR29) PARM(&COMTYP &FDTE6 &TDTE6)
             ENDDO

             IF (&TYPE = '0') THEN(GOTO BOTTOM)
             GOTO CMDLBL(NOMSG)

/*-------------------------------------------------------------------*/
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

             RMVM       FILE(RTECOMM) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             RMVM       FILE(RTECOMTY) MBR(&MEMBER2)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             RMVM       FILE(RTECOMMW) MBR(&MEMBER3)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             IF (&RETURN = '*CANCEL') THEN(DO)
             CHGVAR     VAR(&RETURN)  VALUE('       ')
             RCLRSC     LVL(*CALLER)
             GOTO OPTNS
             ENDDO

BOTTOM:
             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
