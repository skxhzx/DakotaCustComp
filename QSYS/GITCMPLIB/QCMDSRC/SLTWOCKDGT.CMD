/*********************************************************************/
/*                                                                   */
/*  SLTWOCKDGT   Print List of All Slots Without Check Digit         */
/*  04 August 2004                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: SCD310CL                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/04/04  DAS  4.17                                            */
/*      - Created.                                                   */
/*    09/21/04  MLB  4.17a                                           */
/*      - Added new fields to command.                               */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*    &WHSE                  Warehouse number                        */
/*    &WHDP                  Warehouse department                    */
/*    &Slottype              Slot type O=Overflow,P=Pick,B=Both(417a)*/
/*    &Slotstat              Slot status *ALL or status code. (417a) */
/*    &RTN                   Return value                            */
/*    &DEVICE                Printer device                          */
/*    &FORMTYPE              Formtype                                */
/*    &HEAD                  Heading                           (417a)*/
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Print Slots W/O Check Digit')
             PARM       KWD(WHSE) TYPE(*CHAR) LEN(3) RANGE(001 999) +
                          PROMPT('Warehouse number')
             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) +
                          PROMPT('Warehouse department')
             PARM       KWD(SLOTTYPE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(B) VALUES(P O B) MIN(0) PROMPT('Slot +
                          type')                           /* (417a) */
             PARM       KWD(SLOTSTAT) TYPE(*CHAR) LEN(4) RSTD(*NO) +
                          DFT(*ALL) MIN(0) PROMPT('Slot type') /* +
                          (417a) */
             PARM       KWD(RTN) TYPE(*CHAR) LEN(8) DSPINPUT(*NO) +
                          PROMPT('Return value')
             PARM       KWD(DEVICE) TYPE(*CHAR) LEN(10) DFT(*JOB) +
                          PROMPT('Printer device')
             PARM       KWD(FORMTYPE) TYPE(*CHAR) LEN(10) DFT(*STD) +
                          PROMPT('Formtype')
             PARM       KWD(HEAD) TYPE(*CHAR) LEN(50) DSPINPUT(*NO)
