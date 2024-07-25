/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TR852CL   Trax Stop Level Options                                */
/*  27 March, 2012                                                   */
/*  Retha Davis                                                      */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/27/12  RBD  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TR852CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(TR852)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD) TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHSE) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&RTE) TYPE(*CHAR) LEN(5)
             DCL        VAR(&STOP) TYPE(*DEC) LEN(2 0)
             DCL        VAR(&DEV) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RTN) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(&PGM)  PARM(&CMD &WHSE &RTE &STOP &DEV &FORM &RTN)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
