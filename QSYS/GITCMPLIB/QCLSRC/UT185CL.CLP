/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT185CL   Display LF's with different lib than PF using DSPF     */
/*  01 February 2000                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/01/00  DAS  4.13                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT185CL:    PGM

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

             CALL       PGM(UT185) PARM(&RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Create database relations file */

             MSGBFC     MESSAGE('Creating file of LF''s in +
                          QTEMP/UT185FD for *USRLIBL')

             DSPFD      FILE(*USRLIBL/*ALL) TYPE(*MBR) +
                          OUTPUT(*OUTFILE) FILEATR(*LF) +
                          OUTFILE(QTEMP/UT185FD)

/*  Run query */

             MSGBFC     MESSAGE('Running query on file QTEMP/UT185FD')

             RUNQRY     QRY(UT185) QRYFILE((QTEMP/UT185FD)) +
                          OUTTYPE(*DISPLAY) OUTFORM(*DETAIL)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
