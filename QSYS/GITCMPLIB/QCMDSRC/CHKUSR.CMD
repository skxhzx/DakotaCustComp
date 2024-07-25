/*********************************************************************/
/*                                                                   */
/*  CHKUSR      Check user in/out - only allowed to chk user in once */
/*  02 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CHKUSR                               */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &OPT         Option - *IN, *OUT, *VIEW                           */
/*  &USER        User                                                */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Check user In/Out')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          VALUES(*IN *OUT *VIEW) MIN(1) PROMPT('Type')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) +
                          PROMPT('User')

