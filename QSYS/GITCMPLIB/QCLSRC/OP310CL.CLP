/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP310CL   PIR options - Voice                                    */
/*  17 May 2004                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/17/04  DAS  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    12/02/05  JCJ  5.00                                            */
/*      - Enh. Changed Global value from *Yes to *No                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP310CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP310)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Voice Options')
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
