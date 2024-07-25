/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT729CL   Display Unexported item adjustments                    */
/*  10 December, 2001                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT729CL:    PGM        PARM(&PWHSE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(IT729)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PWHSE)  TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */


/*  On with the show ... */

             CALL       PGM(&PGM) PARM(&PWHSE)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
