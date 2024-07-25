/*********************************************************************/
/*                                                                   */
/*  SLTWCKDGT   Print List of All Slots With Check Digit             */
/*  04 August 2004                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: SCD320CL                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/04/04  DAS  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*    &WHSE                  Warehouse number                        */
/*    &WHDP                  Warehouse department                    */
/*    &RTN                   Return value                            */
/*    &DEVICE                Printer device                          */
/*    &FORMTYPE              Formtype                                */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Print Slots With Check Digit')
             PARM       KWD(WHSE) TYPE(*CHAR) LEN(3) RANGE(001 999) +
                          PROMPT('Warehouse number')
             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) +
                          PROMPT('Warehouse department')
             PARM       KWD(RTN) TYPE(*CHAR) LEN(8) DSPINPUT(*NO) +
                          PROMPT('Return value')
             PARM       KWD(DEVICE) TYPE(*CHAR) LEN(10) DFT(*JOB) +
                          PROMPT('Printer device')
             PARM       KWD(FORMTYPE) TYPE(*CHAR) LEN(10) DFT(*STD) +
                          PROMPT('Formtype')
