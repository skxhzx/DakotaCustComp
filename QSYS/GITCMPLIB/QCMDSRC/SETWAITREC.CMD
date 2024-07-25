/*********************************************************************/
/*                                                                   */
/*  SETWAITREC  Change file WAITREC parameter to 30 seconds          */
/*  23 June 1996                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: SETWAITREC                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB         Library containing files.                           */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Change WAITREC to 30 secs')

             PARM       KWD(PGMLIB) TYPE(*NAME) LEN(10) +
                          SPCVAL((*ALL) (*ALLUSR) (*CURLIB) (*LIBL) +
                          (*USRLIBL)) MIN(1) EXPR(*YES) +
                          PROMPT('Library containing files')

             PARM       KWD(JOBQ) TYPE(*NAME) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) MIN(0) PROMPT('Place +
                          on JOBQ')

