/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT180CL   Display LF's with different lib than PF                */
/*  11 September 1997                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    09/11/97  DAS  4.05                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT180CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Display Wayward Logical Files')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(UT180) PARM(&RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Create database relations file */

             MSGBFC     MESSAGE('Creating database relation file +
                          QTEMP/UT180DBR for *USRLIBL')

             DSPDBR     FILE(*USRLIBL/*ALL) OUTPUT(*OUTFILE) +
                          OUTFILE(QTEMP/UT180DBR)

/*  Run query */

             MSGBFC     MESSAGE('Running query on file QTEMP/UT180DBR')

             RUNQRY     QRY(UT180) QRYFILE((QTEMP/UT180DBR)) +
                          OUTTYPE(*DISPLAY) OUTFORM(*DETAIL)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
