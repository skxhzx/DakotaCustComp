/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR730CL   Export customer returns.                               */
/*  10 November, 1994                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/24/96  DAS  2.13                                            */
/*      - Added new constants &PGMTYPE and &ORDTYPE to identify      */
/*        normal, transfer or POS.                                   */
/*      - Added &PGMTYPE to options program.                         */
/*      - Added &ORDTYPE to &QRYSLT statement.                       */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*    07/06/99  DAS  4.11                                            */
/*      - Revised to work with FTP export.                           */
/*      - Added &FTP parameter to OR730 call.                        */
/*      - Used parameter to either call OR735 (&FTP=N) or            */
/*        OR736CL (&FTP=Y).                                          */
/*                                                                   */
/*    10/19/01  MLB  4.16                                            */
/*      - Revised &QRYSLT to include return records with             */
/*        ORTYPE = 'U', Return records changed during close.         */
/*    08/19/02  RH   4.16a                                           */
/*      - Revised &QRYSLT to not use return type ORTYPE.             */
/*        ORTYPE='Q', Quick returns use an export option.          */
/*                                                                   */
/*    04/01/16  MLB  7.00                                            */
/*      - Enh: Added client custom code support to program.          */
/*    04/01/16  MLB  7.00a                                           */
/*      - Enh: Revised program to add support for calling staging    */
/*        export program.                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    08/01/13  MLB  DRY                                             */
/*      - Revised program to call Staging Export interface pgm even  */
/*        though FTP Export option is set to Y=Yes. Client in        */
/*        process of migrating to new Host ERP and will use Staging  */
/*        Export interfaces going forward.                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Springfield Grocery                     */
/*                                                                   */
/*    09/19/17  MLB  SGC                                             */
/*      - Enh: Revised pgm to submit exports to jobq BATCH in        */
/*        library PWRUSER. Per Bill H. email.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Seashore                                */
/*    06/24/22  RH   SFP                                             */
/*      - TEMP:  Do not allow Seashore to export Returns while using */
/*        Thyme for ERP.                                             */
/*        Disable when they change to FreshBytes for ERP.            */
/*-------------------------------------------------------------------*/

 OR730CL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (700 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */
             DCL        VAR(&SGC)     TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')                            /* (SGC A) */
             DCL        VAR(&SFP)     TYPE(*CHAR) LEN(10) +
                          VALUE('SEASHORE  ')                     /* (SGC A) */

  /* Program type. */

             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(8) +
                          VALUE('*NORMAL ')
             DCL        VAR(&ORDTYPE) TYPE(*CHAR) LEN(1) +
                          VALUE(' ')
             DCL        VAR(&ORDTYPEU) TYPE(*CHAR) LEN(1) +
                          VALUE('U')                             /* (416) */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR730CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OR730)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OR735)

  /* Main FTP program. */

             DCL        VAR(&FTPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(OR736CL)
             DCL        VAR(&STGPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR736SCL)                         /* (700aA) */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Export customer returns')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Exporting customer returns')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (700 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (700 A) */
             DCL        VAR(&FTP)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(10)      /* (SGC A) */
             DCL        VAR(&JOBQLIB)    TYPE(*CHAR) LEN(10)      /* (SGC A) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (700 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (700 A) */

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO MAIN)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PGMTYPE &RETURN &WHSE &FTP)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO
/*  DO NOT ALLOW OPTION FOR SEASHORE SFPa.   */
             IF         COND(&CLIENT = &SFP) THEN(DO)             /* (SFFPaA) */
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN                                             /* (SFPaA) */
             ENDDO                                                /* (SFPaA) */

/*  See if user wants to put report on JOBQ. */

     /* 411 A  Use FTP option to call appropriate program */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
/*             IF (&FTP = 'Y') THEN(DO)                              (700aD) */
               SELECT                                             /* (700aA) */
               when (&FTP = 'Y') THEN(DO)                         /* (700aM) */
                 SELECT                                           /* (DRY A) */
                 WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)   /* (DRY A) */
                   SBMJOB     CMD(CALL PGM(&STGPGM) PARM(&WHSE)) +
                                JOB(&STGPGM)                      /* (DRY A) */
                 ENDDO                                            /* (DRY A) */

                 when       COND(&CLIENT = &SGC) THEN(DO)         /* (SGC A) */
                   CHGVAR     VAR(&JOBQ) VALUE('BATCH')           /* (SGC A) */
                   CHGVAR     VAR(&JOBQLIB) VALUE('PWRUSER')      /* (SGC A) */
                   SBMJOB CMD(CALL PGM(&FTPPGM) PARM(&WHSE &ORDTYPE)) +
                            JOB(&FTPPGM) jobq(&jobqlib/&jobq)     /* (SGC A) */
                 enddo                                            /* (SGC A) */

                 OTHERWISE  CMD(DO)                               /* (DRY A) */
                 SBMJOB CMD(CALL PGM(&FTPPGM) PARM(&WHSE &ORDTYPE)) +
                          JOB(&FTPPGM)
                 enddo                                            /* (DRY A) */
                 ENDSELECT                                        /* (DRY A) */
               ENDDO

/*             Staging File Export method in use.                    (700aA) */
               when (&FTP = 'S') THEN(DO)                         /* (700aA) */
                 SBMJOB     CMD(CALL PGM(&STGPGM) PARM(&WHSE)) +
                              JOB(&STGPGM)                        /* (700aA) */
               Enddo                                              /* (700aA) */

/*             IF (&FTP *NE 'Y') THEN(DO)                            (700aD) */
               OTHERWISE  CMD(DO)                                 /* (700aM) */
                 SBMJOB  CMD(CALL PGM(&SBMPGM) PARM(&WHSE)) JOB(&SBMPGM)
               ENDDO
               ENDSELECT                                          /* (700aA) */
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

     /* 411 A  FTP uses a different program */

/*           IF (&FTP = 'Y') THEN(DO)                                (700aD) */
             SELECT                                               /* (700aA) */
             When (&FTP = 'Y') THEN(DO)                           /* (700aM) */
                 SELECT                                           /* (DRY A) */
                 WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)   /* (DRY A) */
                   CALL       PGM(&STGPGM) PARM(&WHSE)            /* (DRY A) */
                   GOTO GETOUT                                    /* (DRY A) */
                 ENDDO                                            /* (DRY A) */

                 OTHERWISE  CMD(DO)                               /* (DRY A) */
               CALL PGM(&FTPPGM) PARM(&WHSE &ORDTYPE)
               enddo                                              /* (DRY A) */
               ENDSELECT                                          /* (DRY A) */
               Enddo                                              /* (700aA) */

/*             Staging File Export method in use.                    (700aA) */
               WHEN       COND(&FTP = 'S') THEN(DO)               /* (700aA) */
                 CALL PGM(&STGPGM) PARM(&WHSE)                    /* (700aA) */
                 GOTO GETOUT                                      /* (700aA) */
               Enddo                                              /* (700aA) */
               ENDSELECT                                          /* (DRY A) */
/*             GOTO GETOUT                                           (700aD) */
/*           ENDDO                                                   (700aD) */
 MAIN:

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to export')

             OVRDBF     FILE(ORRTN) SHARE(*YES)
             CHGVAR     VAR(&QRYSLT) VALUE('(ORWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (ORUDTE *EQ 0)')    /* 416a      */
/*           CHGVAR     VAR(&QRYSLT) VALUE('(ORWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (ORUDTE *EQ 0) *AND (ORTYPE +
                          *EQ' *BCAT &QUOTE *CAT &ORDTYPE *CAT +
                          &QUOTE *CAT ')')                        (416) */
/*           CHGVAR     VAR(&QRYSLT) VALUE('(ORWHSE *EQ' *BCAT &WHSE +
                          *CAT ') *AND (ORUDTE *EQ 0) *AND (ORTYPE +
                          *EQ' *BCAT &QUOTE *CAT &ORDTYPE *CAT +
                          &QUOTE *BCAT '*OR ORTYPE *EQ' *BCAT +
                          &QUOTE *CAT &ORDTYPEU *CAT &QUOTE *CAT +
                          ')')  (416a) */  /*   (416) */
             OPNQRYF    FILE((ORRTN)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((ORWHSE) (ORORD) (ORITEM) (ORRDTE) +
                          (ORRTIM))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
