/*-------------------------------------------------------------------*/
/*  Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  P.O. Box 1957                                                    */
/*  Batavia, IL 60510                                                */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIRIMPORT   PIR - Import Directory Processing                    */
/*  17 October 2006                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: PIRIMPCL                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    - 02/07/14  MLB  6.50                                          */
/*        - Enh: Add 2 new cmds: *STAGE, *STAGETEST to be used with  */
/*          new global staging import library, PIRSTGF.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters                                                       */
/*                                                                   */
/*  &DELAYTIME   Delay time between run-time executions checking     */
/*               for files to import from directory.                 */
/*  &RUNTIMEENV  *PROD=Production library list.                      */
/*               *TEST=Test library list.                            */
/*               *STAGE=Production Staging Import library list.      (650 A) */
/*               *STAGETEST=Test Staging Import library list.        (650 A) */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Import Directory Processing')
             PARM       KWD(DELAYTIME) TYPE(*DEC) LEN(6 0) RANGE(60 +
                          999999) MIN(1) PROMPT('Delay time between +
                          checks')
             PARM       KWD(RUNTIMEENV) TYPE(*CHAR) LEN(10) +
                          RSTD(*YES) VALUES(*PROD *TEST *STAGE +
                          *STAGETEST) MIN(1) PROMPT('Run-time +
                          environment')                           /* (650 M) */
/*           PARM       KWD(RUNTIMEENV) TYPE(*CHAR) LEN(5) +      /* (650 D) */
/*                        RSTD(*YES) VALUES(*PROD *TEST) MIN(1) + /* (650 D) */
/*                        PROMPT('Run-time environment')          /* (650 D) */
