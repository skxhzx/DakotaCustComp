/*********************************************************************/
/*                                                                   */
/*  APTENDFTP  End APTFTP server                                     */
/*  November 1, 2011                                                 */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: APTENDFTP                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    11/01/11  RTR  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DTAQLIB     Data queue library                                  */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('End APTFTP Server')

             PARM       KWD(DTAQLIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data Queue Library')

