/*********************************************************************/
/*                                                                   */
/*  DRILOGCLN   Dakota Realtime Interface log file cleanup           */
/*  27 February 2002                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DRILOGCLN                            */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*   03/29/02  DAS  4.16                                             */
/*     - Added Hours parameter.                                      */
/*     - Changed wording for Days parameter.                         */
/*                                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DAYS        Days of history to keep for non-LOGDRI logs         */
/*  &HOURS       Hours of history to keep for LOGDRI                 */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('DRI Log File Cleanup')

             PARM       KWD(DAYS) TYPE(*DEC) LEN(3) DFT(7) +
                          CHOICE('Days, (-1 to clear file)') +
                          PROMPT('Non-DRIMAIN history to keep')

             PARM       KWD(HOURS) TYPE(*DEC) LEN(3) DFT(24) +
                          CHOICE('Hours (0 to clear file)') +
                          PROMPT('DRIMAIN history to keep')

