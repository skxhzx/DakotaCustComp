/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DSPTDDTAQ    Display WRTTRAND data queue                         */
/*  12 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/16/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/30/12  DAS  6.40a                                           */
/*      - Added data queue parameter                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DSPVODTAQ:  PGM        PARM(&DTAQ &TYPE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&DQNAME)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&DTAQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(8)

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

             IF COND(&DTAQ = '1') THEN(DO)
               CHGVAR     VAR(&DQNAME) VALUE('WRTTRAND')
             ENDDO

             IF COND(&DTAQ = '2') THEN(DO)
               CHGVAR     VAR(&DQNAME) VALUE('WRTTRAND2')
             ENDDO

             IF COND(&DTAQ = '3') THEN(DO)
               CHGVAR     VAR(&DQNAME) VALUE('WRTTRAND3')
             ENDDO

/* Display either the Entries or the Description */

  /* Entries */

             IF         COND(&TYPE *EQ '*ENTRIES') THEN(DO)
             DSPDQE     DTAQ(&DQNAME)
             ENDDO

  /* Description */

             IF         COND(&TYPE *EQ '*DESC') THEN(DO)
             DSPDQD     DTAQ(&DQNAME)
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
