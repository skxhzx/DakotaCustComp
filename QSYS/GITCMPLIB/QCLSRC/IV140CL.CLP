/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV140CL   Display Inventory Status                               */
/*  28 February, 1996                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    09/17/02  RH   4.16                                            */
/*      - Add &PWHDP parameter.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV140CL:    PGM        PARM(&PWHSE &PWHDP)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(IV140)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PWHSE)  TYPE(*CHAR) LEN(3)
             DCL        VAR(&PWHDP)  TYPE(*CHAR) LEN(5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */


/*  On with the show ... */

             CALL       PGM(&PGM) PARM(&PWHSE &PWHDP)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
