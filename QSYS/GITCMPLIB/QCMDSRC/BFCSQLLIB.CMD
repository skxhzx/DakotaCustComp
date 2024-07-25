/*********************************************************************/
/*                                                                   */
/*  BFCSQLLIB   GENERATE SQL SCRIPTS NOT FOUND                       */
/*  16 May 2016                                                      */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: BFCSQLLIB                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    05/16/16  DAS  7.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*     LIB     - Library                                             */
/*     RTNMSG  - Return message                                      */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Confirm SQL Scripts Exist')

             PARM       KWD(LIB) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Library')

             PARM       KWD(RTNMSG) TYPE(*CHAR) LEN(99) MIN(0) +
                          DSPINPUT(*NO)

