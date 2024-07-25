/*-------------------------------------------------------------------*/
/*  Copyright (C) 2022 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  P.O. Box 1957                                                    */
/*  Batavia, IL 60510                                                */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH155CL2    FTP Export Closed Customer Orders - Alpha Order#     */
/*  07 April 2022                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: RH155CL2                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    04/07/22  MLB  7.60                                            */
/*      - Enh: Created.                                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters                                                       */
/*                                                                   */
/*  &PGM         Program to receive messages                         */
/*  &WHSE        Warehouse number                                    */
/*  &RTID        Route ID                                            */
/*  &RTE         Route Number                                        */
/*  &RTN         Return Code                                         */
/*  &MSGKEY      Message Key                                         */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('FTP Export Cust Orders Alpha')
             PARM       KWD(PGM) TYPE(*CHAR) LEN(10) MIN(1) +
                          PROMPT('Program to receive msgs')
             PARM       KWD(WHSE) TYPE(*DEC) LEN(3 0) RANGE(001 999) +
                          MIN(1) PROMPT('Warehouse number')
             PARM       KWD(RTID) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route ID')
             PARM       KWD(RTE) TYPE(*CHAR) LEN(5) MIN(1) +
                          PROMPT('Route number')
             PARM       KWD(RTN) TYPE(*CHAR) LEN(8) +
                          PROMPT('Return code')
             PARM       KWD(MSGKEY) TYPE(*CHAR) LEN(4) +
                          PROMPT('Message key')
