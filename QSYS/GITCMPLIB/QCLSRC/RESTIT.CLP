/*-----------------------------------------------------------------*/
/*                                                                 */
/*  RESTIT      Restore library from save file                     */
/*  23 August 2000                                                 */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &LIB2RST  Library to restore                             */
/*        &TFRLIB   Transfer library                               */
/*                                                                 */
/*-----------------------------------------------------------------*/

 SAVEIT:     PGM        PARM(&LIB2RST &TFRLIB)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&LIB2RST)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSG)      TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TFRLIB)   TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CHGVAR     VAR(&MSG) VALUE('Restoring library' *BCAT +
                          &LIB2RST *BCAT 'from save file' *BCAT +
                          &TFRLIB *CAT '/' *CAT &LIB2RST)
             MSGBFC     MESSAGE(&MSG)
             RSTLIB     SAVLIB(&LIB2RST) DEV(*SAVF) +
                          SAVF(&TFRLIB/&LIB2RST) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL)

 GETOUT:

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) MSGTYPE(*COMP)

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

             ENDPGM
