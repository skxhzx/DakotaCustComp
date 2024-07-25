/*********************************************************************/
/*                                                                   */
/*  BFCTOMCAT2  Start/End Tomcat Servers - Development               */
/*  03 November 2011                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: BFCTOMCAT2                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    11/03/11  DAS  6.40                                            */
/*      - Created                                                    */
/*    02/24/12  DAS  6.40a                                           */
/*      - Added PROD2.                                               */
/*      - Moved DEV64 and changed its port.                          */
/*    03/22/12  DAS  6.40b                                           */
/*      - Changed description for PROD2                              */
/*    02/23/13  DAS  6.50a                                           */
/*      - Revised to enter the server code.                          */
/*        This code must be in file BFCGLOBALF/GLOTOMSRV             */
/*      - Old code removed for clarity.                              */
/*        See BFCTOMC2.1 for old code.                               */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*     CMD     - *START, *END                                        */
/*     SRVCODE - Server code from file BFCGLOBALF/GLOTOMSRV          */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Start/End Tomcat Servers')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          VALUES(*START *END) MIN(1) +
                          PROMPT('Start/End Server')

             PARM       KWD(SERVER) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Server code')

