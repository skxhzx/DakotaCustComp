/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP300CL   PIR options - Expiration / Entered Date Options        */
/*  27 November 2002                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   11/27/02  MLB  4.17                                             */
/*     - Created.                                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP300CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP300)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) +
                          VALUE('Expiration Date / Entered Date +
                          Options')
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
