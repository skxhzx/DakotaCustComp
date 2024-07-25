/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV760CL   Clear Slot files for SI255 Host Count                  */
/*  26 January, 2006                                                 */
/*  Roxanne Harrison                                                 */
/*    01/26/06  RH   5.00                                            */
/*    - Created using IV500CL                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV760CL:    PGM        PARM(&CMD &WHSE &BATCH &STAT &JOBQ)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1) VALUE('N')
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO POSTIT)

/*  Get user parameters. */

             CALL       PGM(IV760) PARM(&WHSE &WHDP &BATCH &STAT +
                          &JOBQ &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA('Clear Slot Files Host Count') +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* See if user wants to put it on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(IV760CL) PARM(&RETURN &WHSE +
                          &BATCH &STAT &JOBQ)) JOB(IV760)
             GOTO       CMDLBL(GETOUT)
             ENDDO

             CHGVAR     VAR(&CMD) VALUE(&RETURN)
             CHGVAR     VAR(&RETURN) VALUE(' ')

/*  Otherwise, run program. */

 POSTIT:

   /* Share files. */

      /*     OVRDBF     FILE(ORDH) SHARE(*YES)   */
      /*     OVRDBF     FILE(ORDD) SHARE(*YES)   */

   /* Call picking traffic cop. */

             CALL       PGM(IV765) PARM(&CMD &WHSE &WHDP &BATCH +
                          &STAT &JOBQ &RETURN)
 /*                       &JOBQ &RETURN)                  */

             IF (&RETURN = '*ERROR') THEN(DO)
               SNDPGMMSG  MSGID(PIR9802) MSGF(PIRMSGF) +
                          MSGDTA('Clear Slot File Host Count') +
                          MSGTYPE(*INFO)
             ENDDO

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

   /* Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
