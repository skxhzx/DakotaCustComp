/*********************************************************************/
/*                                                                   */
/*  LODEPM      Initial load of EPM libraries.                       */
/*  12 March 1996                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LODEPM                               */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DEVICE      Tape device                                         */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Initial Load of EPM Libraries')

             PARM       KWD(DEVICE) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Device')

             PARM       KWD(JOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('Place on JOBQ')

