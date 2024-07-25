/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADRFCL3A  Equip check in, clear flags, load, equip check out.  */
/*                                                                   */
/*  April 27, 2009                                                   */
/*  Retha Davis                                                      */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  04/27/09  RBD  5.20                                              */
/*   - Created                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADRFCL3A:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(2)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Set screen size for other programs to use */

             CALL PIRRFSCR ('*SET' '08' '020')

             CALL       PGM(EQ410CL)
             CALL       PGM(RU310CL)
             CALL       PGM(EQ410CL)

/*  Clean up before leaving */
             RCLRSC     LVL(*CALLER)

             ENDPGM
