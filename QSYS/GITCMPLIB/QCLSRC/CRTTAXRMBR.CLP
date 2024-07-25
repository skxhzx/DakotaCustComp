/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTTAXRMBR   Create member in TAXREXP file for Tax-Right         */
/*  14 July 2006                                                     */
/*  Robin Clark                                                      */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    07/14/06  RMC                                                  */
/*      - Created.  Copied from CRTREDPMBR                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTTAXRMBR: PGM        PARM(&MEMBER)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXIST)      TYPE(*LGL)
 /*          DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(10)       */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*                                                                   */
/*  SEE IF MEMBER EXISTS (1=EXISTS                                   */
/*                                                                   */
             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(TAXREXP) OBJTYPE(*FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*                                                                   */
/*  IF MEMBER DOES NOT EXIST THEN CREATE IT AND RETURN               */
/*                                                                   */
             IF  (*NOT &EXIST) DO
                 ADDPFM     FILE(TAXREXP) MBR(&MEMBER)
             RETURN
             ENDDO
/*                                                                   */
/*  IF MEMBER EXISTS, CLEAR IT                                       */
/*                                                                   */
             ALCOBJ     OBJ((TAXREXP *FILE *EXCL &MEMBER)) WAIT(0)
             MONMSG     MSGID(CPF1002)

             CLRPFM     FILE(TAXREXP) MBR(&MEMBER)
             MONMSG     MSGID(CPF3130 CPF3156 CPF3203)

             DLCOBJ     OBJ((TAXREXP *FILE *EXCL &MEMBER))

             ENDPGM
