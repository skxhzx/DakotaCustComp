/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RU371CL   Cleared flags report                                   */
/*  DECEMBER 6, 2007                                                 */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    ##/##/##  CBIa-JGD                                             */
/*      TEXT . . .                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RU371CL:    PGM        PARM(&WHSE &TDTE8 &FDTE8 &FDTE6 &TDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM &RPTT)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU371CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU374)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Cleared flags report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing cleared flags report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLOSED)     TYPE(*CHAR) LEN(1) VALUE('C')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILNAM1)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&MEMBER1)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER2)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&FDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&FDTE8)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TDTE8)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&RPTT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &FDTE8 &TDTE8 &FDTE6 +
                            &TDTE6 &RETURN &VP &JOBQ &DEV &FORM &RPTT)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
                SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                           MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
                RETURN
                ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
                SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &TDTE8 +
                &FDTE8 &FDTE6 &TDTE6 &RETURN &VP &JOBQ &DEV &FORM  +
                &RPTT)) JOB(&SBMPGM)
                GOTO       CMDLBL(GETOUT)
                ENDDO

/*  Otherwise, run program. */

 REPORT:

                MSGBFC     MESSAGE('Selecting records')


            /*  Temp file being created to be used as output */
            /*  file by query 'Runner' below.                */

   /* Qry reads 'Runner' file, brakes down datestamp field into 2   +
      fields 'date' and 'time', writes record out. This new file is +
      a mirror image of 'Runner' file, and it is used by the OpnQry.*/


/*    - Get unique member to use.                      */
             CALL       PGM(GETUNQMEM) PARM(*REUSE RUNCPY &MEMBER1)

             RUNQRY     QRY(RUNNER) OUTFILE(RUNCPY &MEMBER1)


   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('RUWHSE *EQ ' *CAT &WHSE)

/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')  */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *EQ' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)                           */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                         '((RUODTD *EQ %RANGE('  *CAT &FDTE8 +
                         *BCAT &TDTE8 *CAT ')))')


             OVRDBF     FILE(RUNCPY) TOFILE(RUNCPY) MBR(&MEMBER1) +
                        SHARE(*YES)

             OPNQRYF    FILE((RUNCPY &MEMBER1)) QRYSLT(&QRYSLT) +
                        SEQONLY(*NO) OPTIMIZE(*FIRSTIO)



/*    - Get unique member to use.                      */
             CALL       PGM(GETUNQMEM) PARM(*REUSE RU372 &MEMBER2)



            /*-----------------------------------------*/
            /*  Create updated version of qry flag file*/
            /*-----------------------------------------*/

             OVRDBF     FILE(RUNCPY) TOFILE(RUNCPY) MBR(&MEMBER1) +
                        SHARE(*YES)

             OVRDBF     FILE(RU372) MBR(&MEMBER2)
             CALL       PGM(RU371D) PARM(&FDTE8 &TDTE8)


            /*-----------------------------------------*/
            /*  Create flag summary file               */
            /*-----------------------------------------*/

             RUNQRY     QRY(FLGRPT1) QRYFILE((RU372 &MEMBER2))

            /*  Print report by Summary, Detail or Both */

             IF         (&VP   = 'P') THEN(DO)
             IF         (&RPTT = 'S') THEN(GOTO PRINTSUM) /* Summary */
             IF         (&RPTT = 'D') THEN(GOTO PRINTDTL) /* Detail  */
             ELSE       GOTO BOTH                         /* Both    */
             ENDDO

 VIEW:
 SUMMARY:

             RUNQRY     QRY(FLGRPT2) OUTTYPE(*RUNOPT) +
                        PRTDEV(&DEV) FORMTYPE(&FORM)
             GOTO       CMDLBL(GETOUT)


PRINTSUM:

             RUNQRY     QRY(FLGRPT3) OUTTYPE(*RUNOPT) +
                        PRTDEV(&DEV) FORMTYPE(&FORM)
             GOTO       CMDLBL(GETOUT)


PRINTDTL:

             RUNQRY     QRY(RUNNERY) QRYFILE((RU372 +
                        &MEMBER2)) PRTDEV(&DEV) FORMTYPE(&FORM)
             GOTO       CMDLBL(GETOUT)

BOTH:

             RUNQRY     QRY(FLGRPT3) OUTTYPE(*RUNOPT) +
                        PRTDEV(&DEV) FORMTYPE(&FORM)

             RUNQRY     QRY(RUNNERY) QRYFILE((RU372 +
                        &MEMBER2)) PRTDEV(&DEV) FORMTYPE(&FORM)


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

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(RUNCPY) MBR(&MEMBER1)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             RMVM       FILE(RU372)  MBR(&MEMBER2)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             ENDPGM
