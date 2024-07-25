/******************************************************************************/
/*                                                                            */
/*  PUTMSG    Send a message to our program queue                             */
/*  06 MAY 1991                                                               */
/*  J. David Romaine                                                          */
/*                                                                            */
/*  If message id = 0000, then clear program message queue,                   */
/*  else send the specified message.                                          */
/*                                                                            */
/******************************************************************************/

             PGM        PARM(&MSGF &MSGID &MSGTYPE &MSGDATA &PGMMSGQ +
                          &MSGKEY)

             DCL        VAR(&MSGF)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGTYPE)   TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGDATA)   TYPE(*CHAR) LEN(128)
             DCL        VAR(&PGMMSGQ)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGKEY)    TYPE(*CHAR) LEN(4)

             IF         COND(&MSGID *EQ '*CLEAR') THEN(RMVMSG +
                          PGMQ(*SAME &PGMMSGQ) CLEAR(*ALL))

             ELSE       CMD(SNDPGMMSG MSGID(&MSGID) MSGF(&MSGF) +
                          MSGDTA(&MSGDATA) TOPGMQ(*SAME &PGMMSGQ) +
                          MSGTYPE(&MSGTYPE) KEYVAR(&MSGKEY))

             RETURN

             ENDPGM
