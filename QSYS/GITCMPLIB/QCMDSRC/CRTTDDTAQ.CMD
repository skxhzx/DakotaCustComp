/*********************************************************************/
/*                                                                   */
/*  CRTTDDTAQ    Create WRTTRAND data queue                          */
/*  15 February 2012                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CRTTDDTAQ                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/15/12  DAS  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    08/30/12  DAS  6.40a                                           */
/*      - Change 'Queue' to 'Queues'                                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB         Library to create queues in                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create WRTTRAND Data Queues')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) +
                          SPCVAL((*CURRENT *CURRENT)) MIN(1) +
                          PROMPT('Library for data queues')

