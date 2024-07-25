/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PUTMSGPA  Write all program messages of calling program to a     */
/*            specific programs message queue.                       */
/*  09 April 2003                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  04/09/03  DAS                                                    */
/*    - Created.                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &PGM      Program to send messages to.                   */
/*                                                                 */
/*-----------------------------------------------------------------*/

 PUTMSGPA:    PGM       PARM(&PGM)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&PGM)      TYPE(*CHAR) LEN(10)

   /* Standard message handling variables */

             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLG)     TYPE(*LGL)  VALUE('0')
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Receive any messages and pass them on  */

 GETOUT:
             IF         COND(&MSGFLG) THEN(GOTO CMDLBL(ENDPGM))
             CHGVAR     VAR(&MSGFLG) VALUE('1')
 NEXTMSG:    DO
             RCVMSG     PGMQ(*PRV) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) MSGF(&MSGF) +
                          MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOPGMQ(*SAME (&PGM)) +
                          MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 ENDPGM:     ENDPGM
