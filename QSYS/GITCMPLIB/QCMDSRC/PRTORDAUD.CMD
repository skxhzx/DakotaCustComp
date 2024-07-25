/*********************************************************************/
/*                                                                   */
/*  PRTORDAUD      Truck Build - Traffic Cop                         */
/*  29 March 2019                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: PRTORDAUD                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*  03/29/19  MLB  7.30                                              */
/*    - Created.                                                     */
/*      Note: Required with 7.30b mod in QRPGSRC/PRTORDAUD.          */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Print Audited Order')

             PARM       KWD(PCMD) TYPE(*CHAR) LEN(10) PROMPT('Command')
             PARM       KWD(PJOBQ) TYPE(*CHAR) LEN(1) PROMPT('JobQ Y/N')
             PARM       KWD(Pwhse) TYPE(*dec) LEN(3 0) +
                          PROMPT('Warehouse')
             PARM       KWD(PTRANLST) TYPE(*CHAR) LEN(100) +
                          PROMPT('Transaction List')
             PARM       KWD(Pordid) TYPE(*dec) LEN(7 0) +
                          PROMPT('Order ID')
             PARM       KWD(Prtn) TYPE(*CHAR) LEN(10) +
                          PROMPT('Return code')
             PARM       KWD(Pmsg) TYPE(*CHAR) LEN(100) +
                          PROMPT('Return Message')
