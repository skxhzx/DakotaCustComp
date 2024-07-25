/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SAPDSPDTAQ    Display SQP Qty In/Out data queues                    */
/*  20 January 2020                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/30/20  DAS  7.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SAPDSPDTAQ: PGM        PARM(&TYPE &TYPE2 &LIB)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&DQIN)   TYPE(*CHAR) LEN(10) VALUE('SAPQTYIN')
             DCL        VAR(&DQOUT)  TYPE(*CHAR) LEN(10) VALUE('SAPQTYOUT')
             DCL        VAR(&DQNAME)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(5)
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

/* Determine which data queue to use */

             IF (&TYPE *EQ '*IN') +
               THEN(CHGVAR VAR(&DQNAME) VALUE(&DQIN))
               ELSE CMD(CHGVAR VAR(&DQNAME) VALUE(&DQOUT))

/* Display either the Entries or the Description */

  /* Entries */

             IF         COND(&TYPE2 *EQ '*ENTRIES') THEN(DO)
             DSPDQE     DTAQ(&LIB/&DQNAME)
             ENDDO

  /* Description */

             IF         COND(&TYPE2 *EQ '*DESC') THEN(DO)
             DSPDQD     DTAQ(&LIB/&DQNAME)
             ENDDO

     /*      GOTO       CMDLBL(NOMSG)     */

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
