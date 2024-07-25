/*********************************************************************/
/*                                                                   */
/*  APTTRNSEL  SEND APT SEL TRANS TO APT  (YHATA)                    */
/*  March 12,2022                                                    */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: APTTRNSEL                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    03/12/22  KDE  Yhata first                                     */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command                                             */
/*  &PARMS       Parameter string for command.                       */
/*  &DTAQLIB     Data queue library                                  */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send Sel Trans to APT')

             PARM       KWD(WHS) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT(Warehouse)

             PARM       KWD(TRAN) TYPE(*DEC) LEN(7 0) MIN(1) +
                          PROMPT(Transaction)

             PARM       KWD(CMD) TYPE(*CHAR) LEN(10) +
                          SPCVAL((*CRTAPTDTA)) MIN(1) PROMPT(COMMAND)

             PARM       KWD(EMP) TYPE(*DEC) LEN(5 0) MIN(1) +
                          PROMPT('EMPLOYEE NUMBER')

             PARM       KWD(REWRTE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) SPCVAL((N)) +
                          PROMPT('REWRITE (Y/N) ?')

             PARM       KWD(RTN) TYPE(*CHAR) LEN(40) MIN(1) +
                          PROMPT('Retrun String')

