/*********************************************************************/
/*                                                                   */
/*  DLTUPDLIB   Delete PIR update libraries                          */
/*  01 March 1996                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DLTUPDLIB                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &OPT1        First Y/N option                                    */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*  &OPT2        'Are you sure?' Y/N option                          */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Delete PIR update libraries')

             PARM       KWD(OPT1) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) PROMPT('Delete +
                          update libraries')

             PARM       KWD(JOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('Place on JOBQ')

             PARM       KWD(OPT2) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PMTCTL(OPT1) +
                          PROMPT('Are you sure')

 OPT1:       PMTCTL     CTL(OPT1) COND((*EQ *YES))
