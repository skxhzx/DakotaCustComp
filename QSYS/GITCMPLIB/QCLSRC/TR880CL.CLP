/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TR880CL   Trax - reset downloaded or uploaded status.            */
/*  09 February 2012                                                 */
/*  Retha Davis                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    02/09/12  RBD  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD       *CHANGE   Allow changes to be made.                 */
/*                                                                   */
/*    &RTN       *CANCEL   User canceled.                            */
/*               *INVALID  User entered invalid password.            */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TR880CL:    PGM        PARM(&CMD &RTN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Informational messages. */

             DCL        VAR(&INFOMSG1) TYPE(*CHAR) LEN(60) +
                          VALUE('   Invalid password entered.')

             DCL        VAR(&INFOMSG2) TYPE(*CHAR) LEN(60) +
                          VALUE('User canceled.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHS)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&RTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&DEV)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&RTN)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(TR880) PARM(&CMD &WHS &RTE &DEV &FORM &RTN)

/*  Check if user entered valid password.                               */

             IF         COND(&RTN *EQ '*INVALID')  THEN(DO)
                        SNDPGMMSG  MSG(&INFOMSG1)   +
                        MSGTYPE(*INFO)
             RETURN
             ENDDO

/*  Check if user canceled.                                             */

             IF         COND(&RTN *EQ '*CANCEL')  THEN(DO)
                        SNDPGMMSG  MSG(&INFOMSG2)   +
                        MSGTYPE(*INFO)
             RETURN
             ENDDO

             RCLRSC     LVL(*CALLER)

             ENDPGM
