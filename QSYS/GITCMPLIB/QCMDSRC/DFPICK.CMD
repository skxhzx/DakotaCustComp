/*********************************************************************/
/*                                                                   */
/*  DFPICK      Manually redefine picking sequence                   */
/*  02 March 2006                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DFPICK                               */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Manually Redefine Pick Seq')

             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')

