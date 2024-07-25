/*********************************************************************/
/*                                                                   */
/*  APTFTP2     Execute FTP from batch.                              */
/*  November 9, 2011                                                 */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: APTFTP2CL                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('APT - FTP Execute')

             PARM       KWD(Pcmd) TYPE(*CHAR) LEN(8) PROMPT('Command ')
             PARM       KWD(Pwhse) TYPE(*dec) LEN(3 0) +
                          PROMPT('Warehouse')
             PARM       KWD(Prtid) TYPE(*CHAR) LEN(5) +
                          PROMPT('Route Id')
             PARM       KWD(Prte) TYPE(*CHAR) LEN(5) +
                          PROMPT('Route Nbr')
             PARM       KWD(Pmbr) TYPE(*CHAR) LEN(10) +
                          PROMPT('Export member name')
             PARM       KWD(Pfile) TYPE(*CHAR) LEN(30) +
                          PROMPT('Remote host export file name')
             PARM       KWD(Prtn) TYPE(*CHAR) LEN(10) +
                          PROMPT('Return code')
             PARM       KWD(Pmsg) TYPE(*CHAR) LEN(4) +
                          PROMPT('Message number')

