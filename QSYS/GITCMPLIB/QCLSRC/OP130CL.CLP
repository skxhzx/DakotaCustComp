/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP130CL   PIR options - Putaway      416 M                       */
/*  29 October 1994                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    09/24/01  DAS  4.16                                            */
/*      - Changed name to "Receiving Priorities from "Receiving".    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP130CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP130)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) +
                          VALUE('Receiving Priorities')  /* 416 M */
    /*                    VALUE('Receiving Options')        416 D */
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
