/*********************************************************************/
/*                                                                   */
/*  ENV200      Create test user profile.                            */
/*  25 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Command Processing Program: ENV200CL                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Test User Profile')

             PARM       KWD(USRID) TYPE(*CHAR) LEN(10) RSTD(*NO) +
                          DFT(BFCTEST) MIN(0) PROMPT('User ID')


