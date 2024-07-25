/*********************************************************************/
/*                                                                   */
/*  TDEND       End WRTTRAND                                         */
/*  15 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TDEND                                */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/15/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CONFIRM     Confirm                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('End WRTTRAND')

             PARM       KWD(CONFIRM) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Are you +
                          sure?')
