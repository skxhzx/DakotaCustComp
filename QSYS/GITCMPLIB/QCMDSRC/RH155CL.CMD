/*-------------------------------------------------------------------*/
/*  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                           */
/*  West Chicago, IL  60185                                          */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH155CL     FTP Export Closed Customer Orders                    */
/*  04 June  2007                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: RH155CL                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    06/04/07  MLB  5.10                                            */
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

             CMD        PROMPT('FTP Export Customer Orders')
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
