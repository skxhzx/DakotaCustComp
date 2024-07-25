/*********************************************************************/
/*                                                                   */
/*  LT330        Front end to LT330                                  */
/*  21 August 2009                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LT330                                */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command (*DISPLAY)                                  */
/*  &WHSE        Warehouse                                           */
/*  &PO          PO                                                  */
/*  &ITEM        Item                                                */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Recall Listing')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*DISPLAY) VALUES(*DISPLAY) MIN(0) +
                          PMTCTL(*PMTRQS) PROMPT('Command')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(0) +
                          PMTCTL(*PMTRQS) PROMPT('Warehouse')

             PARM       KWD(PO) TYPE(*CHAR) LEN(9) MIN(0) +
                          PROMPT('P.O.')

             PARM       KWD(ITEM) TYPE(*CHAR) LEN(15) MIN(0) +
                          PROMPT('Item')

