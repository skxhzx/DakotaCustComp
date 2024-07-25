/*-------------------------------------------------------------------*/
/*  Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                           */
/*  West Chicago, IL  60185                                          */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CHKIFSOBJ   Check for IFS Object                                 */
/*  03 October 2006                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Command Processing Program: CHKIFSOBJ                            */
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
/*  &USER        User to send message to                             */
/*  &MSG         Message to send                                     */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Check for IFS Object')
             PARM       KWD(OBJ) TYPE(*CHAR) LEN(640) MIN(1) +
                          PROMPT('Object')
             PARM       KWD(AUT) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X) PROMPT('Authority')
