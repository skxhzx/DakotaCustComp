/*********************************************************************/
/*                                                                   */
/*  CLRSCLDTAQ    Clear SCALES or SCALESERV data queue               */
/*  16 November 2015                                                 */
/*  Donnie Sanders                                                   */
/*                                                                   */
/*  Command Processing Program: CLRSCLDTAQ                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    11/16/15  DLS  7.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DTAQ        Data queue to clear                                 */
/*  &DTAQLIB     Library of data queue to clear                      */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear Scale Data Queues')

             PARM       KWD(DTAQ) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          VALUES(SCALES SCALESERV) MIN(1) +
                          PROMPT('Data queue to clear')

             PARM       KWD(DTAQLIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library of data +
                          queue')

