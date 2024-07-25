/*-----------------------------------------------------------------*/
/*  Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved    */
/*  BFC Software, Inc.                                             */
/*  P.O. Box 1957                                                  */
/*  Batavia, IL 60510                                              */
/*  (630) 562-0375                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRIMPCL    Never-Ending PIR Import Job                        */
/*  11 October 2006                                                */
/*  Max Blacknik                                                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions                                                      */
/*                                                                 */
/*  10/11/06  MLB  5.10                                            */
/*    - Created.                                                   */
/*                                                                 */
/*  02/07/14  MLB  6.50                                            */
/*    - Enh: Revised pgm add support for new global staging import */
/*      library / environment.                                     */
/*                                                                 */
/*    06/28/21  MLB  7.50                                          */
/*      - Added client custom code support to program              */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Chef's Warehouse                      */
/*                                                                 */
/*  06/28/21  MLB  DRY                                             */
/*    - Revised pgm to set &PRTDEV = LPRT01 to override device on  */
/*      end user's job so that import reports are directed to      */
/*      correct printer/outq.                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/

 PIRIMPCL:   PGM        PARM(&DELAYTIME &RUNTIMEENV)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (750 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */


/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (750 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (750 A) */
             DCL        VAR(&DELAYTIME)  TYPE(*DEC)  LEN(6 0)
             DCL        VAR(&ENDSTATUS)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PRTDEV)     TYPE(*CHAR) LEN(10)      /* (DRY A) */
/*           DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(5)          (650 D) */
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(10)      /* (650 M) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (750 A) */

/*           RTVJOBA    TYPE(&TYPE)                               /* (DRY D) */
             RTVJOBA    TYPE(&TYPE) PRTDEV(&PRTDEV)               /* (DRY M) */


/* First time, run program to check directory for files to import. */
             IF         COND(&TYPE = '0') THEN(DO)
               GOTO       CMDLBL(PROCESSDIR)
             ENDDO

             IF         COND(&CLIENT *EQ &DAIRYLAND) THEN(DO)     /* (DRY A) */
               CHGVAR     VAR(&PRTDEV) VALUE(LPRT01)              /* (DRY A) */
             ENDDO                                                /* (DRY A) */

/* Otherwise, Submit program to batch for processing.              */
             IF COND(&RUNTIMEENV = '*TEST') THEN(DO)

               SBMJOB     CMD(PIRIMPORT DELAYTIME(&DELAYTIME) +
                            RUNTIMEENV(&RUNTIMEENV)) JOB(PIRIMPCL) +
                            JOBD(PIR/PIRJOBDTST) JOBQ(QS36EVOKE) +
                            PRTDEV(&PRTDEV)                       /* (DRY M) */
             ENDDO
             ELSE       CMD(DO)
               SBMJOB     CMD(PIRIMPORT DELAYTIME(&DELAYTIME) +
                            RUNTIMEENV(&RUNTIMEENV)) JOB(PIRIMPCL) +
                            JOBD(*LIBL/PIRJOBD) JOBQ(QS36EVOKE) +
                            PRTDEV(&PRTDEV)                       /* (DRY M) */
/*                          JOBD(*LIBL/BFCPGMR) JOBQ(QS36EVOKE)      (650 D) */
             ENDDO

             RETURN

/* Make job wait here until time expires. */

 SLEEP:      DLYJOB     DLY(&DELAYTIME)

/* See if job and/or subsystem is being ended. */

             RTVJOBA    ENDSTS(&ENDSTATUS)
             IF         COND(&ENDSTATUS = '1') THEN(DO)
               SNDPGMMSG  MSG('** Attention ** BFC Dakota /  Import +
                            job is being ended. Please verify job +
                            PIRIMPCL job is running in QBATCH +
                            subsystem after system restarts.') +
                            TOMSGQ(*SYSOPR)
               GOTO       CMDLBL(GETOUT)
             ENDDO

PROCESSDIR:                                                       /* (650 A) */
             SELECT                                               /* (650 A) */
             WHEN       COND(&RUNTIMEENV = '*STAGE' +
                         *OR &RUNTIMEENV = '*STAGETEST') THEN(DO) /* (650 A) */
/*-----------------------------------------------------------------  (650 A) */
/*        Call Pgm to Check Staging Import lib for Files to Import.  (650 A) */
/*-----------------------------------------------------------------  (650 A) */
                                                                  /* (650 A) */
                                                                  /* (650 A) */
               CALL       PGM(PIRIMPSTG) PARM(&RUNTIMEENV)        /* (650 A) */
             ENDDO                                                /* (650 A) */
                                                                  /* (650 A) */
             WHEN       COND(&RUNTIMEENV = '*PROD' +
                         *OR &RUNTIMEENV = '*TEST') THEN(DO)      /* (650 A) */
/*-----------------------------------------------------------------*/
/*        Call Program to Check IFS for Files to Import.           */
/*-----------------------------------------------------------------*/

/*PROCESSDIR:                                                        (650 D) */

             CALL       PGM(PIRDIR)
             ENDDO                                                /* (650 A) */
             ENDSELECT                                            /* (650 A) */

/*-----------------------------------------------------------------*/
/*        Go back to sleep at Top.                                 */
/*-----------------------------------------------------------------*/

             GOTO       CMDLBL(SLEEP)

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
