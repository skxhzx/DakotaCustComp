/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR500CL   Pick orders                                            */
/*  17 March 1993                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/21/96  DAS  2.13                                            */
/*      - Added parameter &BTYP to OR500CL, OR500 and OR505.         */
/*      - Added parameter &TYPE to OR505.                            */
/*      - Added two dummy parameters used for transfers to OR505.    */
/*    08/15/96  HNK  2.16                                            */
/*      - Escape message sent back when the program ends abnormally  */
/*        on jobq.                                                   */
/*    10/16/96  RH   2.17                                            */
/*      - Size of warehouse number parameter (&WHSE) changed to      */
/*        15 long with 5 decimal.  Size is changed to 3 long with    */
/*        zero decimal in RPG programs called from here.             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR500CL:    PGM        PARM(&CMD &WHSE &BATCH &STAT &ROUTE &ORDER +
                          &BTYPE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&BTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1) VALUE('N')
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&ORDER)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&ROUTE)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO PICKIT)

/*  Get user parameters. */

             CALL       PGM(OR500) PARM(&WHSE &BTYPE &BATCH &STAT  +
                          &JOBQ &ROUTE &ORDER &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA('Pick Customer Orders') +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* See if user wants to put it on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(OR500CL) PARM(&RETURN &WHSE +
                          &BATCH &STAT &ROUTE &ORDER &BTYPE)) +
                          JOB(OR500)
             GOTO       CMDLBL(GETOUT)
             ENDDO

             CHGVAR     VAR(&CMD) VALUE(&RETURN)
             CHGVAR     VAR(&RETURN) VALUE(' ')

/*  Otherwise, run program. */

 PICKIT:

   /* Share files. */

             OVRDBF     FILE(ORDH) SHARE(*YES)
             OVRDBF     FILE(ORDD) SHARE(*YES)

   /* Call picking traffic cop. */

             CALL       PGM(OR505) PARM(&CMD &BTYPE &TYPE &WHSE +
                          &BATCH &STAT &ROUTE &ORDER ' ' ' ' &RETURN)

             IF (&RETURN = '*ERROR') THEN(DO)
             IF (&TYPE = '1') THEN(DO)
               SNDPGMMSG  MSGID(PIR9802) MSGF(PIRMSGF) +
                          MSGDTA('Pick Customer Orders') +
                          MSGTYPE(*INFO)
             ENDDO
             IF (&TYPE = '0') THEN(DO)
             SNDPGMMSG  MSGID(PIR9802) MSGF(PIRMSGF) MSGDTA('Pick +
                          Customer Orders') MSGTYPE(*ESCAPE)
             ENDDO
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
