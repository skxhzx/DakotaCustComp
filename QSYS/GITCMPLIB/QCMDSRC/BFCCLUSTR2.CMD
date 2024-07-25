/*********************************************************************/
/*                                                                   */
/*  BFCCLUSTR2  Start/End Tomcat Cluster Servers - Development       */
/*  26 February 2016                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: BFCCLUSTR2                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    02/26/16  DAS  7.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*     CMD     - *START, *END                                        */
/*     SERVER  - Server code from file BFCGLOBALF/GLOTOMSRV          */
/*     START   - Starting node number                                */
/*     NBR     - Number of nodes to start/end                        */
/*     LOADBAL - Start/End Apache load balancer (Y,N)                */
/*     JOBQ    - Put on jobq (Y/N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Start/End Cluster Servers')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          VALUES(*START *END) MIN(1) +
                          PROMPT('Start/End Server')

             PARM       KWD(SERVER) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Server code')

             PARM       KWD(START) TYPE(*DEC) LEN(2 0) DFT(1) +
                          RANGE(0 20) +
                          PROMPT('Starting node number')

             PARM       KWD(NBR) TYPE(*DEC) LEN(2 0) DFT(1) +
                          RANGE(1 20) PROMPT('Number of nodes to +
                          start')

             PARM       KWD(LOADBAL) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Start/End +
                          Apache Load Balancer')

             PARM       KWD(JOBQ) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) PROMPT('Put on Jobq')

