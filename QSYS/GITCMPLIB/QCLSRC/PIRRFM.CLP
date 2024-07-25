/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRRFM   Gateway to PIR system for RF Main Menu                */
/*  14 August 2008                                                 */
/*  Dave Sommerville                                               */
/*  Roxanne Harrison                                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 2008 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                         */
/*  West Chicago, IL  60185                                        */
/*  (630) 562-0375                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions:                                                     */
/*    07/24/08  MLB  5.20                                          */
/*      - Added client custom code support to program.             */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Client Custom Revisions: Renzi Foodservice                     */
/*    07/24/08  MLB  RNZ                                           */
/*      - Revised program to not perform RMV/ADDLIBLE cmds.        */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Notes:                                                         */
/*                                                                 */
/*    This program is called by the PIRRFM command.  The command   */
/*    needs to set the current library to the main PIR library     */
/*    so this program can setup the library list correctly.        */
/*                                                                 */
/*-----------------------------------------------------------------*/

PIR:         PGM

/*-------------------------------------------------------------------*/
/*  Customer ID's                                           (520  A) */
/*-------------------------------------------------------------------*/
             DCL        VAR(&RENZI) TYPE(*CHAR) LEN(10) +
                          VALUE('RENZI')                 /* (520  A) */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10) +
                          VALUE(' ')                     /* (520  A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10) +
                          VALUE(' ')                     /* (520  A) */


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CURLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILELIB) TYPE(*CHAR) LEN(10)

/*    * Get client id.                                                (520 A) */

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)    /* (520 A) */

/*-----------------------------------------------------------------*/
/*  Setup library list for PIR and bring up first menu             */
/*-----------------------------------------------------------------*/

             RTVJOBA    CURLIB(&CURLIB)
             IF         COND(&CLIENT = &RENZI) THEN(DO)           /* (RNZ A) */
             enddo                                                /* (RNZ A) */
             ELSE       CMD(DO)                                   /* (RNZ A) */
             CHGVAR     VAR(&FILELIB) VALUE(&CURLIB *TCAT 'F')
             RMVLIBLE   LIB(&FILELIB)
             MONMSG     MSGID(CPF0000)
             ADDLIBLE   LIB(&FILELIB)
             enddo                                                /* (RNZ A) */

             GO         MENU(RFSCRN)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
