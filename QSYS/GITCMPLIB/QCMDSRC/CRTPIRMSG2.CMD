/*********************************************************************/
/*                                                                   */
/*  CRTPIRMSG2  Create all PIR messages - Variable library           */
/*  24 July 2006                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CRTPIRMSG2                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB         Library                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create All PIR Messages')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(PIR) +
                          PROMPT('Library')

