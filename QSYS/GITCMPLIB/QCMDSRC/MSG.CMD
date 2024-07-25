/*********************************************************************/
/*                                                                   */
/*  MSG       Command to execute MSG program                         */
/*  03 December 1990                                                 */
/*  DAVE SOMMERVILLE                                                 */
/*                                                                   */
/*  Command Processing Program: MSG                                  */
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

