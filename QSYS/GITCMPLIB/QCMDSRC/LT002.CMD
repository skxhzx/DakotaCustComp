/*********************************************************************/
/*                                                                   */
/*  LT002        Set item license tracking flag                      */
/*  01 March 2009                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LT002CL                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command                                             */
/*  &WHSE        Warehouse                                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Set Item License Tracking Flag')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          VALUES(*ALL *INVLD) MIN(1) PROMPT(COMMAND)

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

