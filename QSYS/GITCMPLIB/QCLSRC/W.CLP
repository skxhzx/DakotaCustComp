/*-------------------------------------------------------------------*/
/*                                                                   */
/*  W         Display message with user's default warehouse          */
/*  10 May 2002                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    05/10/02  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 W:          PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DESC)       TYPE(*CHAR) LEN(30)
             DCL        VAR(&DESC2)      TYPE(*CHAR) LEN(40)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    USER(&USER)

/* Get user's warehouse information */

             CALL       PGM(GETWHSE2) PARM(&USER &WHSE &DESC &DESC2)

/* Display message and get out */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&DESC2) MSGTYPE(*COMP)

             RCLRSC     LVL(*CALLER)

             ENDPGM
