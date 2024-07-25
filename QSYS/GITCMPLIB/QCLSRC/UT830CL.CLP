/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT310CL   Recalculate stock quantity in slots                    */
/*            using pick, transfer, and receive quantities.          */
/*            CAN ONLY BE USED WHEN ALL TRANSACTIONS ARE CLOSED.     */
/*  21 August 1998                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT830CL:    PGM        PARM(&WHSE &ITEM &JOBQ)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UT830CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UT830)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Recalculate Stock Quantity in Slots')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNMSG)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO RECALC)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &ITEM &JOBQ &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &ITEM +
                          &JOBQ)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 RECALC:

             CALL       PGM(UT832) PARM(&WHSE &ITEM &TYPE &SBMPGM +
                          &RETURN &RTNMSG)


 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
