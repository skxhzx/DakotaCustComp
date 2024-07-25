/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PRECLNUPCL   Cleanup PRE Slots Until Fully Live on TruckBuilder. */
/*  06 July 2011                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    07/06/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*    mm/dd/yy  iii  ccc                                             */
/*      -                                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/

PRECLNUPCL:  PGM        PARM(&CMD &WHSE &AISL &ROUTE &RTID)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&AISL)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&ROUTE)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERROR))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF         COND(&CLIENT *EQ ' ') THEN(DO)
               CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)
             ENDDO

/*  Call PRE Cleanup program.                                        */
             CALL       PGM(PRECLNUP) PARM(&CMD &WHSE &AISL &ROUTE &RTID)

/*  Cleanup finished without error. Skip to sending back messages  */

 FINISHED:
             CHGVAR     VAR(&RETURN) VALUE('*OK')
             GOTO       CMDLBL(GETOUT)

/*  Unexpected errors come here  */

 ERROR:
             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             DSPJOBLOG  JOB(*) OUTPUT(*PRINT)

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOUSR(&MSGQ) MSGTYPE(*COMP)

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
