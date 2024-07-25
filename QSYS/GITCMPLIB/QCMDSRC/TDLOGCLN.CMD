/*********************************************************************/
/*                                                                   */
/*  TDLOGCLN    WRTTRAND log file cleanup                            */
/*  15 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TDLOGCLN                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*   02/15/12  DAS  6.40                                             */
/*     - Created.                                                    */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DAYS        Days.Hours of history to keep.                      */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('WRTTRAND Log Cleanup')

             PARM       KWD(DAYS) TYPE(*DEC) LEN(4 2) DFT(3) +
                          CHOICE('Days.Hours') PROMPT('Log +
                          history to keep')

