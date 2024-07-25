/*********************************************************************/
/*                                                                   */
/*  SAPCLRDTAQ    Clear SAP Qty In/Out data queues                   */
/*  30 January 2020                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CLRSAPDTAQ                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    01/30/20  DAS  7.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &TYPE        Data queue type to create (*IN, *OUT, *BOTH)        */
/*  &LIB         Library to create queues in                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear SQP Qty Data Queues')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          VALUES(*IN *OUT *BOTH) MIN(1) +
                          PROMPT('Data queue to clear')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data queue library')

