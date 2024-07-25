/*********************************************************************/
/*                                                                   */
/*  LT310        Front end to LT310                                  */
/*  21 August 2009                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LT310                                */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command (*DISPLAY, *PRINT)                          */
/*  &WHSE        Warehouse                                           */
/*  &WHDP        Department                                          */
/*  &DISP        Slot display                                        */
/*  &ITEM        Item                                                */
/*  &DEV         Printer device                                      */
/*  &FORM        Printer form                                        */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Active License Listing')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*DISPLAY) VALUES(*DISPLAY *SPECIAL) +
                          MIN(0) PMTCTL(*PMTRQS) PROMPT('Command')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(0) +
                          PMTCTL(*PMTRQS) PROMPT('Warehouse')

             PARM       KWD(WHDP) TYPE(*CHAR) LEN(5) MIN(0) +
                          PMTCTL(*PMTRQS) PROMPT('Department')

             PARM       KWD(DISP) TYPE(*CHAR) LEN(12) SPCVAL((RCV +
                          'RCV%') (STG 'STG%') (OSS 'OSS%') (USR +
                          'USR%')) MIN(1) PROMPT('Slot display')

