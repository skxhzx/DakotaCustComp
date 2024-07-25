/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TR310CL   View Trax logs                                         */
/*  13 Feb 2012                                                      */
/*  Retha Davis                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TR310CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(TR310)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&WHSE)   TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&RTID)   TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTE)    TYPE(*CHAR) LEN(5)
             DCL        VAR(&DATE)   TYPE(*DEC)  LEN(6 0)
             DCL        VAR(&DWNUP)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&ERRONL) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  On with the show ... */

             CALL       PGM(&PGM)  PARM(&WHSE &RTID &RTE &DATE +
                          &DWNUP &ERRONL)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
