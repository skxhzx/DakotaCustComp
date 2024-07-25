/*-------------------------------------------------------------------*/
/*                                                                   */
/*  APPDQCRT  Create Android App In/Out data queues                  */
/*  01 February 2022                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/01/22  DAS  7.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 APPDQCRT:   PGM        PARM(&LIB)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(4)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLG)     TYPE(*LGL)  VALUE('0')
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Create Inbound Data Queue  */

             CRTDTAQ    DTAQ(&LIB/APPDQIN) MAXLEN(64512) SEQ(*KEYED) +
                          KEYLEN(32) SENDERID(*YES) SIZE(*MAX2GB) +
                          AUTORCL(*YES) TEXT('Android App Data +
                          Queue - Inbound')

                MONMSG     MSGID(CPF9870)

/*  Create Outbound Data Queue  */

             CRTDTAQ    DTAQ(&LIB/APPDQOUT) MAXLEN(64512) +
                          SEQ(*KEYED) KEYLEN(32) SENDERID(*YES) +
                          SIZE(*MAX2GB) AUTORCL(*YES) TEXT('Android +
                          App Data Queue - Outbound')

                MONMSG     MSGID(CPF9870)

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
