/*********************************************************************/
/*                                                                   */
/*  OR605       Truck Build - Traffic Cop                            */
/*  24 July 2002                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: OR605CL                              */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Truck Build - Traffic Cop')

             PARM       KWD(PCMD) TYPE(*CHAR) LEN(8) PROMPT('Command +
                          #1')
             PARM       KWD(PCMD2) TYPE(*CHAR) LEN(8) PROMPT('Command +
                          #2')
             PARM       KWD(PTYPE) TYPE(*CHAR) LEN(8) PROMPT('Processing +
                          type')
             PARM       KWD(PJTYP) TYPE(*CHAR) LEN(1) +
                          PROMPT('Process mode 0=Batch, 1=Inter')
             PARM       KWD(Pwhs) TYPE(*dec) LEN(15 5) +
                          PROMPT('Warehouse')
             PARM       KWD(Pbat) TYPE(*dec) LEN(7 0) +
                          PROMPT('Batch number')
             PARM       KWD(Pstat) TYPE(*CHAR) LEN(1) +
                          PROMPT('Status')
             PARM       KWD(Prtid) TYPE(*CHAR) LEN(5) +
                          PROMPT('Route Id')
             PARM       KWD(Pord) TYPE(*dec) LEN(7 0) +
                          PROMPT('Order number')
             PARM       KWD(Prwhs) TYPE(*dec) LEN(3 0) +
                          PROMPT('Transfer warehouse')
             PARM       KWD(Ptrte) TYPE(*CHAR) LEN(5) +
                          PROMPT('Transfer Route')
             PARM       KWD(Prtn) TYPE(*CHAR) LEN(8) +
                          PROMPT('Return coder')
             PARM       KWD(Pmsg) TYPE(*CHAR) LEN(4) +
                          PROMPT('Message number')
             PARM       KWD(Pprg) TYPE(*CHAR) LEN(10) +
                          PROMPT('Calling program')

