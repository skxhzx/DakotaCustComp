/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LO120CL   TRUCK LOADER                                           */
/*  09 JULY, 2004                                                    */
/*  KENNETH ELDER                                                    */
/*                                                                   */
/*  Created                                                          */
/*  07/09/04  KDE                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LO120CL:    PGM        PARM(&WHSE &PRTE &PRTID &MEMBER)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('TRUCK LOADER')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PRTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PPAL#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PSHFT)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(OUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  LOAD FIRST SCREEN  */

AGAIN:
             RMVM       FILE(LO120A) MBR(&MEMBER)
             MONMSG     MSGID(CPF0000)

             CHGVAR     VAR(&QRYSLT) VALUE('PSWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PSRTID  +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSGEN=1')

             OPNQRYF    FILE((PLTSUM) (LOADTRN)) FORMAT(LO120) +
                          QRYSLT(&QRYSLT) KEYFLD((PLTSUM/PSRTID) +
                          (PLTSUM/PSPLID)) UNIQUEKEY(2) +
                          JFLD((PLTSUM/PSRTID LOADTRN/LORTID) +
                          (PLTSUM/PSPLID LOADTRN/LOPLID)) +
                          JDFTVAL(*ONLYDFT) OPNID(LO120)
             CPYFRMQRYF FROMOPNID(LO120) TOFILE(LO120A) +
                          TOMBR(&MEMBER) MBROPT(*REPLACE) CRTFILE(*NO)
             OVRDBF     FILE(LO120) TOFILE(LO120A) MBR(&MEMBER)
             CALL       PGM(LO120) PARM(&WHSE &PRTID &PRTE &RETURN)

   /* Clean up before leaving */

             DLTOVR     FILE(LO120)
             CLOF       OPNID(LO120)
             RCLRSC

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:
             RETURN

             ENDPGM
