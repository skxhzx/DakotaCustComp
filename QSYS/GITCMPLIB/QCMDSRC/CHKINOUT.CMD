/*********************************************************************/
/*                                                                   */
/*  CHKINOUT    Check data area in/out - only allowed to chk in once */
/*  19 September 2000                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CHKINOUT                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &OPT         Option - *IN, *OUT, *VIEW                           */
/*  &DTAARA      Data area                                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Check Data Area In/Out')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          VALUES(*IN *OUT *VIEW) MIN(1) PROMPT('Type')

             PARM       KWD(DTAARA) TYPE(*NAME) LEN(10) PROMPT('Data +
                          area')

