/*-------------------------------------------------------------------*/
/*                                                                   */
/*  US220CL   Program User Security - Driver                         */
/*  21 September 2014                                                */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    09/21/14  RTR  6.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 US220CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(US220)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Program User Security')
             DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*NO)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
