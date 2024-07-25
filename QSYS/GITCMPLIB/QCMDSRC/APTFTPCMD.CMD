/*********************************************************************/
/*                                                                   */
/*  APTFTPCMD  Send command to APTFTP                                */
/*  November 9, 2011                                                 */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: APTFTPCMD                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    11/09/11  RTR  LED                                             */
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

             CMD        PROMPT('Send Command to APTFTP')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          SPCVAL((*SEND) (*SENDT) (*RESEND) +
                          (*CHGWAIT) (*END)) MIN(1) PROMPT(COMMAND)

             PARM       KWD(PARMS) TYPE(*CHAR) LEN(30) +
                          PROMPT('Command parameters')

             PARM       KWD(DTAQLIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data Queue Library')

