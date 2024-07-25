/*********************************************************************/
/*                                                                   */
/*  UPDSUM007      LETDOWN/REPLEN REPRT GUI                          */
/*  16 July 2019                                                     */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: UPDSUM007                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*  07/16/19  KDE  7.30                                              */
/*    - Created.                                                     */
/*      Used in MRCRPTSCH to submite work file generation for        */
/*      so Letdown Report can be scheduled                           */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create SUM007 Data')

             PARM       KWD(ERRMSG) TYPE(*CHAR) LEN(99) RTNVAL(*NO) +
                          PROMPT('Returned Error Message')
             PARM       KWD(SESSID) TYPE(*CHAR) LEN(40) +
                          PROMPT('Session ID (Timestamp)')
             PARM       KWD(Pwhse) TYPE(*dec) LEN(3 0) +
                          PROMPT('Warehouse')
             PARM       KWD(PDEPT) TYPE(*CHAR) LEN(5) +
                          PROMPT('Department')
             PARM       KWD(PTNUMRPLNS) TYPE(*DEC) LEN(3 0) +
                          PROMPT('# of Replens')
             PARM       KWD(PTFRMAISL) TYPE(*CHAR) LEN(3) +
                          PROMPT('From Slot Aisle')
             PARM       KWD(PTTOAISL) TYPE(*CHAR) LEN(3) PROMPT('To +
                          Slot Aisle')
             PARM       KWD(PTFRMLOC) TYPE(*DEC) LEN(3 0) +
                          PROMPT('From Location')
             PARM       KWD(PTTOLOC) TYPE(*DEC) LEN(3 0) +
                          PROMPT('From Location')
             PARM       KWD(PTCREW) TYPE(*CHAR) LEN(6) PROMPT('Crew')
             PARM       KWD(PTSHFT) TYPE(*CHAR) LEN(6) PROMPT('Shift')
             PARM       KWD(PTTASK) TYPE(*CHAR) LEN(6) PROMPT('Task')
             PARM       KWD(PTFRMDATE) TYPE(*DEC) LEN(8 0) +
                          PROMPT('From Task Date')
             PARM       KWD(PTTODATE) TYPE(*DEC) LEN(8 0) PROMPT('To +
                          Task Date')
