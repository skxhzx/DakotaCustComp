/*********************************************************************/
/*                                                                   */
/*  TSTTR842     Test TR842                                          */
/*  08 December 2017                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: TSTTR842                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Test TR842')

             PARM       KWD(FILE) TYPE(*CHAR) LEN(30) MIN(1) +
                          CASE(*MIXED) PROMPT('XML file name')

             PARM       KWD(PATH) TYPE(*CHAR) LEN(30) MIN(1) +
                          CASE(*MIXED) PROMPT('Path for XML file')

             PARM       KWD(COMMAND) TYPE(*CHAR) LEN(30) +
                          DFT('postCompletedRoute') SPCVAL((CMPRTE +
                          'PostCompletedRoute') (CMPSTP +
                          'PostCompletedStop') (STRRTE +
                          'sendRouteStart') (STRSTP +
                          'sendStopStart')) CASE(*MIXED) +
                          PROMPT('Command')

