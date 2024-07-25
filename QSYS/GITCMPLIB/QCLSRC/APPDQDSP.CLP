/*-------------------------------------------------------------------*/
/*                                                                   */
/*  APPDQDSP  Display Android App In/Out data queue                  */
/*  01 February 2022                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/01/22  DAS  7.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 APPDQDSP:   PGM        PARM(&TYPE &TYPE2)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&DQNAME)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&TYPE2)      TYPE(*CHAR) LEN(8)

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

/* Determine which data queue to use */

             IF         COND(&TYPE *EQ 'IN') THEN(CHGVAR +
                          VAR(&DQNAME) VALUE(APPDQIN))
               ELSE CMD(CHGVAR VAR(&DQNAME) VALUE(APPDQOUT))

/* Display either the Entries or the Description */

  /* Entries */

             IF         COND(&TYPE2 *EQ '*ENTRIES') THEN(DO)
             DSPDQE     DTAQ(&LIB/&DQNAME)
             ENDDO

  /* Description */

             IF         COND(&TYPE2 *EQ '*DESC') THEN(DO)
             DSPDQD     DTAQ(&LIB/&DQNAME)
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
