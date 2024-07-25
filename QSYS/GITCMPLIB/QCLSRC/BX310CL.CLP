/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BX310CL   Display of AMP Box info from CMD Line or BX-RH150A etc */
/*  21 April 2016                                                    */
/*  Nancy Koelz                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    04/21/16  NLK  7.00                                            */
/*      - Created to run the display from a command line             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 BX310CL:    PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&cmd) TYPE(*CHAR) LEN(8)
             DCL        VAR(&whse) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&dt) TYPE(*DEC) LEN(8 0)
             DCL        VAR(&box)  TYPE(*DEC) LEN(3 0)
             DCL        VAR(&cord) TYPE(*DEC) LEN(7 0)
             DCL        VAR(&tran)   TYPE(*DEC) LEN(7 0)
             DCL        VAR(&cust)   TYPE(*DEC) LEN(11 0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(BX310) PARM(&cmd &whse $dt $box $cord $tran $cust)

             ENDPGM
