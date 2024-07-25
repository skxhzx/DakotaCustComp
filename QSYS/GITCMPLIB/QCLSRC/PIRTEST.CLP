/*-----------------------------------------------------------------*/
/*                                                                 */
/*  PIRTEST  Gateway to PIR system using test files                */
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
/*  Notes:                                                         */
/*                                                                 */
/*    This program is called by the PIRTEST command.               */
/*                                                                 */
/*-----------------------------------------------------------------*/

PIRTEST:     PGM

/*-----------------------------------------------------------------*/
/*  Setup library list for PIR and bring up first menu             */
/*-----------------------------------------------------------------*/

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
             ADDLIBLE   LIB(PIRTESTF)
             ADDLIBLE   LIB(PIRFTP)
             ADDLIBLE   LIB(PIRFTPF)
             ADDLIBLE   LIB(PIRMODS)

             GO         MENU(PIRMAIN)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
