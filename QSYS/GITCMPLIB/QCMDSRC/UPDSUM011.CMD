/*********************************************************************/
/*                                                                   */
/*  UPDSUM011      DAILY SELECTION LABEL REPORT                      */
/*  11 Dec 2019                                                     */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: UPDSUM011                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*  12/11/19  KDE  7.30                                              */
/*    - Created.                                                     */
/*      Used in MRCRPTSCH to submit work file generation for         */
/*      Daily Selection Label Report when Scheduled                  */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create SUM011 Data')

             PARM       KWD(ERRMSG) TYPE(*CHAR) LEN(99) RTNVAL(*NO) +
                          PROMPT('Returned Error Message')
             PARM       KWD(SESSID) TYPE(*CHAR) LEN(40) +
                          PROMPT('Session ID (Timestamp)')
             PARM       KWD(Pwhse) TYPE(*dec) LEN(3 0) +
                          PROMPT('Warehouse')
             PARM       KWD(PTRANNUM) TYPE(*DEC) LEN(7 0) +
                          PROMPT('Trans#')
             PARM       KWD(PTRTEID) TYPE(*CHAR) LEN(5) +
                          PROMPT('Route Id')
             PARM       KWD(PTPALLID) TYPE(*DEC) LEN(7 0) +
                          PROMPT('Pallet Id')
             PARM       KWD(PTEMPLIST) TYPE(*CHAR) LEN(500) +
                          PROMPT('Employee List')
             PARM       KWD(PTRTNLIST) TYPE(*CHAR) LEN(196) +
                          PROMPT('Return List')
             PARM       KWD(PTFDTETIM) TYPE(*CHAR) LEN(14) +
                          PROMPT('From Date/Time')
             PARM       KWD(PTTDTETIM) TYPE(*CHAR) LEN(14) +
                          PROMPT('To Date/Time')
             PARM       KWD(PTRFVOICE) TYPE(*CHAR) LEN(1) +
                          PROMPT('RF/Voice B/Y/N')
             PARM       KWD(PTUPCE) TYPE(*CHAR) LEN(1) +
                          PROMPT('RF/Voice B/Y/N')
             PARM       KWD(PTVOERRORS) TYPE(*CHAR) LEN(1) +
                          PROMPT('RF/Voice B/Y/N')
             PARM       KWD(PTITEM) TYPE(*CHAR) LEN(15) +
                          PROMPT('Item')
