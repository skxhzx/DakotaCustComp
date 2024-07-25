/*********************************************************************/
/*                                                                   */
/*  MRCRPTSCH   PROCESS ON-DEMAND MRC REPORT                         */
/*  15 APRIL    2020                                                 */
/*  KENNETH ELDER                                                    */
/*                                                                   */
/*  CALLS MRCRPTSCH TO PROCESS MRC REPORT                            */
/*  REVISIONS:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  PARAMETERS                                                       */
/*  &WHSE        WAREHOUSE                                           */
/*  &RPTNAM      REPORT NAME                                         */
/*  &URL         MRC URL                                             */
/*  &EMAIL       EMAILS IF USED                                      */
/*  &PRINTER     PRINTER IF USED                                     */
/*  &ORIENT      PAGE ORIENTATION                                    */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('PROCESS MRC REPORT')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3 0) +
                          PROMPT('WAREHOUSE:')

             PARM       KWD(RPTNAM) TYPE(*CHAR) LEN(20) +
                          PROMPT('REPORT NAME')

             PARM       KWD(URL) TYPE(*CHAR) LEN(3000) +
                          PROMPT('MRC URL')

             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(1000) +
                          PROMPT('EMAIL(S) IF INCLUDED')

             PARM       KWD(PRINTER) TYPE(*CHAR) LEN(10) +
                          PROMPT('PRINTER IF INCLUDED')

             PARM       KWD(ORIENT) TYPE(*CHAR) LEN(1) PROMPT('PAGE +
                          ORIENTATION')
