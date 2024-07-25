/*********************************************************************/
/*                                                                   */
/*  SFC100      Route summary by stop                                */
/*  14 September 2000                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: SFC100CL                             */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse number                                    */
/*  &RTID        Route id                                            */
/*  &RTN         Return code                                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Route Detail by Stop')

             PARM       KWD(WHSE) TYPE(*CHAR) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(RTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route id')

             PARM       KWD(RTN) TYPE(*NAME) LEN(8) CONSTANT(X) MIN(1)

