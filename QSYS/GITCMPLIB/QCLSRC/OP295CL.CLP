/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP295CL   PIR options - Item Tracking Default Levels             */
/*  15 November 2004                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   11/15/04  DAS  5.00                                             */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP295CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP295)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('Item +
                          Tracking Default Levels')
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
