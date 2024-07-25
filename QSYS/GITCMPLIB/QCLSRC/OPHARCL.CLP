/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OPHARCL   HARBOR label options                                   */
/*  13 March 2007                                                    */
/*  Retha Davis                                                      */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/13/07  RBD  5.10                                            */
/*      - Created.                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OPHARCL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OPHAR)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Harbor Label Options')
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
