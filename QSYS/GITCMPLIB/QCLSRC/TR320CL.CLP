/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TR320CL   View Trax routes                                       */
/*  14 Oct 2011                                                      */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TR320CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(TR320)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHSE)   TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&RTE)    TYPE(*CHAR) LEN(5)
             DCL        VAR(&DEV)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  On with the show ... */

             CHGVAR     VAR(&CMD) VALUE('*SPECIAL')

             CALL       PGM(&PGM)  PARM(&CMD &WHSE &RTE &DEV &FORM)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
