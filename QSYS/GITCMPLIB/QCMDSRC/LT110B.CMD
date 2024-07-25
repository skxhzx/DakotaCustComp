/*********************************************************************/
/*                                                                   */
/*  LT110B        Clear Priority Replenishment work file             */
/*  10 October 2010                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: LT110B                               */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*   720   KDE   ADD REPLEN TYPE AS PARM                             */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &WHDP        Department                                          */
/*  &RTYPE       REPLENISHMENT TYPE                                  */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear Priority Replen File')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) MIN(0) +
                          PROMPT('Department')

/* 720 A */  PARM       KWD(RTYPE) TYPE(*CHAR) LEN(1) MIN(0) +
/* 720 A */               PROMPT('Replenishment Type')

