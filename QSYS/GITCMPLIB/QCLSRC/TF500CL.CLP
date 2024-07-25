/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TF500CL   Pick transfer orders.                                  */
/*  13 March 1996                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/21/96  DAS  2.13                                            */
/*      - Added parameter &BTYP to OR500CL, OR500 and OR505.         */
/*      - Added parameter &TYPE to OR505.                            */
/*      - Added two dummy parameters used for transfers to OR505.    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Notes:                                                           */
/*                                                                   */
/*    - This is similar to OR500CL.                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TF500CL:    PGM        PARM(&CMD &WHSE &BATCH &STAT &ROUTE &ORDER +
                          &RWHSE &TRTE &BTYPE)

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
             DCL        VAR(&RWHSE)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TRTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO PICKIT)

/*  Get user parameters. */

             CALL       PGM(TF500) PARM(&WHSE &BTYPE &BATCH &STAT &JOBQ  +
                          &ROUTE &ORDER &RWHSE &TRTE &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA('Pick Transfer Orders') +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* See if user wants to put it on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(TF500CL) PARM(&RETURN &WHSE +
                          &BATCH &STAT &ROUTE &ORDER &RWHSE &TRTE +
                          &BTYPE)) JOB(TF500)
             GOTO       CMDLBL(GETOUT)
             ENDDO

             CHGVAR     VAR(&CMD) VALUE(&RETURN)
             CHGVAR     VAR(&RETURN) VALUE(' ')

/*  Otherwise, run program. */

 PICKIT:

   /* Override ORD files to TPCK. */

             OVRDBF     FILE(ORDH)  SHARE(*YES)
             OVRDBF     FILE(ORDD)  SHARE(*YES)

   /* Call picking traffic cop. */

             CALL       PGM(OR505) PARM(&CMD &BTYPE &TYPE &WHSE +
                          &BATCH &STAT &ROUTE &ORDER &RWHSE &TRTE +
                          &RETURN)

             IF (&RETURN = '*ERROR') THEN(DO)
               SNDPGMMSG  MSGID(PIR9802) MSGF(PIRMSGF) +
                          MSGDTA('Pick Transfer Orders') +
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
