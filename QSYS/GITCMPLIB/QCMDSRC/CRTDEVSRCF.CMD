/*********************************************************************/
/*                                                                   */
/*  CRTDEVSRCF  Create source physical files for library             */
/*  20 September 1999                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: CRTDEVSRCF                           */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*                                                                   */
/*    06/21/07  DAS  5.10a                                           */
/*      - Added qcopysrc.                                            */
/*                                                                   */
/*    03/26/15  DAS  6.50a                                           */
/*      - Removed E/L/R files                                        */
/*      - Added SQL                                                  */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &LIBNAME     Library name                                        */
/*  &QCLSRC      Create QCLSRC (Y,N)                                 */
/*  &QCMDSRC     Create QCMDSRC (Y,N)                                */
/*  &QCOPYSRC    Create QCOPYSRC (Y,N)                               */
/*  &QDDSFILES   Create QDDSFILES (Y,N)                              */
/*  &QDDSSRC     Create QDDSSRC (Y,N)                                */
/*  &QMENUSRC    Create QMENUSRC (Y,N)                               */
/*  &QMSGSRC     Create QMSGSRC (Y,N)                                */
/*  &QRPGSRC     Create QRPGSRC (Y,N)                                */
/*  &QRPGLESRC   Create QRPGLESRC (Y,N)                              */
/*  &QSQLSRC     Create QSQLSRC (Y,N)                                */
/*  &QTESTSRC    Create QTESTSRC (Y,N)                               */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Create Development Library')


             PARM       KWD(LIBNAME) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Library Name')

             PARM       KWD(QCLSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QCLSRC +
                          for Base')

             PARM       KWD(QCMDSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QCMDSRC +
                          for Base')

             PARM       KWD(QCOPYSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QCOPYSRC')

             PARM       KWD(QDDSFILES) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QDDSFILES +
                          for Base')

             PARM       KWD(QDDSSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QDDSSRC +
                          for Base')

             PARM       KWD(QMENUSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QMENUSRC +
                          for Base')

             PARM       KWD(QMSGSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QMSGSRC +
                          for Base')

             PARM       KWD(QRPGSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QRPGSRC +
                          for Base')

             PARM       KWD(QRPGLESRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QRPGLESRC +
                          for Base')

             PARM       KWD(QSQLSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create QSQLSRC +
                          for Base')

             PARM       KWD(QTESTSRC) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) PROMPT('Create +
                          QTESTSRC for 900 pgms')

             PARM       KWD(JOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('Place on JOBQ')

