/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOG750CL  Remove old DRI log records - Called directly           */
/*  22 February 2002                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/22/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    03/29/02  DAS  4.16a                                           */
/*      - Added &HOURS.                                              */
/*                                                                   */
/*    03/15/10  MLB  5.30                                            */
/*      - Enh: Addec call to LOG765 to remove rcds from LOGLT210.    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOG750CL:   PGM        PARM(&DAYS &HOURS)   /*416aM*/

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOG750CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LOG750)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LOG755)
             DCL        VAR(&MAINPGM2) TYPE(*CHAR) LEN(8) +
                          VALUE(LOG765)                           /* (530 A) */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Remove old Dakota Realtime +
                          Interface log records')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Removing old Dakota Realtime +
                          Interface log records')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DAYS)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&PDAYS)      TYPE(*DEC)  LEN(3 0)     /* (530 A) */
             DCL        VAR(&HOURS)      TYPE(*DEC)  LEN(15 5) /*416aA*/
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)

/* Don't get options if being run in batch mode. */

             IF (&TYPE = '0') THEN(GOTO MAIN)

/*  Otherwise, run program. */

 MAIN:

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&DAYS &HOURS)  /*416aM*/
             CHGVAR     VAR(&PDAYS) VALUE(&DAYS)                  /* (530 A) */
             CALL       PGM(&MAINPGM2) PARM(&PDAYS)               /* (530 A) */

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
