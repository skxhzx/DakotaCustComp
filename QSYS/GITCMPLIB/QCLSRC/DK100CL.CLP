/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DK100CL   Start new dock door matrix                             */
/*  06 November 2001                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    11/06/01  DAS  4.16                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DK100CL:    PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Variables                                                        */
/*-------------------------------------------------------------------*/

             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

/*-------------------------------------------------------------------*/
/*  Message handling fields                                          */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Create new dock door matrix */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating new dock door matrix') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CALL       PGM(DK101) PARM(&WHSE)

/*  Remove old dock door history */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Remove old dock door history') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CALL       PGM(DK109) PARM(&WHSE)

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
 OUT:
 NOMSG:

             ENDPGM
