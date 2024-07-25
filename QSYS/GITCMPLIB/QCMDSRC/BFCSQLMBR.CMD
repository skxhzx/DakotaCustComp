/*********************************************************************/
/*                                                                   */
/*  BFCSQLMBR   Run SQL script converting PIRSQL to cccSQL           */
/*  11 May 2016                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: BFCSQLMBR                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    05/11/16  DAS  7.00                                            */
/*      - Created                                                    */
/*    01/03/23  DAS  7.60a                                           */
/*      - Added optional parameter NEWLIB                            */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*     LIB     - Library                                             */
/*     SRCFILE - Source file                                         */
/*     MBRNAME - Member name                                         */
/*     MBRTYPE - Member type                                         */
/*     NEWLIB  - New library                                         */
/*     RTNMSG  - Return message                                      */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Run SQL - Cvt PIRSQL to cccSQL')

             PARM       KWD(LIB) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Library')

             PARM       KWD(SRCFILE) TYPE(*CHAR) LEN(10) +
                          DFT(QSQLSRC) PROMPT('Source file')

             PARM       KWD(MBRNAME) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Member name')

             PARM       KWD(MBRTYPE) TYPE(*CHAR) LEN(10) DFT(TXT) +
                          MIN(0) PROMPT('Member type')

             PARM       KWD(NEWLIB) TYPE(*CHAR) LEN(10) +
                          MIN(0) PROMPT('New library')

             PARM       KWD(RTNMSG) TYPE(*CHAR) LEN(99) MIN(0) +
                          DSPINPUT(*NO)

