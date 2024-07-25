/*********************************************************************/
/*                                                                   */
/*  UT311     Move Vslot item and qty to empty base slot             */
/*  07 October 2011                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: UT311                                */
/*  Validity Checking Program:  None                                 */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    10/07/11  MLB  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Move Vslot to Base Slot')

             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')

