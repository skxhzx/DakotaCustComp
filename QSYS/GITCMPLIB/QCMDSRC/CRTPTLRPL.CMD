/*********************************************************************/
/*                                                                   */
/*  CRTPTLRPL   Create potential replenishments.                     */
/*  17 July 1996                                                     */
/*  Dave Sommerville                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Command Processing Program: CRTPTLRPL                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Potential Replenishment')

             PARM       KWD(PGMWHS) TYPE(*DEC) LEN(3) +
                          MIN(1) EXPR(*YES) +
                          PROMPT('Warehouse')

             PARM       KWD(JOBQ) TYPE(*NAME) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) MIN(0) PROMPT('Place +
                          on JOBQ')

