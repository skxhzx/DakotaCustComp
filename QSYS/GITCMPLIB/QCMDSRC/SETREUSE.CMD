/*********************************************************************/
/*                                                                   */
/*  SETREUSE    Change physical files to reused deleted records      */
/*  27 April 1993                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: SETREUSE                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB         Library containing files.                           */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Change PF to rused deletes')

             PARM       KWD(PGMLIB) TYPE(*NAME) LEN(10) +
                          SPCVAL((*ALL) (*ALLUSR) (*CURLIB) (*LIBL) +
                          (*USRLIBL)) MIN(1) EXPR(*YES) +
                          PROMPT('Library containg files')

             PARM       KWD(JOBQ) TYPE(*NAME) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) MIN(0) PROMPT('Place +
                          on JOBQ')

