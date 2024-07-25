/*********************************************************************/
/*                                                                   */
/*  POD310       View POD log                                        */
/*  05 September 2008                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: POD310                               */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &WHSE        Warehouse                                           */
/*  &RTID        Route id                                            */
/*  &RTE         Route code                                          */
/*  &STOP        Stop                                                */
/*  &ORD         Order Id                                            */
/*  &CORD        Customer order number                               */
/*  &DATE        From date (MMDDYY)                                  */
/*  &ERRONLY     Display only errors (Y,N)                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('View POD Log')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3) MIN(1) +
                          PROMPT('Warehouse')

             PARM       KWD(RTID) TYPE(*CHAR) LEN(5) DFT(*ALL) +
                          MIN(0) PROMPT('Route Id')

             PARM       KWD(RTE) TYPE(*CHAR) LEN(5) DFT(*ALL) +
                          PROMPT('Route')

             PARM       KWD(STOP) TYPE(*DEC) LEN(2) DFT(0) +
                          CHOICE('0-99, 0=All') PROMPT('Stop')

             PARM       KWD(ORD) TYPE(*DEC) LEN(7) DFT(0) +
                          CHOICE('0-9999999, 0=All') PROMPT('Order Id')

             PARM       KWD(CORD) TYPE(*DEC) LEN(7) DFT(0) +
                          CHOICE('0-9999999, 0=All') +
                          PROMPT('Customer Order Number')

             PARM       KWD(DATE) TYPE(*DEC) LEN(6) DFT(0) +
                          CHOICE('MMDDYY, 0=All') PROMPT('From Date')

             PARM       KWD(ERRONLY) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) PROMPT('Display only +
                          errors')

