/*********************************************************************/
/*                                                                   */
/*  CO          Customer Order Detail                                */
/*  29 August 2002                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: COCL                                 */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &ORD         Customer order number                               */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Customer Order Detail')

             PARM       KWD(ORD) TYPE(*DEC) LEN(15 5) RSTD(*NO) +
                          RANGE(1 9999999) MIN(1) +
                          PROMPT('Customer order number')

