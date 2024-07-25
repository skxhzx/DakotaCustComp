/*-----------------------------------------------------------------*/
/*  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved    */
/*  BFC Software, Inc.                                             */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                         */
/*  West Chicago, IL  60185                                        */
/*  (630) 562-0375                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIREXPCL    Never-Ending PIR Export Job                        */
/*  10 April 2007                                                  */
/*  Max Blacknik                                                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions                                                      */
/*                                                                 */
/*  04/10/07  MLB  5.10                                            */
/*    - Created.                                                   */
/*    - Enh: Added client custom code support to program.          */
/*                                                                 */
/*  07/28/08  MLB  5.20                                            */
/*    - Enh: Added new parm, &USRID for job to run under.          */
/*      User ID will have job description/library list for job.    */
/*  07/28/08  MLB  5.20a                                           */
/*    - Enh: Added support for new *dtaara PIRENDEXP. Upon         */
/*      wakeup, check dtaara to see if export job should end.      */
/*  08/13/08  MLB  5.20b                                           */
/*    - Enh: Revised standard SBMJOB cmd defaults. Changed         */
/*      parms: PRTDEV, OUTQ to *USRPRF from *CURRENT so that       */
/*      export reports go to correct outq's.                       */
/*  08/14/08  MLB  5.20c                                           */
/*    - Enh: Removed all SBMJOB cmd code. This code moved to       */
/*      new pgm, PIREXP1CL. CPP cmd, PIREXPORT changed to call     */
/*      PIREXP1CL so that job is submitted with correct parms.     */
/*                                                                 */
/*  08/10/10  MLB  5.30                                            */
/*    - Created.                                                   */
/*    - Enh: Added client custom code support to program.          */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                    */
/*                                                                 */
/*  03/26/07  MLB  PAK                                             */
/*    - Added two new &runtimeenv parms:                           */
/*        *SAPPROD  - SAP Production environment                   */
/*        *SAPQA    - SAP QA environment                           */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Glazier Foods                         */
/*                                                                 */
/*  08/10/10  MLB  GLZ                                             */
/*    - Revised program to send out message that says job is being */
/*      ended from DAKOTA SBS instead of QBATCH SBS.               */
/*                                                                 */
/*-----------------------------------------------------------------*/

 PIREXPCL:   PGM        PARM(&WHSE &DELAYTIME &RUNTIMEENV &USRID) /* (520 M) */

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Customer ID                                                  */

             DCL        VAR(&PACKERS) TYPE(*CHAR) LEN(10) +
                          VALUE('PACKERS')                        /* (PAK A) */
             DCL        VAR(&GLAZIER) TYPE(*CHAR) LEN(10) +
                          VALUE('GLAZIER')                        /* (GLZ A) */

   /* Parameters and work variables */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(78)       /* (520 A) */
             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&DELAYTIME)  TYPE(*DEC)  LEN(6 0)
             DCL        VAR(&ENDDTAARA)  TYPE(*CHAR) LEN(10) +
                                         VALUE('PIRENDEXP')       /* (520aA) */
             DCL        VAR(&ENDSTATUS)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RUNTIMEENV) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USRID)      TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

             RTVJOBA    TYPE(&TYPE)
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)

/*     Validate user profile entered for job to run under.           (520 A) */
             if         cond(&USRID *GT ' ') then(DO)             /* (520 A) */
               CHKOBJ     OBJ(&USRID) OBJTYPE(*USRPRF)            /* (520 A) */
               MONMSG     MSGID(CPF9801) EXEC(DO)                 /* (520 A) */
               CHGVAR     VAR(&CANCELMSG) VALUE('User ID- ' *cat +
                            &usrid *tcat ' does not exist. PIREXPORT +
                            job cannot be started.')              /* (520 A) */
                 SNDPGMMSG  MSGID(PIR9999) MSGF(PIRMSGF) +
                            MSGDTA(&CANCELMSG) MSGTYPE(*INFO)     /* (520 A) */
                 RETURN                                           /* (520 A) */
               ENDDO                                              /* (520 A) */
             ENDDO                                                /* (520 A) */

/* Send job to check for data to export before going to sleep.               */

             GOTO       CMDLBL(PROCESSFTP)

/* Make job wait here until time expires. */

 SLEEP:      DLYJOB     DLY(&DELAYTIME)

/* See if job and/or subsystem is being ended. */

             RTVJOBA    ENDSTS(&ENDSTATUS)
/* Or normal shutdown has been requested.                            (520aA) */
             IF         COND(&ENDSTATUS *NE '1') THEN(DO)         /* (520aA) */
               RTVDTAARA  DTAARA(&ENDDTAARA) RTNVAR(&ENDSTATUS)   /* (520aA) */
               IF COND(&ENDSTATUS *EQ '1') THEN(DO)               /* (520aA) */
                 CHGDTAARA  DTAARA(&ENDDTAARA) VALUE('0')         /* (520aA) */
               ENDDO                                              /* (520aA) */
             ENDDO                                                /* (520aA) */

             IF         COND(&ENDSTATUS = '1') THEN(DO)
               IF         COND(&CLIENT = &GLAZIER) then( +
                 SNDPGMMSG  MSG('** Attention ** BFC Dakota /  Export +
                              job is being ended. Please verify job +
                              AUTOSTREXP is running in DAKOTA +
                              subsystem after system restarts.') +
                              TOMSGQ(*SYSOPR))                    /* (GLZ A) */
               ELSE cmd( +
               SNDPGMMSG  MSG('** Attention ** BFC Dakota /  Export +
                            job is being ended. Please verify job +
                            PIREXPCL is running in QBATCH +
                            subsystem after system restarts.') +
                            TOMSGQ(*SYSOPR) )                     /* (GLZ M) */
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*-----------------------------------------------------------------*/
/*        Call Program to Check for File(s) to Export.             */
/*-----------------------------------------------------------------*/

PROCESSFTP:

             CALL       PGM(PIREXP) PARM(&WHSE &RUNTIMEENV)

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
