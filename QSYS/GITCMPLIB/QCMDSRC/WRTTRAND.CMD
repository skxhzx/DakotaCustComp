/*********************************************************************/
/*                                                                   */
/*  WRTTRAND   Write PIRTRAND records                                */
/*  02 January 2012                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: WRTTRANDCL                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/16/12  DAS  6.40a                                           */
/*      - Added &CMD, &WAIT                                          */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command                                             */
/*  &WAIT        Minutes to wait with *NONSTOP command               */
/*  &WHSE        Warehouse                                           */
/*  &TRAN#       Transaction                                         */
/*  &FROMDATE    From date (YYYYMMDD)                                */
/*  &TODATE      To date (YYYYMMDD)                                  */
/*  &EMP#        Employee number                                     */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Write PIRTRAND Records')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*ONCE) VALUES(*ONCE *NONSTOP *ONETRAN +
                          *DLTTRAN *CLEAR *CLEANUP *CLEANLOG) +
                          MIN(0) PROMPT('Command')

             PARM       KWD(WAIT) TYPE(*DEC) LEN(2) MIN(0) +
                          PROMPT('Minutes to wait for *NONSTOP')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(0) +
                          PROMPT('Warehouse')

             PARM       KWD(TRAN) TYPE(*DEC) LEN(7) MIN(0) +
                          PROMPT('Transaction')

             PARM       KWD(FROMDATE) TYPE(*DEC) LEN(8) MIN(0) +
                          PROMPT('From Date (YYYYMMDD) optional')

             PARM       KWD(TODATE) TYPE(*DEC) LEN(8) MIN(0) +
                          PROMPT('To Date (YYYYMMDD) optional')

             PARM       KWD(EMP#) TYPE(*DEC) LEN(5) MIN(0) +
                          PROMPT('Employee number - optional')
