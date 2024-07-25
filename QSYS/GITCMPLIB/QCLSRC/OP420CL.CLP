/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP420CL   PIR options - Adjustment Interface Options             */
/*  22 March 2016                                                    */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/22/16  RTR  7.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP420CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP420)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Adjustment Interface Options')
             DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*NO)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(OP010) PARM(&PGM &DESC &GLOBAL &RETURN)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
