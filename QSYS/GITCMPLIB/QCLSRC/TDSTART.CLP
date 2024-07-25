/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TDSTART     Start WRTTRAND                                       */
/*  16 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    02/16/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*    05/18/12  MLB  6.40a                                           */
/*      - Enh: Added client custom code support.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Glazier Foods                           */
/*                                                                   */
/*    05/18/12  MLB  GLZ                                             */
/*      - Revised program to submit TDSTART to jobq BFCEXPORT which  */
/*        runs under DAKOTA subsystem. Per Gary S. phone call        */
/*        on 05/18/12.                                               */
/*                                                                   */
/*-------------------------------------------------------------------*/
 TDSTART:    PGM        PARM(&ID)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (640aA) */

             DCL        VAR(&GLAZIER) TYPE(*CHAR) LEN(10) +
                          VALUE('GLAZIER')                        /* (GLZ A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640aA) */
             DCL        VAR(&ID)         TYPE(*CHAR) LEN(3)
             DCL        VAR(&JOBNAME)    TYPE(*CHAR) LEN(10)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLG)     TYPE(*LGL)  VALUE('0')
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (640aA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640aA) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

    /* Submit WRTTRAND program */

             CHGVAR     VAR(&JOBNAME) VALUE('BFCWTD' *CAT &ID)

             SELECT                                               /* (GLZ A) */
             WHEN       COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GLZ A) */
               SBMJOB     CMD(WRTTRAND CMD(*NONSTOP) WAIT(5)) +
                            JOB(&JOBNAME) JOBQ(BFCEXPORT)         /* (GLZ A) */
             Enddo                                                /* (GLZ A) */
             OTHERWISE  CMD(DO)                                   /* (GLZ A) */
             SBMJOB     CMD(WRTTRAND CMD(*NONSTOP) WAIT(5)) +
                          JOB(&JOBNAME) JOBQ(QS36EVOKE)
             Enddo                                                /* (GLZ A) */
             Endselect                                            /* (GLZ A) */

/*  Receive any messages and pass them on  */

 GETOUT:
             IF         COND(&MSGFLG) THEN(GOTO CMDLBL(ENDPGM))
             CHGVAR     VAR(&MSGFLG) VALUE('1')
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

 ENDPGM:     ENDPGM
