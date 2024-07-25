/*********************************************************************/
/*                                                                   */
/*  TSTEXPERR      TEST PEXPERR                                      */
/*  28 NOVEMBER 2022                                                 */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: PEXPERR                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*  11/28/22  KDE  7.60                                              */
/*    - Created.                                                     */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('CALL PEXPERR')

             PARM       KWD(PSESSID) TYPE(*CHAR) LEN(40) +
                          PROMPT('Session ID (Timestamp)')
             PARM       KWD(PUSER) TYPE(*CHAR) LEN(10) +
                          PROMPT('User')
             PARM       KWD(PPGM) TYPE(*CHAR) LEN(60) +
                          PROMPT('Program')
             PARM       KWD(PWHSE) TYPE(*dec) LEN(3 0) +
                          PROMPT('Warehouse')
             PARM       KWD(PBATID) TYPE(*CHAR) LEN(11) +
                          PROMPT('Batch Id')
             PARM       KWD(PBATTYPE) TYPE(*CHAR) LEN(10) +
                          PROMPT('Batch Type')
             PARM       KWD(PSUBJECT) TYPE(*CHAR) LEN(100) +
                          PROMPT('Email Subject')
             PARM       KWD(PERROSB) TYPE(*CHAR) LEN(500) +
                          PROMPT('Error Message Batch')
             PARM       KWD(PERRMSG) TYPE(*CHAR) LEN(99) RTNVAL(*NO) +
                          PROMPT('Returned Error Message')
