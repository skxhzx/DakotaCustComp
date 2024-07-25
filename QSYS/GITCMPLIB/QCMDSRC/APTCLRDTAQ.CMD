/*********************************************************************/
/*                                                                   */
/*  APTCLRDTAQ    Clear APTDTAQ data queue                           */
/*  November 1, 2011                                                 */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: APTCLRDTAQ                           */
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
/*  &LIB         Library to create queues in                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear APTDTAQ Data Queue')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data queue library')

