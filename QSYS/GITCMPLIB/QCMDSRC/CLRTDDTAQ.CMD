/*********************************************************************/
/*                                                                   */
/*  CLRTDDTAQ    Clear WRTTRAND data queue                           */
/*  15 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CLRTDDTAQ                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/15/12  DAS  6.40                                            */
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
/*  &CONFIRM     Confirm                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear WRTTRAND Data Queue')

             PARM       KWD(DTAQ) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          VALUES(1 2 3) CHOICE('1=WRTTRAN +
                          2/3=WRTTRAN2/3') PROMPT('Data Queue')

             PARM       KWD(CONFIRM) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Are you +
                          sure?')
