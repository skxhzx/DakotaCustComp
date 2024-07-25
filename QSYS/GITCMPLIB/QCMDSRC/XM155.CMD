/*********************************************************************/
/*                                                                   */
/*  XM155        Create POD XML files                                */
/*  05 September 2008                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: XM155                                */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &RTID        Route id                                            */
/*  &RTE         Route code                                          */
/*  &RTN         Return                                              */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Run XM155')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(RTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')

             PARM       KWD(RTE) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route')

             PARM       KWD(RTN) TYPE(*CHAR) LEN(8) PROMPT('Return')

