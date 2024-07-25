/*********************************************************************/
/*                                                                   */
/*  BFCOFF      Send BFC signoff message                             */
/*  07 October 1999                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: BFCOFF                               */
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

             CMD        PROMPT('Send BFC Signoff Message')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) DFT(BFC) +
                          PROMPT(User)

             PARM       KWD(MSG) TYPE(*CHAR) LEN(255) DFT('Please +
                          sign off for 20 minutes.') PROMPT(Message)

