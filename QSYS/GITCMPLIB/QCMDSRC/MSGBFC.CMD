/*********************************************************************/
/*                                                                   */
/*  MSGBFC    Command to execute MSGBFC program                      */
/*  03 December 1990                                                 */
/*  DAVE SOMMERVILLE                                                 */
/*                                                                   */
/*  Command Processing Program: MSGBFC                               */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*     MESSAGE    - Message to display                               */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Display user message')

             PARM       KWD(MESSAGE) TYPE(*CHAR) LEN(512) +
                          PROMPT('Message')

