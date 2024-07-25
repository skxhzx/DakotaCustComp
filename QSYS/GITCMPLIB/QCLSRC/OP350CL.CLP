/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP350CL   PIR options - Inventory Count                          */
/*  15 December 2006                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    12/15/06  RH   5.10                                            */
/*      - Created.                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP350CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP350)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Inventory Count Options')
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
