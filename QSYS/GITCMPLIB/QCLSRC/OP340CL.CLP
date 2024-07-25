/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP340CL   PIR Options - Interleaving                             */
/*  03 January 2006                                                  */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/03/06  JCJ  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP340CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP340)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Interleaving Replenishment Options')
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
