/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRPROD  Gateway to PIR system using production files          */
/*  11 June 1999                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 1999 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*  799 Roosevelt Rd.  Bldg 6, Suite 108                           */
/*  Glen Ellyn, IL  60137                                          */
/*  (708) 790-8383                                                 */
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
/*    This program is called by the PIRPROD command.               */
/*                                                                 */
/*-----------------------------------------------------------------*/

PIRPROD:     PGM

/*-------------------------------------------------------------------*/
/*  Customer ID's                                           (520  A) */
/*-------------------------------------------------------------------*/
             DCL        VAR(&RENZI) TYPE(*CHAR) LEN(10) +
                          VALUE('RENZI')                 /* (520  A) */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10) +
                          VALUE(' ')                     /* (520  A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10) +
                          VALUE(' ')                     /* (520  A) */

/*    * Get client id.                                                (520 A) */

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)    /* (520 A) */

/*-----------------------------------------------------------------*/
/*  Setup library list for PIR and bring up first menu             */
/*-----------------------------------------------------------------*/

             IF         COND(&CLIENT = &RENZI) THEN(DO)           /* (RNZ A) */
             enddo                                                /* (RNZ A) */
             ELSE       CMD(DO)                                   /* (RNZ A) */
             RMVLIBLE   LIB(PIR)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRF)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRFTP)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRFTPF)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRMODS)
             MONMSG     MSGID(CPF0000)

             RMVLIBLE   LIB(PIRTESTF)
             MONMSG     MSGID(CPF0000)

             ADDLIBLE   LIB(PIR)
             ADDLIBLE   LIB(PIRF)
             ADDLIBLE   LIB(PIRFTP)
             ADDLIBLE   LIB(PIRFTPF)
             ADDLIBLE   LIB(PIRMODS)
             enddo                                                /* (RNZ A) */

             GO         MENU(PIRMAIN)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
