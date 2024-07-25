/*********************************************************************/
/*                                                                   */
/*  CLRCWGT     Truck Build - Clear Catchweight exported flag        */
/*  28 April 2005                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: CHKIUSE                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Truck Build - Clear CWgt Flag')

             PARM       KWD(PCMD) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          VALUES(*CLRCWGT) MIN(1) PROMPT('Command #1')
             PARM       KWD(PWHSE) TYPE(*DEC) LEN(3 0) MIN(1) +
                          PROMPT('Warehouse')
             PARM       KWD(PRTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Id')
             PARM       KWD(PRTN) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          VALUES('        ') DSPINPUT(*NO) +
                          CHOICE(*NONE) PROMPT(*NONE)

