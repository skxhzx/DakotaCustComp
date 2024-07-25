/*********************************************************************/
/*                                                                   */
/*  CLRDRILOG   Dakota Realtime Interface log file cleanup           */
/*              *** Calls DRILOGCLN ***                              */
/*  18 February 2005                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DRILOGCLN                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*   02/18/05  DAS  5.00                                             */
/*     - Created                                                     */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DAYS        Days of history to keep for non-LOGDRI logs         */
/*  &HOURS       Hours of history to keep for LOGDRI                 */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('DRI Log File Cleanup')

             PARM       KWD(DAYS) TYPE(*DEC) LEN(3) DFT(-1) +
                          CHOICE('Days, (-1 to clear file)') +
                          PROMPT('Non-DRIMAIN history to keep')

             PARM       KWD(HOURS) TYPE(*DEC) LEN(3) DFT(0) +
                          CHOICE('Hours (0 to clear file)') +
                          PROMPT('DRIMAIN history to keep')

