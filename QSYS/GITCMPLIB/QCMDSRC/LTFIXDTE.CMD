/*********************************************************************/
/*                                                                   */
/*  LTFIXDTE     Fix slot date from LICACTIVE file                   */
/*  19 May 2009                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LTFIXDTECL                           */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &WHDP        Department                                          */
/*  &DISP        Slot display                                        */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Fix Slot Dates from LICACTIVE')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) MIN(0) +
                          PROMPT('Department')

             PARM       KWD(DISP) TYPE(*CHAR) LEN(12) MIN(0) +
                          PROMPT('Slot display')

