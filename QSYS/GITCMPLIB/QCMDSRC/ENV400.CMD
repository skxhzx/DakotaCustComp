/*********************************************************************/
/*                                                                   */
/*  ENV400      Create user profiles                                 */
/*  14 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Command Processing Program: ENV400CL                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &USER        User ID                                             */
/*  &PSWD        Password                                            */
/*  &MENU        Initial menu                                        */
/*  &AUTH        Authority                                           */
/*  &TEXT        Text                                                */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create User Profile')

             PARM       KWD(USER) TYPE(*CHAR) LEN(10) RSTD(*NO) +
                          MIN(0) PROMPT('User ID')

             PARM       KWD(PSWD) TYPE(*CHAR) LEN(10) +
                          PROMPT('Password')

             PARM       KWD(MENU) TYPE(*CHAR) LEN(10) DFT(PIRMAIN) +
                          MIN(0) PROMPT('Initial Menu')

             PARM       KWD(AUTH) TYPE(*CHAR) LEN(10) DFT(*NONE) +
                          MIN(0) PROMPT('Special Authority')

             PARM       KWD(TEXT) TYPE(*CHAR) LEN(30) MIN(0) +
                          PROMPT('Text')

