/*********************************************************************/
/*                                                                   */
/*  RH155S       Front end to RH155S                                 */
/*  26 January 2016                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: RH155S                               */
/*  Validity Checking Program:  None                                 */
/*********************************************************************/
/*  Revisions:                                                       */
/*  01/26/16  MLB  7.00                                              */
/*    - Created.                                                     */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &CMD         Command (*ALL *HDRDTL TALL THDRDTL)                 */
/*  &WHSE        Warehouse                                           */
/*  &RTID        Route ID                                            */
/*  &RTE         Route number                                        */
/*  &RTN         Return code                                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Stage-Export Closed Route')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*ALL) VALUES(*ALL *HDRDLT TALL +
                          THDRDTL) MIN(0) PROMPT('Command')

             PARM       KWD(WHSE) TYPE(*DEC) LEN(3 0) MIN(0) +
                          PROMPT('Warehouse')

             PARM       KWD(RTID) TYPE(*CHAR) LEN(5) MIN(0) +
                          PROMPT('Route ID')

             PARM       KWD(RTE) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route Number')

             PARM       KWD(RTN) TYPE(*CHAR) LEN(8) MIN(1) +
                          PROMPT('Return Code')

