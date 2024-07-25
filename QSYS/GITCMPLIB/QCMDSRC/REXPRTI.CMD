/*********************************************************************/
/*                                                                   */
/*  REXPRTI     Re-export route info                                 */
/*  27 April 2006                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Command Processing Program: PT725CL                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Re-Export Route Info')

             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')
             PARM       KWD(PRTE) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route')
             PARM       KWD(PREX) TYPE(*CHAR) LEN(1) MIN(1) +
                          PROMPT('Re-Export')

