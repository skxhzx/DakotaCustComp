/*********************************************************************/
/*                                                                   */
/*  SAVEIT      Save library to save file in transfer library        */
/*  19 May 2000                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: SAVEIT                               */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/23/00  DAS  4.14                                            */
/*      - Changed default to PIRTFR.                                 */
/*                                                                   */
/*    11/02/01  DAS  4.16                                            */
/*      - Added &TGTRLS parameter                                    */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB2SAV     Library to save                                     */
/*  &TFRLIB      Transfer library                                    */
/*  &TGTRLS      Target release                                      */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Save Lib to Transfer Lib')

             PARM       KWD(LIB2SAV) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Library to save')

             PARM       KWD(TFRLIB) TYPE(*NAME) LEN(10) +
                          DFT(PIRTFR) PROMPT('Transfer library')

             PARM       KWD(TGTRLS) TYPE(*CHAR) LEN(8) DFT(*CURRENT) +
                          PROMPT('Target release')

