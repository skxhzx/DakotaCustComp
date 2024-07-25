/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTPIRMSG   Create all PIR messages                              */
/*  24 September 2000                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTPIRMSG:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&MEMBER)    TYPE(*CHAR) LEN(10)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 /* Get first QMSGDSRC member */

             RTVMBRD    FILE(PIR/QMSGDSRC) MBR(*FIRSTMBR) +
                          RTNMBR(&MEMBER)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(OUT))

LOOP:

    /* Call the member to create the messages */

             CALL       PGM(&MEMBER) PARM(*ALL)
             MONMSG     MSGID(CPF0000)

    /* Get next member */

             RTVMBRD    FILE(PIR/QMSGDSRC) MBR(&MEMBER *NEXT) +
                          RTNMBR(&MEMBER)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(OUT))

             GOTO       CMDLBL(LOOP)

OUT:

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
 NOMSG:
 BOTTOM:
