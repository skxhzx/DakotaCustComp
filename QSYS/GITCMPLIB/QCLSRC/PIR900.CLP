/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIR900 Gateway to TEST 900 system                              */
/*  23 November, 1998                                              */
/*  Roxanne Harrison                                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 1993 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*  799 Roosevelt Rd.  Bldg 6, Suite 108                           */
/*  Glen Ellyn, IL  60137                                          */
/*  (708) 790-8383                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Notes:                                                         */
/*                                                                 */
/*    This program is called by the PIR900 cmd.  The command       */
/*    needs to set the current library to the main PIR library     */
/*    so this program can setup the library list correctly.        */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revision:                                                      */
/*    01/14/00  RH   V4.13                                         */
/*    Program changed to not set the current library to PIR.       */
/*    Change to put PIRMODS on library list.                       */
/*-----------------------------------------------------------------*/

PIR900:      PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CURLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILELIB) TYPE(*CHAR) LEN(10)

/*-----------------------------------------------------------------*/
/*  Setup library list for PIR and bring up first menu             */
/*-----------------------------------------------------------------*/

             RMVLIBLE   LIB(PIR)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIR900F)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRMODS)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRTESTF)
             MONMSG     MSGID(CPF0000)

             ADDLIBLE   LIB(PIR)
             ADDLIBLE   LIB(PIR900F)
             ADDLIBLE   LIB(PIRMODS)


             GO         MENU(PCKTST)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
