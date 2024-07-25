/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH155SCL   Stage - Export closed customer orders to Host         */
/*  18 May 2011                                                      */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/18/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*        This program calls a java program that takes export        */
/*        data from staging files and creates custom defined Host    */
/*        files.                                                     */
/*    05/23/11  MLB  6.40a                                           */
/*      - Enh: Revised program to add library QSHELL before library  */
/*        QTEMP so that QSHELL msgs are issued correctly.            */
/*    11/02/11  MLB  6.40b                                           */
/*      - Revised program to ovrprtf cmd to direct QPRINT output     */
/*        to outq QPRINT.                                            */
/*    11/02/11  MLB  6.40c                                           */
/*      - Enh: Revised pgm to only print joblog when RH155SCL is     */
/*        called from batch.                                         */
/*                                                                   */
/*    09/22/13  MLB  6.50                                            */
/*      - Enh: Revised program to call pgm, RH155S to export         */
/*        customer orders to staging files.                          */
/*    11/21/14  MLB  6.50a                                           */
/*      - Enh: Revised program to direct export jobs to EXPSTGwww    */
/*        where w=warehouse number. Per Kelly R. conf. call 11/21/14.*/
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*    05/18/11  MLB  EFC                                             */
/*      - Revised program to call Java interface pgm, RunExportCO.sh */
/*        to interface with Dynamics SL v7.00.                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH155SCL:   PGM        PARM(&PCMD &PWHS &PRTID &PTRTE &PRTN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */

             DCL        VAR(&Eastland) TYPE(*CHAR) LEN(10) +
                          VALUE('EASTLAND')                       /* (EFC A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXIST)      TYPE(*CHAR) LEN(1)       /* (650aA) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHS)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&PWHSE)      TYPE(*DEC)  LEN(3 0)     /* (EFC A) */
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PTRTE)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PPRG)       TYPE(*CHAR) LEN(10)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE(' ')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE(' ')

/*  Don't get options, if being run from JOBQ. */

/* Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             SELECT
             WHEN       COND(&PCMD = '*ALL') THEN(DO)
               CHGVAR     VAR(&JOBQ) VALUE('EXPSTG' *cat &pwhs)   /*(650aA) */

               CHGVAR     VAR(&EXIST) VALUE('1')                  /* (650aA) */
               CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)               /* (650aA) */
               MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                            VALUE('0'))                           /* (650aA) */
               IF         COND(&EXIST = '0') THEN(DO)             /* (650aA) */
               CHGVAR     VAR(&JOBQ) VALUE('QS36EVOKE')
               Enddo                                              /* (650aA) */
             enddo
             OTHERWISE  CMD(DO)
               CHGVAR     VAR(&JOBQ) VALUE('*JOBD')
             enddo
             endselect

             ADDLIBLE   LIB(QSHELL) POSITION(*BEFORE QTEMP)       /* (640aA */
             MONMSG     MSGID(CPF2103)                            /* (640aA)*/
             SBMJOB     CMD(CALL PGM(RH155SCL) PARM(&PCMD &PWHS +
                          &PRTID &PTRTE &PRTN)) JOB(RH155SCL) +
                          JOBQ(&JOBQ)
             GOTO       CMDLBL(GETOUT)

/*  Otherwise, run program. */

 REPORT:

             SELECT                                               /* (EFC A) */
             WHEN       COND(&CLIENT = &EASTLAND) THEN(DO)        /* (EFC A) */
             OVRPRTF    FILE(QPRINT) TOFILE(QGPL/QPRINT) +
                          OUTQ(QPRINT)                            /* (640bA) */
             QSH        CMD('/PIRIFCDYNSL0700/RunExportCO.sh')
             enddo                                                /* (EFC A) */
             OTHERWISE  CMD(DO)                                   /* (650 A) */
               CHGVAR VAR(&PWHSE) VALUE(&PWHS)                    /* (650 A) */
               OVRDBF FILE(STGBATCH) TOFILE(STGBATCH) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDH) TOFILE(EXPSORDH) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDD) TOFILE(EXPSORDD) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDC) TOFILE(EXPSORDC) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDT) TOFILE(EXPSORDT) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDB) TOFILE(EXPSORDB) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDE) TOFILE(EXPSORDE) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDL) TOFILE(EXPSORDL) FRCRATIO(1) /* (650 A) */
               OVRDBF FILE(EXPSORDP) TOFILE(EXPSORDP) FRCRATIO(1) /* (650 A) */
               call rh155s parm(&pcmd &pwhse &prtid &ptrte &prtn) /* (650 A) */
             enddo                                                /* (650 A) */
             endselect                                            /* (650 A) */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
/*           IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))(640cD) */
             IF         COND(&MSGID *EQ ' ') THEN(DO)             /* (640cM) */
               IF       COND(&TYPE = '0') THEN(DO)                /* (640cA) */
                 OVRPRTF    FILE(QPJOBLOG) OUTQ(BFCEXCP)          /* (640cA) */
                 DSPJOBLOG  OUTPUT(*PRINT)                        /* (640cA) */
               ENDDO                                              /* (640cA) */
               GOTO CMDLBL(NOMSG)                                 /* (640cA) */
             ENDDO                                                /* (640cA) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

             RCLRSC     LVL(*CALLER)

             ENDPGM
