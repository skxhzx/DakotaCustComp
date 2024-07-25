/*********************************************************************/
/*                                                                   */
/*  ENV100      Create test Job description                          */
/*  25 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Command Processing Program: ENV100CL                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Test Job Description')

             PARM       KWD(JOBD) TYPE(*CHAR) LEN(10) RSTD(*NO) +
                          DFT(BFCTEST) MIN(0) PROMPT('Job Description')


