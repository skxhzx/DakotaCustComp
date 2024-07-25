/*********************************************************************/
/*                                                                   */
/*  BFCON       Send BFC signon message                              */
/*  07 October 1999                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: BFCON                                */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &USER        User to send message to                             */
/*  &MSG         Message to send                                     */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send BFC Signon Message')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) DFT(BFC) +
                          PROMPT(User)

             PARM       KWD(MSG) TYPE(*CHAR) LEN(255) DFT('Ok to +
                          signon') PROMPT(MESSAGE)

