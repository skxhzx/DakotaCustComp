/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP270CL   PIR options - Dock Door options                        */
/*  13 February 2002                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/13/02  MLB  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP270CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP270)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('Dock +
                          Door Options')
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
