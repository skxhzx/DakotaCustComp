/*-------------------------------------------------------------------*/
/*  Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                           */
/*  West Chicago, IL  60185                                          */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIREXPORT2   PIR - Export FTP Processing #2                      */
/*  14 August 2008                                                   */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: PIREXPCL                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    08/14/08  MLB  5.20                                            */
/*      - Enh: Created.                                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters                                                       */
/*                                                                   */
/*  &WAREHOUSE   Warehouse number to process exports.                */
/*  &DELAYTIME   Delay time between run-time executions checking     */
/*               for files to export via FTP.                        */
/*  &RUNTIMEENV  *PROD=Production library list.                      */
/*               *TEST=Test library list.                            */
/*  &USRID       User ID that job will run under.                    */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('PIR Export FTP Processing 2')
             PARM       KWD(warehouse) TYPE(*DEC) LEN(3 0) RANGE(001 +
                          999) MIN(1) PROMPT('Warehouse number')
             PARM       KWD(DELAYTIME) TYPE(*DEC) LEN(6 0) RANGE(60 +
                          999999) MIN(1) PROMPT('Delay time in +
                          seconds')
             PARM       KWD(RUNTIMEENV) TYPE(*CHAR) LEN(10) +
                          RSTD(*YES) VALUES(*PROD *TEST *SAPPROD +
                          *SAPQA) MIN(1) +
                          PROMPT('Run-time environment')
             PARM       KWD(USRID) TYPE(*CHAR) LEN(10) +
                          MIN(1) PROMPT('User Id for +
                          job to run under')
