/*********************************************************************/
/*                                                                   */
/*  APTDSPDTAQ   Display APTDTAQ data queue                          */
/*  November 1, 2011                                                 */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Command Processing Program: APTDSPDTAQ                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    11/01/11  RTR  6.40                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &TYPE        Information type (*ENTRIES,*DESC)                   */
/*  &LIB         Data queue library                                  */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Display APTDTAQ Data Queue')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ENTRIES) VALUES(*ENTRIES *DESC) +
                          PROMPT('Information type')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data queue library')

