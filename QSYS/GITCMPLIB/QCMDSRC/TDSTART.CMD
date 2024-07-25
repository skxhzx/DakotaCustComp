/*********************************************************************/
/*                                                                   */
/*  TDSTART     Start WRTTRAND                                       */
/*  15 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TDSTART                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/15/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &ID          Environment id (i.e., PRO, TST, ...)                */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Start WRTTRAND')

             PARM       KWD(ID) TYPE(*CHAR) LEN(3) DFT(ZZZ) +
                          PROMPT('Id (i.e., PRO, TST, ...)')
