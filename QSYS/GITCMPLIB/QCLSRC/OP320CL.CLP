/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP320CL   PIR options - Slot Pallet Position Tracking Options    */
/*  25 August 2004                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   08/25/04  DAS  5.00                                             */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP320CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP320)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE('Slot +
                          Pallet Position Tracking Options')
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
