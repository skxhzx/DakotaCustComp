/*********************************************************************/
/*                                                                   */
/*  SCD320      View check digits                                    */
/*  16 June 2006                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: SCD320CL                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('View Check Digits')

             PARM       KWD(WHSE) TYPE(*CHAR) LEN(3) DFT(' ') +
                          PROMPT('Warehouse')
             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) DFT(' ') +
                          PROMPT('Department')
             PARM       KWD(STYP) TYPE(*CHAR) LEN(1) DFT(' ') +
                          PROMPT('Section')
             PARM       KWD(STAT) TYPE(*CHAR) LEN(4) DFT(' ') +
                          PROMPT('Stat')
             PARM       KWD(RETURN) TYPE(*CHAR) LEN(8) DFT(' ') +
                          PROMPT('Return')
             PARM       KWD(DEV) TYPE(*CHAR) LEN(10) DFT(' ') +
                          PROMPT('Device')
             PARM       KWD(FORM) TYPE(*CHAR) LEN(10) DFT(' ') +
                          PROMPT('Form')
             PARM       KWD(HEAD) TYPE(*CHAR) LEN(50) DFT(' ') +
                          PROMPT('Heading')

