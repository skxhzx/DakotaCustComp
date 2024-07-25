/*********************************************************************/
/*                                                                   */
/*  UPDSUM012      EMPTY PICK SLOT W/OVERFLOW                        */
/*  29 MAY 2020                                                      */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: UPDSUM012                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*  05/29/20  KDE  7.40                                              */
/*    - Created.                                                     */
/*      Used in MRCRPTSCH to submit work file generation for         */
/*      Empty Pick Slot w/Overflow Quantity                          */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create SUM012 Data')

             PARM       KWD(ERRMSG) TYPE(*CHAR) LEN(99) RTNVAL(*NO) +
                          PROMPT('Returned Error Message')
             PARM       KWD(SESSID) TYPE(*CHAR) LEN(40) +
                          PROMPT('Session ID (Timestamp)')
             PARM       KWD(Pwhse) TYPE(*dec) LEN(3 0) +
                          PROMPT('Warehouse')
             PARM       KWD(PWHDP) TYPE(*CHAR) LEN(5) +
                          PROMPT('Department')
             PARM       KWD(PFAISL) TYPE(*CHAR) LEN(3) +
                          PROMPT('From Aisle')
             PARM       KWD(PTAISL) TYPE(*CHAR) LEN(3) +
                          PROMPT('To Aisle')
