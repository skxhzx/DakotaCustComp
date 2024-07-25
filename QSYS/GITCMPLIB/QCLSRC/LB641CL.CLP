/*-------------------------------------------------------------------*/
/*  LB641CL:  Label re-print audit view/print                        */
/*  October 13, 2004                                                 */
/*  Jose G. Duque                                                    */
/*                                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    MM/DD/YY  CBI-XXX                                              */
/*      Text.....................                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LB641CL:    PGM        PARM(&WHSE &FDATE &TDATE &FDTE6 &TDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LB641CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LB644)

  /* Open query input file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABELOG)

  /* Infotmational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Reprint Labels Audit')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Printing ''Reprint Labels Audit')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILNAM)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&FDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 OPTNS:

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &FDATE &TDATE &FDTE6 +
                            &TDTE6 &RETURN &VP &JOBQ &DEV &FORM)

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

             CHGVAR     VAR(&QRYSLT) VALUE('LGWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           '((LGDATE *EQ %RANGE(' *CAT +
                              &FDATE *BCAT &TDATE *CAT ')))')


             OVRDBF     FILE(LB641) TOFILE(&FILE) SHARE(*YES)

             OPNQRYF    FILE((&FILE)) FORMAT(LB641) QRYSLT(&QRYSLT) +
                          KEYFLD((LGWHSE) (LGDATE) (LGUSER)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             CHGVAR     VAR(&FILNAM) VALUE('OR' || &TIME)

             CPYFRMQRYF FROMOPNID(&FILE) TOFILE(QTEMP/&FILNAM) +
                        MBROPT(*ADD) CRTFILE(*YES)


/* If viewing the report */

             IF         COND(&VP *EQ 'V') THEN(DO)

             CALL       PGM(LB643) PARM(&RETURN)

             IF (&RETURN = '*CANCEL') THEN(DO)
             CLOF       OPNID(&FILE)
             CHGVAR     VAR(&RETURN)  VALUE('       ')
             GOTO OPTNS
             ENDDO

             IF         (&RETURN = '*F21') GOTO CMDLBL(PRINTRPT)
             ELSE
                        GOTO CMDLBL(NOMSG)
             ENDDO


PRINTRPT:

             OVRDBF     FILE(LB641) TOFILE(&FILNAM) SHARE(*YES)

             RUNQRY     QRY(LBLPRT) OUTTYPE(*RUNOPT) +
                            PRTDEV(&DEV) FORMTYPE(&FORM)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
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

             DLTF       FILE(QTEMP/&FILNAM)
             RCLRSC     LVL(*CALLER)

             ENDPGM
