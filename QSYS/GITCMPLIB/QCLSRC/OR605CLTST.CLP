/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR605CL   Truck Build - Traffic Cop                              */
/*  24 July 2002                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    07/24/02  MLB  4.16                                            */
/*      - Created.                                                   */
/*        This program allows the Truck Build portions of            */
/*        allocate/build, pick/print to be processed in batch.       */
/*                                                                   */
/*    02/25/04  MLB  CBI                                             */
/*      - Changed to submit to BFCJOBQ instead of QBATCH. BFCJOBQ    */
/*        is a "single-thread' jobq.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR605CL:    PGM        PARM(&PCMD &PCMD2 &PTYPE &PJTYP &PWHS &PBAT +
                          &PSTAT &PRTID &PORD &PRWHS &PTRTE &PRTN +
                          &PMSG &PPRG)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PCMD2)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PJTYP)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PWHS)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&PBAT)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&PSTAT)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PORD)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&PRWHS)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&PTRTE)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PMSG)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&PPRG)       TYPE(*CHAR) LEN(10)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE(' ')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE(' ')

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*           SBMJOB     CMD(OR605 PCMD(&PCMD) PCMD2(&PCMD2) +
                          PTYPE(&PTYPE) PJTYP(&PJTYP) PWHS(&PWHS) +
                          PBAT(&PBAT) PSTAT(&PSTAT) PRTID(&PRTID) +
                          PORD(&PORD) PRWHS(&PRWHS) PTRTE(&PTRTE) +
                          PRTN(&PRTN) PMSG(&PMSG) PPRG(&PPRG)) +
                          JOB(OR605CL) JOBQ(BFCJOBQ)      */
/*           GOTO       CMDLBL(GETOUT)     */

/*  Otherwise, run program. */

 REPORT:

             CALL       PGM(OR605) PARM(&PCMD &PCMD2 &PTYPE &PJTYP +
                          &PWHS &PBAT &PSTAT &PRTID &PORD &PRWHS +
                          &PTRTE &PRTN &PMSG &PPRG)
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

             RCLRSC     LVL(*CALLER)

             ENDPGM
