/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OP380CL   PIR options - Interface Debugging Options              */
/*  25 October 2013                                                  */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    10/25/13  RTR  6.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OP380CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OP380)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          Interface Debugging Options')
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
