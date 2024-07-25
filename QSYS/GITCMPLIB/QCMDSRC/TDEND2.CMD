/*********************************************************************/
/*                                                                   */
/*  TDEND2      End WRTTRAND2                                        */
/*  30 August 2012                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TDEND2                               */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/30/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CONFIRM     Confirm                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('End WRTTRAND2')

             PARM       KWD(CONFIRM) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PROMPT('Are you +
                          sure?')
