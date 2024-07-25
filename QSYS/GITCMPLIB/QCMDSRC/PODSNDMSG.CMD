/*********************************************************************/
/*                                                                   */
/*  PODSNDMSG    Send message to user                                */
/*  05 September 2008                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: PODSNDMSG                            */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &USER        User to send message to                             */
/*  &MSG         Message                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send Message to User')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('User')

             PARM       KWD(MSG) TYPE(*CHAR) LEN(512) MIN(1) +
                          CASE(*MIXED) PROMPT(Message)

