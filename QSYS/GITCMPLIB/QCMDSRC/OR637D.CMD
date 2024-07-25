/*********************************************************************/
/*                                                                   */
/*  OR637D      Manually delete ORDP piece seq# records              */
/*  20 June 2007                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: OR637D                               */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Manually Delete ORDP Records')

             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')

