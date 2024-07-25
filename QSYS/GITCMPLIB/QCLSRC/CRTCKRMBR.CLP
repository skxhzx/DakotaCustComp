/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTCKRMBR   Create member in CKREXP file for Check Right         */
/*  26 June 2006                                                     */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/26/09  JCJ                                                  */
/*      - Created.  Copied from CRTTAXRMBR                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTCKRMBR:  PGM        PARM(&MEMBER)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXIST)      TYPE(*LGL)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*                                                                   */
/*  SEE IF MEMBER EXISTS (1=EXISTS                                   */
/*                                                                   */
             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(CKREXP) OBJTYPE(*FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*                                                                   */
/*  IF MEMBER DOES NOT EXIST THEN CREATE IT AND RETURN               */
/*                                                                   */
             IF  (*NOT &EXIST) DO
                 ADDPFM     FILE(CKREXP) MBR(&MEMBER)
             RETURN
             ENDDO
/*                                                                   */
/*  IF MEMBER EXISTS, CLEAR IT                                       */
/*                                                                   */
             ALCOBJ     OBJ((CKREXP *FILE *EXCL &MEMBER)) WAIT(0)
             MONMSG     MSGID(CPF1002)

             CLRPFM     FILE(CKREXP) MBR(&MEMBER)
             MONMSG     MSGID(CPF3130 CPF3156 CPF3203)

             DLCOBJ     OBJ((CKREXP *FILE *EXCL &MEMBER))

             ENDPGM
