/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DJ101CL   DSPJRN extraction program                              */
/*  01 May 2001                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   05/01/01  DAS  4.15                                             */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DJ101CL:    PGM        PARM(&FILEOVR)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILEOVR)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             RMVMSG     CLEAR(*ALL)

             IF         COND(&FILEOVR *EQ ' ') THEN(DO)
               OVRDBF     FILE(JRNOUTF) TOFILE(&FILEOVR)
             ENDDO

             CALL       PGM(DJ101)

             IF         COND(&FILEOVR *EQ ' ') THEN(DO)
               DLTOVR     FILE(JRNOUTF)
             ENDDO

             GOTO NOMSG

 /* Receive any messages and pass them on */

 GETOUT:
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

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
