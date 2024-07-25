/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP220CL   PIR options - Replenishment                            */
/*  11 January 2000                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/11/00  MLB  4.13                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP220CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP220)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) +
                          VALUE('Replenishment Options')
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
