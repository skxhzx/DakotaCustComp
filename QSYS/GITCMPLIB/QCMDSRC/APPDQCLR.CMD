/*********************************************************************/
/*                                                                   */
/*  APPDQCLR  Clear Android App data queue                           */
/*  01 February 2022                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: APPDQCLR                             */
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
/*  &DTAQ        Data queue to clear                                 */
/*               IN  - APPDQIN                                       */
/*               OUT - APPDQOUT                                      */
/*  &MIN         Minutes to keep                                     */
/*  &CONFIRM     Confirm                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear Android App Data Queue')

             PARM       KWD(DTAQ) TYPE(*CHAR) LEN(3) RSTD(*YES) +
                          VALUES(IN OUT) CHOICE(*VALUES) +
                          PROMPT('Data Queue')

             PARM       KWD(MIN) TYPE(*DEC) LEN(5) DFT(5) RANGE(1 +
                          99999) CHOICE(*VALUES) PROMPT('Minutes to +
                          keep')

             PARM       KWD(CONFIRM) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Are you +
                          sure?')
