/*********************************************************************/
/*                                                                   */
/*  OI300       RESEQUENCE BFC DAKOTA STOPS                          */
/*  29 JANUARY 2009                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: OI300                                */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*       -None-                                                      */
/*                                                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('End BFC Tomcat Server')
             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')

