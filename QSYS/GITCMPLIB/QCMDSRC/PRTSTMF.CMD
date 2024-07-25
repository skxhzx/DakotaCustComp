/*********************************************************************/
/*                                                                   */
/*  PRTSTMF      Print Stream File                                   */
/*                                                                   */
/*  Written by Scott Klement, August 9, 2005                         */
/*                                                                   */
/*  Command Processing Program: PRTSTMF                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    03/06/13  DAS  6.50                                            */
/*      - Created.                                                   */
/*    09/29/21  DAS  7.50                                            */
/*      - Added parm for drawer to use                               */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &STMF        Stream file to print                                */
/*  &OUTQ        Output queue                                        */
/*  &DRW         Output Drawer                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Print Raw Stream File')

             PARM       KWD(STMF) TYPE(*CHAR) LEN(256) MIN(1) +
                          VARY(*YES *INT2) CHOICE('IFS Path') +
                          PROMPT('Stream file to print')

             PARM       KWD(OUTQ) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Output Queue to print on')

             PARM       KWD(DRW) TYPE(*CHAR) LEN(7) MIN(0) +
                          PROMPT('Output Drawer')

