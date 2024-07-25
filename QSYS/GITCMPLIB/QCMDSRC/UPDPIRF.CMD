/*********************************************************************/
/*                                                                   */
/*  UPDPIRF    Re try update PIR files from update libraries         */
/*  11 September 1997                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Command Processing Program: UPDPIRF                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &FILES       Retry update files (Y,N)                            */
/*  &ULIB        Library to update                                   */
/*  &ULIBF       File library to update                              */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Retry Upadate files')

             PARM       KWD(FILES) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) +
                          PROMPT('Retry Update Files')

             PARM       KWD(ULIB) TYPE(*CHAR) LEN(10) +
                          DFT(PIR) PROMPT('Program library to update')

             PARM       KWD(ULIBF) TYPE(*CHAR) LEN(10) +
                          DFT(PIRF) +
                          PROMPT('File library to update')


