/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TD911CL   Initialize totals in TASKDET file - from command       */
/*  28 February 1996                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*-------------------------------------------------------------------*/

 TD911CL:    PGM        PARM(&PCAT &PSUB &PTASK &PWHSE &PWHDP &PSTYP +
                          &PETIM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Informational messages */

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Initializing Totals')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCAT)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&PSUB)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&PTASK)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(4)
             DCL        VAR(&PWHDP)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PSTYP)      TYPE(*CHAR) LEN(4)
             DCL        VAR(&PETIM)      TYPE(*DEC)  LEN(4 0)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Verify options. */

             CALL       PGM(TD911) PARM(&PCAT &PSUB &PTASK &PWHSE +
                          &PWHDP &PSTYP &PETIM &RETURN)


/*  See errors were found with parameters passed from command. */

             IF (&RETURN *EQ '*ERROR') THEN(DO)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(INZTSK) PARM(&PCAT &PSUB &PTASK &PWHSE +
                          &PWHDP &PSTYP &PETIM)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
