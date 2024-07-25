/*********************************************************************/
/*                                                                   */
/*  TR310    View Trax log                                           */
/*  13 July 2010                                                     */
/*  Retha Davis                                                      */
/*                                                                   */
/*  Command Processing Program: TR310                                */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &RTID        Route id                                            */
/*  &RTE         Route code                                          */
/*  &DATE        From date (MMDDYY)                                  */
/*  &DWNUP       Display only routes downloaded but not uploaded     */
/*  &ERRONLY     Display only errors (Y,N)                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('View Trax Log')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(RTID) TYPE(*CHAR) LEN(5) DFT(*ALL) +
                          MIN(0) PROMPT('Route Id')

             PARM       KWD(RTE) TYPE(*CHAR) LEN(5) DFT(*ALL) +
                          PROMPT('Route')

             PARM       KWD(DATE) TYPE(*DEC) LEN(6) DFT(0) +
                          CHOICE('MMDDYY, 0=All') PROMPT('From Date')

             PARM       KWD(DWNUP) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Downloaded & not +
                          yet uploaded')

             PARM       KWD(ERRONLY) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) PROMPT('Display only +
                          errors')

