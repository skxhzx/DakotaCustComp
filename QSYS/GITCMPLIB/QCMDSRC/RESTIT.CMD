/*********************************************************************/
/*                                                                   */
/*  RESTIT      Restore library from save file in transfer library   */
/*  23 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: RESTIT                               */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIB2RST     Library to restore                                  */
/*  &TFRLIB      Transfer library                                    */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Restore Lib from Transfer Lib')

             PARM       KWD(LIB2RST) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Library to restore')

             PARM       KWD(TFRLIB) TYPE(*NAME) LEN(10) +
                          DFT(PIRTFR) PROMPT('Transfer library')

