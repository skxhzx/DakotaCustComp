/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTTDDTAQ    Create WRTTRAND data queue                          */
/*  16 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/16/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/30/12  DAS  6.40a                                           */
/*      - Added WRTTRAND2 and WRTTRAND3 data queues                  */
/*    10/02/13  LMC  6.50a                                           */
/*      - Changed the size on WRTTRAND2 - dataq had maxed            */
/*      out at client during cleanup.                                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTTDDTAQ:  PGM        PARM(&LIB)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)

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

/*  Create WRTTRAND Data Queue  */
/*  Used to start WRTTRAND in batch mode */

             CRTDTAQ    DTAQ(&LIB/WRTTRAND) MAXLEN(50) +
                          SENDERID(*YES) TEXT('WRTTRAND Data Queue')

             MONMSG     MSGID(CPF9870)

/*  Create WRTTRAND2 Data Queue  */
/*  Used to communicate to WRTTRAND2 in real-time mode */

/*           CRTDTAQ    DTAQ(&LIB/WRTTRAND2) MAXLEN(500) +
                          TEXT('WRTTRAND2 Data Queue')  650aD */

             CRTDTAQ    DTAQ(&LIB/WRTTRAND2) MAXLEN(500) +
                          SIZE(*MAX2GB 100) AUTORCL(*YES) +
                          TEXT('WRTTRAND2 Data Queue') /* 650aM */

             MONMSG     MSGID(CPF9870)

/*  Create WRTTRAND3 Data Queue  */
/*  Used to force shutdown of WRTTRAND2 */

             CRTDTAQ    DTAQ(&LIB/WRTTRAND3) MAXLEN(10) +
                          TEXT('WRTTRAND3 Data Queue')

             MONMSG     MSGID(CPF9870)

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
