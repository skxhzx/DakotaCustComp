/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DRILOGCLN  Remove old DRI log records - Using DRILOGCLN cmd      */
/*  27 February 2002                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/27/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    03/29/02  DAS  4.16a                                           */
/*      - Added &HOURS.                                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes                                                            */
/*                                                                   */
/*   This program was created to be called from the DRILOGCLN        */
/*   command. Program LOG750CL could not be called directly because  */
/*   a command can not send a 15.5 number.                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DRILOGCLN:  PGM        PARM(&DAYS &HOURS)   /*416aM*/

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DAYS)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&DAYS15)     TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&HOURS)      TYPE(*DEC)  LEN(3 0)  /*416aA*/
             DCL        VAR(&HOURS15)    TYPE(*DEC)  LEN(15 5) /*416aA*/
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

             CHGVAR     VAR(&DAYS15) VALUE(&DAYS)
             CHGVAR     VAR(&HOURS15) VALUE(&HOURS)          /*416aA*/
             CALL       PGM(LOG750CL) PARM(&DAYS15 &HOURS15) /*416aM*/

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
