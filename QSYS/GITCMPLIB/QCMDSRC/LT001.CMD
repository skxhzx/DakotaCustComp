/*********************************************************************/
/*                                                                   */
/*  LT001        Sync LICACTIVE with slots                           */
/*  22 February 2009                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LT001CL                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &ACTION      Action code                                         */
/*  &WHSE        Warehouse                                           */
/*  &WHDP        Department                                          */
/*  &DISP        Slot display                                        */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Sync LICACTIVE with Slots')

             PARM       KWD(ACTION) TYPE(*CHAR) LEN(3) RSTD(*YES) +
                          VALUES(FIX SI SU) MIN(1) PROMPT('Action +
                          code')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) MIN(0) +
                          PROMPT('Department')

             PARM       KWD(DISP) TYPE(*CHAR) LEN(12) MIN(0) +
                          PROMPT('Slot display')

