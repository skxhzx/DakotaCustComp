/*********************************************************************/
/*                                                                   */
/*  SAPDSPDTAQ    Display SQP Qty In/Out data queues                 */
/*  30 January 2020                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DSPSAPDTAQ                           */
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
/*  &TYPE        Data queue type to create (*IN, *OUT)               */
/*  &TYPE2       Information type (*ENTRIES,*DESC)                   */
/*  &LIB         Library to create queues in                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Display SAP Qty Data Queues')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*OUT) VALUES(*IN *OUT) PROMPT('Data +
                          queue to display')

             PARM       KWD(TYPE2) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ENTRIES) VALUES(*ENTRIES *DESC) +
                          PROMPT('Information type')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data queue library')

