/*----------------------------------------------------------------   */
/*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*----------------------------------------------------------------   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UI314CL   Clear UCI Exceptions                                   */
/*  12 September, 2006                                               */
/*  Randy Haselhorst                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UI314CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(UIIEXCP1)
             DCL        VAR(&PGM)   TYPE(*CHAR) LEN(8)  VALUE(UI314)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

             OVRDBF     FILE(&FILE) SHARE(*YES)
          /* OPNDBF     FILE(&FILE) OPTION(*ALL) */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

   /* Use OPNQRYF to select and order the records we need */

             OPNQRYF    FILE((&FILE)) OPTION(*ALL) QRYSLT('UIESTA +
                          *NE "4 "') KEYFLD(*FILE)

/*  On with the show ... */

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
