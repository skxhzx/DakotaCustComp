/*********************************************************************/
/*                                                                   */
/*  CRTSCLDTAQ    Create SCALES or SCALESERV data queue                     */
/*  16 November 2015                                                 */
/*  Donnie Sanders                                                   */
/*                                                                   */
/*  Command Processing Program: CRTSCLDTAQ                            */
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
/*  &DTAQ        Data queue to create                                */
/*  &DTAQLIB     Library to create queues in                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Scale Data Queues')

             PARM       KWD(DTAQ) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          VALUES(SCALES SCALESERV) MIN(1) +
                          PROMPT('Data queue to create')

             PARM       KWD(DTAQLIB) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Libary for data queue')


