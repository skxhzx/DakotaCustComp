/*********************************************************************/
/*                                                                   */
/*  DSPTDDTAQ    Display WRTTRAND data queue                         */
/*  16 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DSPTDDTAQ                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/16/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/30/12  DAS  6.40a                                           */
/*      - Added data queue parameter                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DTAQ        Data queue to clear                                 */
/*               1 = WRTTRAND                                        */
/*               2 = WRTTRAND2                                       */
/*               3 = WRTTRAND3                                       */
/*  &TYPE        Information type (*ENTRIES,*DESC)                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Display WRTTRAND Data Queues')

             PARM       KWD(DTAQ) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          VALUES(1 2 3) CHOICE('1=WRTTRAN +
                          2/3=WRTTRAN2/3') PROMPT('Data Queue')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ENTRIES) VALUES(*ENTRIES *DESC) +
                          PROMPT('Information type')
