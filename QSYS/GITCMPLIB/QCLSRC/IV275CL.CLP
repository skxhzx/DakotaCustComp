/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV275CL   Inventory slot assignment status                       */
/*  17 June, 2007                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*    06/17/07  RH   5.10a                                           */
/*      - Created                                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV275CL:    PGM        PARM(&WHSE &WHDP)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&PGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV275CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV275)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(INVSASN)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Slot Assignment status')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Listing Inv slot assignment status')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PARMS)      TYPE(*CHAR) LEN(136)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER1)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&CODE)       TYPE(*CHAR) LEN(2)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  Get options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/*  Run program. */

                CALL       PGM(GETUNQMEM) PARM(*REUSE IV275 &MEMBER1)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IVGWHS *EQ ' *CAT &WHSE)

             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IVGWHD *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO


/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(IV275) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (INVSLOT)) FORMAT(IV275) +
                          QRYSLT(&QRYSLT) +
                          KEYFLD((INVSASN/IVGWHS) (INVSASN/IVGWHD) +
                          (INVSASN/IVGTEM) (INVSLOT/IVSEDT)) +
                          JFLD((INVSASN/IVGWHS INVSLOT/IVSWHS) +
                          (INVSASN/IVGWHD INVSLOT/IVSWHD) +
                          (INVSASN/IVGDSP INVSLOT/IVSDSP)) +
                          JDFTVAL(*YES) OPTIMIZE(*FIRSTIO) SEQONLY(*NO)



/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE IV276A &MEMBER)
             OVRDBF     FILE(IV276A) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(IV276A) PARM(&WHSE &WHDP &RETURN)
 VIEW:

             CALL       PGM(IV276) PARM(&WHSE &WHDP &RETURN)           +



             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)



 /* Receive any messages and pass them on */

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
 OUT:
 NOMSG:

   /* Clean up before leaving */
             DLTOVR     FILE(IV276A)
             MONMSG     MSGID(CPF9841)
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)

             RCLRSC     LVL(*CALLER)

             ENDPGM
