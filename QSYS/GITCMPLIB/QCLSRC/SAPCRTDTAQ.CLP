/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SAPCRTDTAQ    Create SQP Qty In/Out data queues                     */
/*  30 January 2020                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/30/20  DAS  7.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SAPCRTDTAQ: PGM        PARM(&TYPE &LIB)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&DQIN)   TYPE(*CHAR) LEN(10) VALUE('SAPQTYIN')
             DCL        VAR(&DQOUT)  TYPE(*CHAR) LEN(10) VALUE('SAPQTYOUT')
             DCL        VAR(&LIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)   TYPE(*CHAR) LEN(5)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLG)   TYPE(*LGL)  VALUE('0')
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Create Inbound Data Queue  */

             IF         COND(&TYPE *EQ '*IN' *OR &TYPE *EQ '*BOTH') +
                          THEN(DO)

             CRTDTAQ    DTAQ(&LIB/&DQIN) MAXLEN(100) SENDERID(*YES) +
                          AUTORCL(*YES) TEXT('SAP Qty Data Queue - In')

                MONMSG     MSGID(CPF9870)

             ENDDO

/*  Create Outbound Data Queue  */

             IF         COND(&TYPE *EQ '*OUT' *OR &TYPE *EQ '*BOTH') +
                          THEN(DO)

             CRTDTAQ    DTAQ(&LIB/&DQOUT) MAXLEN(500) SEQ(*KEYED) +
                          KEYLEN(40) SENDERID(*YES) AUTORCL(*YES) +
                          TEXT('SAP Qty Data Queue - Out')

            /*  CRTDTAQ    DTAQ(&LIB/&DQOUT) MAXLEN(500) SENDERID(*YES) +
                             TEXT('SAP Qty Data Queue - Out')   */

             MONMSG     MSGID(CPF9870)

             ENDDO

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
