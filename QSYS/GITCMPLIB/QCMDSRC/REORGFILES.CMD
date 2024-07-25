/*********************************************************************/
/*                                                                   */
/*  REORGFILES  Reorganize files in a library.                       */
/*  23 April 1993                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: REORGFILES                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB         Library containing programs.                        */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Reorganize Files in a Library')

             PARM       KWD(PGMLIB) TYPE(*NAME) LEN(10) +
                          SPCVAL((*ALL) (*ALLUSR) (*CURLIB) (*LIBL) +
                          (*USRLIBL)) MIN(1) EXPR(*YES) +
                          PROMPT('Library for reorganization')

             PARM       KWD(JOBQ) TYPE(*NAME) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) MIN(0) PROMPT('Place +
                          on JOBQ')

