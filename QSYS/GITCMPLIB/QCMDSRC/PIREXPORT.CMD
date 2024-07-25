/*-------------------------------------------------------------------*/
/*  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                           */
/*  West Chicago, IL  60185                                          */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIREXPORT   PIR - Export FTP Processing                          */
/*  10 April 2007                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: PIREXP1CL                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    04/10/07  MLB  5.10                                            */
/*      - Enh: Created.                                              */
/*                                                                   */
/*    07/28/08  MLB  5.20                                            */
/*      - Enh: Revised program to add &USRID parm to cmd.            */
/*        User id needed to assign job description to submitted job. */
/*    08/14/08  MLB  5.20a                                           */
/*      - Enh: Revised cmd to call new CPP, PIREXP1CL.  This new     */
/*        CPP has all the SMBJOB processing in it. PIREXPCL job      */
/*        will do the actual export processing from Dakota.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's                                */
/*                                                                   */
/*    03/26/07  MLB  PAK                                             */
/*      - Revised cmd to add two new &runtimeenv parm options.       */
/*        *SAPQA   - SAP testing environment                         */
/*        *SAPPROD - SAP production environment                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters                                                       */
/*                                                                   */
/*  &WAREHOUSE   Warehouse number to process exports.                */
/*  &DELAYTIME   Delay time between run-time executions checking     */
/*               for files to export via FTP.                        */
/*  &RUNTIMEENV  *PROD=Production library list.                      */
/*               *TEST=Test library list.                            */
/*  &USRID       User ID that job will run under.            (520 A) */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('PIR Export FTP Processing')
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
                          job to run under')                      /* (520 A) */
