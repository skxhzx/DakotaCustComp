/*********************************************************************/
/*                                                                   */
/*  PT725CL     EXPORT ROUTE INFO                                    */
/*  18 JANUARY 2016                                                  */
/*  MAX BLACKNIK                                                     */
/*                                                                   */
/*  COMMAND PROCESSING PROGRAM: PT725CL                              */
/*  VALIDITY CHECKING PROGRAM:  NONE                                 */
/*                                                                   */
/*********************************************************************/
/*  REVISIONS:                                                       */
/*  01/18/16  MLB  7.00                                              */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  PARAMETERS                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('EXPORT ROUTE INFO')

             PARM       KWD(PWHS) TYPE(*DEC) LEN(3 0) +
                          PROMPT('WAREHOUSE')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) +
                          PROMPT('ROUTE ID')
             PARM       KWD(PTRTE) TYPE(*CHAR) LEN(5) +
                          PROMPT('TRANSFER ROUTE')
             PARM       KWD(PREEXP) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          VALUES(' ' 'Y') PROMPT('REEXPORT FLAG')

