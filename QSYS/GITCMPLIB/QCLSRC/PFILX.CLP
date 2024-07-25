/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PFIL      Truck build picking labels - Export file method        */
/*  29 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/29/00  DAS  4.14                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PFIL:       PGM        PARM(&PCMD &PWHSE &PRTID &PCOMP &PTZON &PGEN +
                          &PSZON &PTRUK &PRTE &OPZDTA &PTRN#)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PCOMP)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PTZON)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PGEN)       TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&PSZON)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PTRUK)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&OPZDTA)     TYPE(*CHAR) LEN(117)
             DCL        VAR(&PTRN#)      TYPE(*DEC)  LEN(7 0)


             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Call label program. */

             CALL       PGM(PFILPGM) PARM(&PCMD &PWHSE &PRTID &PCOMP +
                          &PTZON &PGEN &PSZON &PTRUK &PRTE &OPZDTA +
                          &PTRN#)


/*  Receive any messages and pass them on  */

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

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
