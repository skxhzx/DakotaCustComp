/*********************************************************************/
/*                                                                   */
/*  COOLTRAXQ   Start Cooltrax program  - QSH                        */
/*  05 November 2013                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: COOLTRAXQ                            */
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

             PARM       KWD(MIN) TYPE(*CHAR) LEN(4) DFT(1440) +
                          PROMPT('Sleep time in minutes')

             PARM       KWD(OPTT) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y) SPCVAL((Y T) (N ' ')) +
                          MIN(0) PROMPT('Download temperatures')

             PARM       KWD(OPTA) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y) SPCVAL((Y A) (N ' ')) +
                          MIN(0) PROMPT('Download asset reefer data')

             PARM       KWD(OPTC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y) SPCVAL((Y C) (N ' ')) +
                          MIN(0) PROMPT('Download contact point data')

             PARM       KWD(OPTL) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y) SPCVAL((Y L) (N ' ')) +
                          MIN(0) PROMPT('Download location data')

             PARM       KWD(OPTG) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y) SPCVAL((Y G) (N ' ')) +
                          MIN(0) PROMPT('Download asset list data')

             PARM       KWD(OPTR) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y) SPCVAL((Y R) (N ' ')) +
                          MIN(0) PROMPT('Download reefer alarm data')

