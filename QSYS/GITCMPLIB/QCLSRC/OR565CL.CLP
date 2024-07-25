/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR565CL   Reprint pallet summary.                                */
/*  14 October 1994                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/05/96  DAS  2.13                                            */
/*      - Added new constants &PGMTYPE to identify                   */
/*        normal, transfer or POS.                                   */
/*      - Added &PGMTYPE to options program.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR565CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Program type. */

             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(8) +
                          VALUE('*NORMAL ')

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Reprint pallet report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get parameters. */

             CALL       PGM(OR565) PARM(&PGMTYPE &RTYPE &WHSE &BATCH &RTE +
                          &WHDP &JOBQ &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* Otherwise run the report. */

             CHGVAR     VAR(&CMD)    VALUE('*REPRINT')

   /* From jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(OR560CL) PARM(&CMD &RTYPE &WHSE +
                          &BATCH &RTE &WHDP &RETURN)) JOB(OR560CL)
             GOTO       CMDLBL(OUT)
             ENDDO

   /* or workstation. */

             CALL       PGM(OR560CL) PARM(&CMD &RTYPE &WHSE &BATCH +
                          &RTE &WHDP &RETURN)

OUT:
             RCLRSC     LVL(*CALLER)

             ENDPGM
