/*********************************************************************/
/*                                                                   */
/*  SAPENDIMP  End SAP Import Server                                 */
/*  May 22, 2012                                                     */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: SAPENDIMP                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    05/22/12  RTR  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &MODE        Server to start (*PROD/*TEST)                       */
/*                                                                   */
/*********************************************************************/
             CMD        PROMPT('End SAP Import Server')

             PARM       KWD(MODE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*PROD) VALUES(*PROD *TEST) +
                          PROMPT('Run Mode')

