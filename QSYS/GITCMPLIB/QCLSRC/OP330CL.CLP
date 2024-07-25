/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP330CL   PIR options - Runner Flag                              */
/*  28 October 2005                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    10/28/05  MLB  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    12/02/05  JCJ  5.00                                            */
/*      - Enh. Changed Global value from *Yes to *No                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP330CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP330)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Runner Flag Options')
/* 500 D     DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*YES)  */
/* 500 M */  DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*NO)

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
