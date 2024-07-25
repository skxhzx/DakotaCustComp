/*-------------------------------------------------------------------*/
/*                                                                   */
/*  WRTTRANDCL  Write PIRTRAND records                               */
/*  08 July 2010                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    07/08/10  DAS  5.30                                            */
/*      - Created.                                                   */
/*    01/02/12  DAS  6.40                                            */
/*      - Added parms fromdate, todate and emp#                     */
/*    05/31/12  LMC  6.40A                                           */
/*      - Added parms tran                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 WRTTRANDCL: PGM        PARM(&CMD &WAIT &WHSE &TRAN &FROMDATE +
                          &TODATE &EMP#)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating transaction detail records')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&WAIT)       TYPE(*DEC)  LEN(2)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE) TYPE(*DEC) LEN(3)
             DCL        VAR(&TRAN)       TYPE(*DEC) LEN(7)
             DCL        VAR(&FROMDATE)   TYPE(*DEC) LEN(8)
             DCL        VAR(&TODATE)     TYPE(*DEC) LEN(8)
             DCL        VAR(&EMP#)       TYPE(*DEC) LEN(5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(WRTTRAND) PARM(&CMD &WAIT &WHSE +
                          &TRAN &FROMDATE &TODATE &EMP#)

 /* Receive any messages and pass them on */

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

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
