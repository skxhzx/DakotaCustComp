/*-------------------------------------------------------------------*/
/*                                                                   */
/*  HT100CL   Populate daily hits files                              */
/*  19 July 2004                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/19/04  DAS  4.18                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 HT100CL:    PGM        PARM(&STARTDTE &FROMTIME &TOTIME)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&STARTDTE)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&FROMTIME)   TYPE(*CHAR) LEN(6)
             DCL        VAR(&TOTIME)     TYPE(*CHAR) LEN(6)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)

/*  Populate Selection Hits file  */

             CALL       PGM(HT100) PARM(&STARTDTE &FROMTIME &TOTIME)

/*  Populate non-zero replenishment hits  */

             CALL       PGM(HT100RPL) PARM(&STARTDTE &FROMTIME &TOTIME)

/*  Populate zero replenishment hits  */

             CALL       PGM(HT100ZRO) PARM(&STARTDTE &FROMTIME &TOTIME)

             GOTO NOMSG

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
