/*-------------------------------------------------------------------*/
/*                                                                   */
/*  MOVMSGP   Move messages to previous program queue.               */
/*  28 February 1996                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*  06/22/05  MLB  5.00                                              */
/*    - Fix: Added MONMSG to SNDPGMMSG command.                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 MOVMSGP:    PGM        PARM(&PGMMSGQ)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGMMSGQ)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME (&PGMMSGQ)) MSGQ(*PGMQ) +
                          MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOPGMQ(*PRV (&PGMMSGQ)) +
                          MSGTYPE(*COMP)
             MONMSG     MSGID(CPF247A) /* Ignore call stack entry +
                          not found.                                (500 A) */
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

             ENDPGM
