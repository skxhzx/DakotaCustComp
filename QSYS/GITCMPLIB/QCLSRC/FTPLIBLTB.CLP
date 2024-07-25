/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 2011 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*                                                                 */
/*-------------------------------------------------------------------*/
/*                                                                 */
/*  FTPLIBLTB  Setup FTP Library List - BFCTRKBLD version          */
/*  10 May 2011                                                    */
/*  Dave Sommerville                                               */
/*                                                                 */
/*-------------------------------------------------------------------*/
/*  05/10/11  DAS  6.40                                            */
/*    - Created                                                    */
/*                                                                   */
/*-----------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &TYPE  -  *PROD   Production library list                      */
/*              *TEST   Test library list                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command                                                      */
/*                                                                   */
/*    QUOTE RCMD CALL PIR/FTPLIBLTB *TEST                            */
/*                                                                   */
/*-----------------------------------------------------------------*/

FTPLIBLTB:   PGM        PARM(&TYPE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF (&TYPE = '*PROD') THEN(DO)
               ADDLIBLE   LIB(BFCTRKBLD) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(BFCTRKBLDM) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(BFCTRKBLDF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*TEST') THEN(DO)
               ADDLIBLE   LIB(BFCTRKBLD) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(BFCTRKBLDM) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(BFCTRKTSTF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(BFCTRKBLDT) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

END:         ENDPGM
