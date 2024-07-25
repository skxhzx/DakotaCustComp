/*********************************************************************/
/*                                                                   */
/*  TDFORCE     Send FORCE command to WRTTRAND data queue            */
/*  17 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TDFORCE                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/17/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CONFIRM     Confirm                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send FORCE to WRTTRAND Dtaq')

             PARM       KWD(CONFIRM) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Are you +
                          sure?')
