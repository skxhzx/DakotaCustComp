/*-------------------------------------------------------------------*/
/*                                                                   */
/*  APPDQCLR  Clear Android App In/Out data queue                    */
/*  03 February 2022                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/03/22  DAS  7.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 APPDQCLR:   PGM        PARM(&TYPE &MIN &CONFIRM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&CONFIRM)    TYPE(*CHAR) LEN(4)
             DCL        VAR(&DELETED)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&DQNAME)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&NAMELIB)    TYPE(*CHAR) LEN(20)
             DCL        VAR(&MIN)        TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&MINA)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(3)

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

             CHGVAR     VAR(&LIB) VALUE('*LIBL')
             CHGVAR     VAR(&MINA) VALUE(&MIN)

/* Get out if confirm value is not *YES */

             IF COND(&CONFIRM *NE '*YES') THEN(GOTO GETOUT)

/* Determine which data queue to use */

             IF COND(&TYPE *EQ 'IN') +
               THEN(CHGVAR VAR(&DQNAME) VALUE(APPDQIN))
               ELSE CMD(CHGVAR VAR(&DQNAME) VALUE(APPDQOUT))

/* Call program to delete entries */

             CHGVAR VAR(&NAMELIB) VALUE(&DQNAME || &LIB)
             CALL PGM(DQDLTOLD) PARM(&NAMELIB &MINA &DELETED)

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
