/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CCJETCL   Submit JIT replenishments to job queue                 */
/*  02 November 2004                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    11/02/04  DAS  5.00                                            */
/*      - Created.                                                   */
/*    01/16/05  RLP  5.00a                                           */
/*      - Changed to submit job into new jobq BFCCCJIT               */
/*    02/11/05  DAS  5.00b                                           */
/*      - Changed to not log non-error messages.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CCJITCL:    PGM        PARM(&WHSE &TRAN#)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

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

       /*    SBMJOB     CMD(CALL PGM(CCJIT) PARM(&WHSE &TRAN#)) +    */
       /*                 JOB(CCJIT) JOBQ(*LIBL/BFCCCJIT) LOG(*JOBD +*/
       /*                 *JOBD *JOBD) INQMSGRPY(*DFT) MSGQ(*NONE)   */

             SBMJOB     CMD(CALL PGM(CCJIT) PARM(&WHSE &TRAN#)) +
                          JOB(CCJIT) JOBQ(*LIBL/BFCCCJIT) LOG(*JOBD +
                          *JOBD *NOLIST) INQMSGRPY(*DFT) MSGQ(*NONE)
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
