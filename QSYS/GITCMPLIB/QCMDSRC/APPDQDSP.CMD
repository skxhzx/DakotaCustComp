/*********************************************************************/
/*                                                                   */
/*  APPDQDSP  Display Android App data queues                        */
/*  01 February 2022                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: APPDQDSP                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    02/01/22  DAS  7.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &DTAQ        Data queue to clear                                 */
/*               IN  - APPDQIN                                       */
/*               OUT - APPDQOUT                                      */
/*  &TYPE        Information type (*ENTRIES,*DESC)                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Display Android App data queue')

             PARM       KWD(DTAQ) TYPE(*CHAR) LEN(3) RSTD(*YES) +
                          DFT(IN) VALUES(IN OUT) CHOICE(*VALUES) +
                          PROMPT('Data Queue')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ENTRIES) VALUES(*ENTRIES *DESC) +
                          PROMPT('Information type')
