/*********************************************************************/
/*                                                                   */
/*  APPDQCRT  Create Android App data queue                          */
/*  02 February 2022                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: APPDQCRT                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/01/22  DAS  7.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB         Library to create queues in                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Android App Data Queues')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) +
                          SPCVAL((*CURRENT *CURRENT)) MIN(1) +
                          PROMPT('Library for data queues')

