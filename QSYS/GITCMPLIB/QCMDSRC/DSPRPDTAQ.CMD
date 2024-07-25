/*********************************************************************/
/*                                                                   */
/*  DSPRPDTAQ    Display REDPDTAQ data queue                         */
/*  21 July 2004                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: DSPRPDTAQ                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    07/21/04  DAS  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &TYPE        Information type (*ENTRIES,*DESC)                   */
/*  &LIB         Data queue library                                  */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Display REDPDTAQ Data Queue')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ENTRIES) VALUES(*ENTRIES *DESC) +
                          PROMPT('Information type')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Data queue library')

