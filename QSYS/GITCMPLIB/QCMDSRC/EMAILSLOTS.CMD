/*-------------------------------------------------------------------*/
/*  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                           */
/*  West Chicago, IL  60185                                          */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EMAILSLOTS   Email CSV file of slots                             */
/*  23 March 2007                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: EMAILSLOTS                           */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*   - Source code for this command courtesy of Scott Klement's      */
/*     Working with the IFS in RPG IV e-book.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Parameters                                                       */
/*  &DEPT        Warehouse department                                */
/*  &EMAIL       Email address                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Email CSV File of Slots')
             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(32) RSTD(*NO) +
                          MIN(1) PROMPT('full bfcsoftware email +
                          address')
             PARM       KWD(DEPT) TYPE(*CHAR) LEN(5) DFT(*ALL) +
                          PROMPT('Department code')
