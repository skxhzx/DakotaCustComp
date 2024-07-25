/*********************************************************************/
/*                                                                   */
/*  COOLTRAX    Start Cooltrax program                               */
/*  05 November 2013                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: COOLTRAX                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    11/05/13  DAS  6.50                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &TYPE        Type (PROD, QA)                                     */
/*  &MIN         Minutes                                             */
/*  &OPT*        Options                                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Start Cooltrax Program')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(QA) VALUES(QA PROD) MIN(0) +
                          PROMPT('Data type')

             PARM       KWD(MIN) TYPE(*DEC) LEN(4 0) DFT(1440) +
                          RANGE(5 1440) PROMPT('Sleep time in minutes')

             PARM       KWD(OPTT) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) MIN(0) +
                          PROMPT('Download temperatures')

             PARM       KWD(OPTA) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) MIN(0) +
                          PROMPT('Download asset reefer data')

             PARM       KWD(OPTC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N)  MIN(0) +
                          PROMPT('Download contact point data')

             PARM       KWD(OPTL) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N)  MIN(0) +
                          PROMPT('Download location data')

             PARM       KWD(OPTG) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N)  MIN(0) +
                          PROMPT('Download asset list data')

             PARM       KWD(OPTR) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) MIN(0) +
                          PROMPT('Download reefer alarm data')

