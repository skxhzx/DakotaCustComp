/*********************************************************************/
/*                                                                   */
/*  CLRIUSE     Truck Build - Clear Inuse flag                       */
/*  25 July 2002                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: CHKIUSE                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*    03/28/13  DAS  650a                                            */
/*      - Revised command to be *CLEARUT instead of *CLEAR.          */
/*        This is for tracking purposes.                             */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Truck Build - Clear Inuse Flag')

             PARM       KWD(PCMD) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          VALUES(*CLEARUT) MIN(1) PROMPT('Command #1')
             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')
             PARM       KWD(PRTN) TYPE(*CHAR) LEN(8) CONSTANT(' ') +
                          PROMPT(*NONE)

