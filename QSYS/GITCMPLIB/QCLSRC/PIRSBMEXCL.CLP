/*-----------------------------------------------------------------*/
/*  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved    */
/*  BFC Software, Inc.                                             */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                         */
/*  West Chicago, IL  60185                                        */
/*  (630) 562-0375                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRSBMEXCL    Submit PIR FTP Export Jobs                       */
/*  11 April 2007                                                  */
/*  Max Blacknik                                                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions                                                      */
/*                                                                 */
/*  04/11/07  MLB  5.10                                            */
/*    - Created.                                                   */
/*                                                                 */
/*  07/28/08  MLB  5.20                                            */
/*    - Enh: Revised program to set &JOBD to *USRPRF when          */
/*      &RUNTIMEENV = *PROD or *TEST.                              */
/*  08/14/08  MLB  5.20a                                           */
/*    - Enh: Revised P/O SBMJOB cmd defaults. Changed              */
/*      parms: PRTDEV, OUTQ to *USRPRF from *CURRENT so that       */
/*      export reports go to correct outq's.                       */
/*                                                                 */
/*  08/31/10  MLB  5.30                                            */
/*      - Enh: Added client custom code support to program.        */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Glazier Foods                         */
/*                                                                 */
/*  08/31/10  MLB  GLZ                                             */
/*    - Revised program to submit export jobs to jobq BFCEXPORT    */
/*      attached to DAKOTA sbsd. Per Gary S.                       */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Greenleaf Produce                     */
/*                                                                 */
/*  04/22/13  MLB  GLP                                             */
/*    - Revised program to submit IT728SCL to batch instead of     */
/*      IT726CL.                                                   */
/*  04/22/13  MLB  GLPa                                            */
/*    - Revised program to not automatically export purchase       */
/*      orders to ProducePro at this time. Per Franscisco email    */
/*      dated 04/22/13.                                            */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Cash Wa Distributing                  */
/*                                                                 */
/*  04/24/13  MLB  CWD                                             */
/*    - Revised program to submit IT728SCL to batch instead of     */
/*      IT726CL.                                                   */
/*    - Added CWD to GLP mod.                                      */
/*  04/24/13  MLB  CWDa                                            */
/*    - Revised program to bypass export of adjustments and        */
/*      customer returns. Per Scott W. phone call 04/24/13.        */
/*    - This is starting out as a temporary mod.                   */
/*                                                                 */
/*-----------------------------------------------------------------*/

 PIRSBMEXCL:   PGM        PARM(&PCMD &WHSE &RTID &RTE &RUNTIMENV)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.  */

             DCL        VAR(&Glazier)  TYPE(*CHAR) LEN(10) +
                          VALUE('GLAZIER')                        /* (GLZ A) */
             DCL        VAR(&Greenleaf)  TYPE(*CHAR) LEN(10) +
                          VALUE('GREENLEAF')                      /* (GLP A) */
             DCL        VAR(&Cashwa)  TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA')                         /* (CWD A) */

  /* Message queues */

             DCL        VAR(&EXPMSGQ)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXPERRMSGQ) TYPE(*CHAR) LEN(10)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&EXPFORMTYP) TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXPMODE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPOUTQ)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBD)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&ORDTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RUNTIMENV)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

   /* Standard message handling variables */


             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (530 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (530 A) */

             CHGVAR     VAR(&FINISHED) VALUE('0')
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)

             IF COND(&RUNTIMENV = '*TEST') THEN(DO)
/*             CHGVAR     VAR(&JOBD) VALUE('PIRJOBDTST')             (520 D) */
               CHGVAR     VAR(&JOBD) VALUE('*USRPRF')             /* (520 M) */

             ENDDO

             ELSE       CMD(IF COND(&RUNTIMENV = '*SAPPROD') THEN(DO))
               CHGVAR     VAR(&JOBD) VALUE('PIRSAPPROD')

             ENDDO

             ELSE       CMD(IF COND(&RUNTIMENV = '*SAPQA') THEN(DO))
               CHGVAR     VAR(&JOBD) VALUE('PIRSAPQA  ')

             ENDDO

             ELSE       CMD(DO)
/*             CHGVAR     VAR(&JOBD) VALUE('PIRJOBD   ')             (520 D) */
               CHGVAR     VAR(&JOBD) VALUE('*USRPRF')             /* (520 M) */
             ENDDO

   /* Setup Standard Import Processing Variables. */

             CHGVAR     VAR(&EXPMODE) VALUE('*INTER')
             CHGVAR     VAR(&EXPOUTQ) VALUE('*JOB')
             CHGVAR     VAR(&EXPFORMTYP) VALUE('*STD')

/*-----------------------------------------------------------------*/
/*        Submit Export Item Adjustments for processing.           */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*ADJUST') THEN(DO)
               IF         COND(&CLIENT = &CASHWA) THEN(DO)
/*               Do not export adjustments at this time.             (CWD A) */
                 return                                           /* (CWD A) */
               enddo                                              /* (CWD A) */
               CHGVAR     VAR(&EXPMSGQ) VALUE('EXPADJ')
               CHGVAR     VAR(&EXPERRMSGQ) VALUE('EXPADJERR')

             IF         COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               SBMJOB     CMD(CALL PGM(IT726CL) PARM(&WHSEA)) +
                          JOB(IT726CL) JOBD(&JOBD) JOBQ(BFCEXPORT) /*(GLZ A) */
             Enddo                                                /* (GLZ A) */
             Else       Cmd(DO)                                   /* (GLZ A) */
                                                                  /* (GLP A) */
               SELECT                                             /* (GLP A) */
               WHEN       COND(&CLIENT = &GREENLEAF +
                           *or &CLIENT = &Cashwa) THEN(DO)        /* (CWD M) */
                 SBMJOB     CMD(CALL PGM(IT728SCL) PARM(&WHSEA)) +
                              JOB(IT728SCL) JOBD(&JOBD) JOBQ(QS36EVOKE) +
                                                                  /* (GLP A) */
               enddo                                              /* (GLP A) */
               OTHERWISE  CMD(DO)                                 /* (GLP A) */
                                                                  /* (GLP A) */
               SBMJOB     CMD(CALL PGM(IT726CL) PARM(&WHSEA)) +
                            JOB(IT726CL) JOBD(&JOBD) JOBQ(QS36EVOKE)
               enddo                                              /* (GLP A) */
               endselect                                          /* (GLP A) */
                                                                  /* (GLP A) */
             Enddo                                                /* (GLZ A) */

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/
/*        Submit Export Customer Returns for Processing            */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*RETURN') THEN(DO)
               IF         COND(&CLIENT = &CASHWA) THEN(DO)
/*               Do not export returns at this time.                 (CWD A) */
                 return                                           /* (CWD A) */
               enddo                                              /* (CWD A) */
               CHGVAR     VAR(&EXPMSGQ) VALUE('EXPRTN')
               CHGVAR     VAR(&EXPERRMSGQ) VALUE('EXPRTNERR')

             IF         COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               SBMJOB     CMD(CALL PGM(OR736CL) PARM(&WHSEA &ORDTYPE)) +
                          JOB(OR736CL) JOBD(&JOBD) JOBQ(BFCEXPORT) /*(GLZ A) */
             Enddo                                                /* (GLZ A) */
             Else       Cmd(DO)                                   /* (GLZ A) */
               SBMJOB     CMD(CALL PGM(OR736CL) PARM(&WHSEA &ORDTYPE)) +
                            JOB(OR736CL) JOBD(&JOBD) JOBQ(QS36EVOKE)
             Enddo                                                /* (GLZ A) */

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/
/*        Submit Export Purchase Orders for Processing             */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*PO') THEN(DO)
               IF         COND(&CLIENT = &GREENLEAF) THEN(DO)     /* (GLPaA) */
                 return                                           /* (GLPaA) */
               ENDDO                                              /* (GLPaA) */
               CHGVAR     VAR(&EXPMSGQ) VALUE('EXPPO')
               CHGVAR     VAR(&EXPERRMSGQ) VALUE('EXPPOERR')

             IF         COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               SBMJOB     CMD(CALL PGM(PO726CL) PARM(&WHSEA)) +
                            JOB(PO726CL) JOBD(&JOBD) JOBQ(BFCEXPORT) +
                            OUTQ(*usrprf) PRTDEV(*usrprf)         /* (GLZ A) */
             Enddo                                                /* (GLZ A) */
             Else       Cmd(DO)                                   /* (GLZ A) */
               SBMJOB     CMD(CALL PGM(PO726CL) PARM(&WHSEA)) +
                            JOB(PO726CL) JOBD(&JOBD) JOBQ(QS36EVOKE) +
                            OUTQ(*usrprf) PRTDEV(*usrprf)         /* (520aA) */
             Enddo                                                /* (GLZ A) */

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/
/*        Submit Export Regular Customer Orders for processing.    */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*REGULAR') THEN(DO)
               CHGVAR     VAR(&EXPMSGQ) VALUE('EXPORD')
               CHGVAR     VAR(&EXPERRMSGQ) VALUE('EXPORDERR')

             IF         COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               SBMJOB     CMD(RH155CL PGM(&PGM) WHSE(&WHSE) +
                            RTID(&RTID) RTE(&RTE) RTN(&RTN) +
                            MSGKEY(&MSGKEY)) JOB(RH155CL) JOBD(&JOBD) +
                            JOBQ(BFCEXPORT)                       /* (GLZ A) */
             Enddo                                                /* (GLZ A) */
             Else       Cmd(DO)                                   /* (GLZ A) */
               SBMJOB     CMD(RH155CL PGM(&PGM) WHSE(&WHSE) +
                            RTID(&RTID) RTE(&RTE) RTN(&RTN) +
                            MSGKEY(&MSGKEY)) JOB(RH155CL) JOBD(&JOBD) +
                            JOBQ(QS36EVOKE)
             Enddo                                                /* (GLZ A) */

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
             ENDDO

/*-----------------------------------------------------------------*/
/*        Submit Export Will-Call Customer Orders for processing.  */
/*-----------------------------------------------------------------*/

             IF         COND(&PCMD = '*WILLCAL') THEN(DO)
               CHGVAR     VAR(&EXPMSGQ) VALUE('EXPORD')
               CHGVAR     VAR(&EXPERRMSGQ) VALUE('EXPORDERR')

             IF         COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               SBMJOB     CMD(RH255CL PGM(&PGM) WHSE(&WHSE) +
                            RTID(&RTID) RTE(&RTE) RTN(&RTN) +
                            MSGKEY(&MSGKEY)) JOB(RH255CL) JOBD(&JOBD) +
                            JOBQ(BFCEXPORT)                       /* (GLZ A) */
             Enddo                                                /* (GLZ A) */
             Else       Cmd(DO)                                   /* (GLZ A) */
               SBMJOB     CMD(RH255CL PGM(&PGM) WHSE(&WHSE) +
                            RTID(&RTID) RTE(&RTE) RTN(&RTN) +
                            MSGKEY(&MSGKEY)) JOB(RH255CL) JOBD(&JOBD) +
                            JOBQ(QS36EVOKE)
             Enddo                                                /* (GLZ A) */

               CHGVAR     VAR(&FINISHED) VALUE('1')
               CHGVAR     VAR(&RETURN)   VALUE('*OK')
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

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&EXPMSGQ) MSGTYPE(*COMP)

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&EXPERRMSGQ) +
                          MSGTYPE(*COMP)
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

               RCLRSC     LVL(*CALLER)

             ENDPGM
