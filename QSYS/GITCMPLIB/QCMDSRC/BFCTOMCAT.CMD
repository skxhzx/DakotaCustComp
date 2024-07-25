/*********************************************************************/
/*                                                                   */
/*  BFCTOMCAT   Start/End Tomcat Servers                             */
/*  03 November 2011                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: BFCTOMCAT                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    11/03/11  DAS  6.40                                            */
/*      - Created                                                    */
/*    02/24/12  DAS  6.40a                                           */
/*      - Added PROD2 for MRC server.                                */
/*    03/22/12  DAS  6.40b                                           */
/*      - Changed descriptions                                       */
/*      - Remove Test option                                         */
/*    08/01/12  DAS  6.40b                                           */
/*      - Readded Test option for Trax testing.                      */
/*    02/23/13  DAS  6.50a                                           */
/*      - Added Test2 option for Dakota GUI testing.                 */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*     One parameter for each environment.                           */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Start/End Tomcat Servers')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          VALUES(*START *END) MIN(1) +
                          PROMPT('Start/End Server')

             PARM       KWD(PROD) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Webfacing/Trax +
                          (7070)')

             PARM       KWD(PROD2) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Dakota (7370)')

             PARM       KWD(TEST) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Webfacing/Trax +
                          Testing (7170)')

             PARM       KWD(TEST2) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Dakota Testing +
                          (7570)')

