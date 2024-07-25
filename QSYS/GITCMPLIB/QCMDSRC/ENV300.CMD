/*********************************************************************/
/*                                                                   */
/*  ENV300      Create live Job description                          */
/*  25 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Command Processing Program: ENV300CL                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Live Job Description')

             PARM       KWD(JOBD) TYPE(*CHAR) LEN(10) RSTD(*NO) +
                          DFT(BFCLIVE) MIN(0) PROMPT('Job Description')


