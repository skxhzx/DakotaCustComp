/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CCJITPCL   Submit Truck Builder JIT Priority Replenishments      */
/*             to Jobq.                                              */
/*                                                                   */
/*  07 October 2005                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    10/07/05  MLB  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CCJITPCL:    PGM        PARM(&PARMS)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PARMS)      TYPE(*CHAR) LEN(136)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRAN#)      TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             SBMJOB     CMD(CALL PGM(CCJITP) PARM(&PARMS)) +
                          JOB(CCJITP) JOBQ(*LIBL/BFCCCJIT) +
                          INQMSGRPY(*DFT) MSGQ(*NONE)

             GOTO       CMDLBL(NOMSG)

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

             ENDPGM
