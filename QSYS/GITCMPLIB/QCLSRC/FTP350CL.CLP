/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP350CL   Display slot CSV file                                 */
/*  09 December 2004                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    12/09/04  DAS  5.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP350CL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Display slot CSV file')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(30)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(FTP350) PARM(&WHSE &RTN)

/*  See if user wants to proceed. */

             IF         COND((&RTN *EQ '*CANCEL') *OR (&RTN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/* Display file  */

             CHGVAR     VAR(&FILE) VALUE('/bfctfr/slot' *CAT &WHSE +
                          *CAT '.csv')
             DSPF       STMF(&FILE)

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

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

             RCLRSC     LVL(*CALLER)
             ENDPGM
