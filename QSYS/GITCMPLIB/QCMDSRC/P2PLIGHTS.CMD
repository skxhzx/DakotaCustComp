/*********************************************************************/
/*                                                                   */
/*  P2PLIGHTS    Pick to Pallet Lights                               */
/*  01 October 2019                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: P2PLIGHTS                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    10/01/19  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command                                             */
/*  &ID          Pallet jack id                                      */
/*  &POS         Pallet position                                     */
/*  &SIDE        Side                                                */
/*  &STAT        Pallet status                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Execute Pick To Pallet')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          VALUES(*OPEN *SET *TEST *CLOSE) MIN(1) +
                          ALWUNPRT(*NO) PROMPT('Command')

             PARM       KWD(ID) TYPE(*CHAR) LEN(10) RSTD(*NO) +
                          ALWUNPRT(*NO) PROMPT('Pallet Jack Id')

             PARM       KWD(POS) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          VALUES(A B C Z) ALWUNPRT(*NO) +
                          PROMPT('Position (Z = All Lights)')

             PARM       KWD(SIDE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          VALUES(L R B) ALWUNPRT(*NO) PROMPT('Side +
                          (Left, Right, Both)')

             PARM       KWD(STAT) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          VALUES(0 1) ALWUNPRT(*NO) PROMPT('Status +
                          (0=Off, 1=On)')

