/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTTOTEMBR   Create member in TOTEEXP file for Cashwa Totes      */
/*  16 March 2012                                                    */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/16/12  LMC   CWDa                                           */
/*      - Created.  Copied from CRTTAXRMBR                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTTOTEMBR: PGM        PARM(&MEMBER)

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
             CHKOBJ     OBJ(TOTEEXP) OBJTYPE(*FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*                                                                   */
/*  IF MEMBER DOES NOT EXIST THEN CREATE IT AND RETURN               */
/*                                                                   */
             IF  (*NOT &EXIST) DO
                 ADDPFM     FILE(TOTEEXP) MBR(&MEMBER)
             RETURN
             ENDDO
/*                                                                   */
/*  IF MEMBER EXISTS, CLEAR IT                                       */
/*                                                                   */
             ALCOBJ     OBJ((TOTEEXP *FILE *EXCL &MEMBER)) WAIT(0)
             MONMSG     MSGID(CPF1002)

             CLRPFM     FILE(TOTEEXP) MBR(&MEMBER)
             MONMSG     MSGID(CPF3130 CPF3156 CPF3203)

             DLCOBJ     OBJ((TOTEEXP *FILE *EXCL &MEMBER))

             ENDPGM
