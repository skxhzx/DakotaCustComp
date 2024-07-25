/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIR   Gateway to PIR system.                                   */
/*  22 March 1993                                                  */
/*  Dave Sommerville                                               */
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
/*    This program is called by the PIR command.  The command      */
/*    needs to set the current library to the main PIR library     */
/*    so this program can setup the library list correctly.        */
/*                                                                 */
/*-----------------------------------------------------------------*/

PIR:         PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CURLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILELIB) TYPE(*CHAR) LEN(10)

/*-----------------------------------------------------------------*/
/*  Setup library list for PIR and bring up first menu             */
/*-----------------------------------------------------------------*/

             RTVJOBA    CURLIB(&CURLIB)
             CHGVAR     VAR(&FILELIB) VALUE(&CURLIB *TCAT 'F')
             RMVLIBLE   LIB(&FILELIB)
             MONMSG     MSGID(CPF0000)
             ADDLIBLE   LIB(&FILELIB)

             GO         MENU(PIRMAIN)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
