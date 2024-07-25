/*********************************************************************/
/*                                                                   */
/*  RH155ST      Front end to RH155ST                                */
/*  01 April 2018                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: RH155ST                              */
/*  Validity Checking Program:  None                                 */
/*********************************************************************/
/*  Revisions:                                                       */
/*  04/01/18  MLB  7.20                                              */
/*    - Created.                                                     */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &TRN#        Transaction number                                  */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Transaction Export RH155ST')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3 0) MIN(0) +
                          PROMPT('Warehouse')

             PARM       KWD(TRAN) TYPE(*DEC) LEN(7 0) MIN(0) +
                          PROMPT('Transaction number')

