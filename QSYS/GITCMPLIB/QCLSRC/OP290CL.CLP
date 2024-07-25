/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP290CL   PIR options - Item Tracking Options                    */
/*  21 November 2002                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   11/21/02  MLB  4.17                                             */
/*     - Created.                                                    */
/*                                                                   */
/*   11/15/04  MLB  5.00                                             */
/*     - Renamed to Item Tracking Options.                           */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP290CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP290)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('Item +
                          Tracking Options')
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
