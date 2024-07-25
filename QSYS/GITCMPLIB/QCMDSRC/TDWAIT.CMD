/*********************************************************************/
/*                                                                   */
/*  TDWAIT    Send WAIT command to WRTTRAND data queue               */
/*  17 January 2012                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: WRTTRANDCL                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/16/12  DAS  6.40a                                           */
/*      - Added &CMD, &WAIT                                          */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WAIT        Minutes to wait with *NONSTOP command               */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Send WAIT Command to WRTTRAND')

             PARM       KWD(WAIT) TYPE(*DEC) LEN(2) RANGE(1 99) +
                          MIN(1) PROMPT('Minutes to wait')
