/*********************************************************************/
/*                                                                   */
/*  ENV700      Refresh test library                                 */
/*  25 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Command Processing Program: ENV700CL                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &FROM        From library                                        */
/*  &TO          To library                                          */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Refresh Test Library')

             PARM       KWD(FROM) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(PIRF) VALUES(PIRF) MIN(0) +
                          PROMPT('From Library')

             PARM       KWD(TO) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(PIRTESTF) VALUES(PIRTESTF) PROMPT('To +
                          Library')


