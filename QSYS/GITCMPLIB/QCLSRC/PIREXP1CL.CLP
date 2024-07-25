/*-----------------------------------------------------------------*/
/*  Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved    */
/*  BFC Software, Inc.                                             */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                         */
/*  West Chicago, IL  60185                                        */
/*  (630) 562-0375                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIREXP1CL    Submits Never-Ending PIR Export Job               */
/*  14 August 2008                                                 */
/*  Max Blacknik                                                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions                                                      */
/*                                                                 */
/*  08/14/08  MLB  5.20                                            */
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
/*    - Changed all submits to use PIREXPORT2 cmd.                 */
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
/*  07/16/10  MLB  GLZ                                             */
/*    - Enh: Revised program to submit auto-export job to          */
/*      jobq BFCEXPORT running in DAKOTA subsystem.                */
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
/*           DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)          (GLZ D) */
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(10)      /* (GLZ M) */
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
             IF         COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               CHGVAR     VAR(&JOBQ) VALUE('BFCEXPORT')           /* (GLZ A) */
             enddo                                                /* (GLZ A) */
             ELSE       CMD(DO)                                   /* (GLZ A) */
               CHGVAR     VAR(&JOBQ) VALUE('QS36EVOKE')           /* (GLZ A) */
             enddo                                                /* (GLZ A) */

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

/* Otherwise, Submit program to batch for processing.              */
             IF COND(&RUNTIMEENV = '*TEST') THEN(DO)

/*             SBMJOB     CMD(PIREXPORT WAREHOUSE(&WHSE) +
                            DELAYTIME(&DELAYTIME) +
                            RUNTIMEENV(&RUNTIMEENV)) JOB(PIREXPCL) +
                            JOBD(PIRJOBDTST) JOBQ(QS36EVOKE) LOG(*JOBD +
                            *JOBD *MSG) LOGCLPGM(*YES) +
                            JOBMSGQFL(*PRTWRAP)                      (520 D) */
               SBMJOB     CMD(PIREXPORT2 WAREHOUSE(&WHSE) +
                            DELAYTIME(&DELAYTIME) +
                            RUNTIMEENV(&RUNTIMEENV) USRID(&USRID)) +
                            JOB(PIREXPCL) JOBD(*USRPRF) +
                            JOBQ(&JOBQ) USER(&USRID) +
                            INLLIBL(*JOBD) LOG(*JOBD *JOBD *MSG) +
                            LOGCLPGM(*YES) JOBMSGQFL(*PRTWRAP)    /* (GLZ M) */
             ENDDO

/* Otherwise, Submit program to batch for processing.              */
             ELSE       CMD(IF COND(&RUNTIMEENV = '*SAPPROD') THEN(DO)) +
                                                                  /* (PAK A) */

               SBMJOB     CMD(PIREXPORT2 WAREHOUSE(&WHSE) +
                            DELAYTIME(&DELAYTIME) +
                            USRID(&USRID) +
                            RUNTIMEENV(&RUNTIMEENV)) JOB(SAPPRODEXP) +
                            JOBD(PIRSAPPROD) JOBQ(&JOBQ) +
                            LOG(*JOBD *JOBD *MSG) LOGCLPGM(*YES) +
                            JOBMSGQFL(*PRTWRAP)                   /* (GLZ M) */
             ENDDO                                                /* (PAK A) */

/* Otherwise, Submit program to batch for processing.              */
             ELSE       CMD(IF COND(&RUNTIMEENV = '*SAPQA') THEN(DO)) +
                                                                  /* (PAK A) */

               SBMJOB     CMD(PIREXPORT2 WAREHOUSE(&WHSE) +
                            DELAYTIME(&DELAYTIME) +
                            USRID(&USRID) +
                            RUNTIMEENV(&RUNTIMEENV)) JOB(SAPQAEXP) +
                            JOBD(PIRSAPQA) JOBQ(&JOBQ) LOG(*JOBD +
                            *JOBD *MSG) LOGCLPGM(*YES) +
                            JOBMSGQFL(*PRTWRAP)                  /* (GLZ M) */
             ENDDO                                               /* (PAK A) */

             ELSE       CMD(DO)
/*             SBMJOB     CMD(PIREXPORT WAREHOUSE(&WHSE) +
                            DELAYTIME(&DELAYTIME) +
                            RUNTIMEENV(&RUNTIMEENV)) JOB(PIREXPCL) +
                            JOBD(PIRJOBD) JOBQ(QS36EVOKE) LOG(*JOBD +
                            *JOBD *MSG) LOGCLPGM(*YES) +
                            JOBMSGQFL(*PRTWRAP)                   /* (520 D) */
               SBMJOB     CMD(PIREXPORT2 WAREHOUSE(&WHSE) +
                            DELAYTIME(&DELAYTIME) +
                            RUNTIMEENV(&RUNTIMEENV) USRID(&USRID)) +
                            JOB(PIREXPCL) JOBD(*USRPRF) +
                            JOBQ(&JOBQ) PRTDEV(*USRPRF) +
                            OUTQ(*USRPRF) USER(&USRID) INLLIBL(*JOBD) +
                            LOG(*JOBD *JOBD *MSG) LOGCLPGM(*YES) +
                            JOBMSGQFL(*PRTWRAP)                   /* (GLZ M) */
             ENDDO

             RETURN

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
