/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT325CL   Warehouse book by item/designation code                */
/*  09 September, 2007                                               */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    09/08/07  RH  V5.10                                            */
/*      - Created                                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT325CL:    PGM        PARM(&WHSE &WHDP &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT325CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT325)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRITEM)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IT326PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Warehouse book by item/desg')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Warehouse book by item/desg')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&DESG)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SECTN &RETURN +
                          &DESG &JOBQ &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP +
                          &RETURN &DEV &FORM)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('ITWHSE *EQ ' *CAT &WHSE)


             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF (&DESG *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITDESG *EQ +
                          ' *BCAT &QUOTE *CAT &DESG *CAT &QUOTE)
             ENDDO

             IF (&RETURN = '*PIR') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'P' *CAT &QUOTE)
             ENDDO

             IF (&RETURN = '*FIXED') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'F' *CAT &QUOTE)
             ENDDO

 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(IT326) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (SLOT)) FORMAT(IT326) +
                          QRYSLT(&QRYSLT) KEYFLD((PIRITEM/ITWHSE) +
                          (PIRITEM/ITWHDP) (PIRITEM/ITSTYP) +
                          (PIRITEM/ITITEM)) JFLD((PIRITEM/ITWHSE +
                          SLOT/SLWHSE) (PIRITEM/ITITEM +
                          SLOT/SLITEM)) JDFTVAL(*YES) +
                          OPTIMIZE(*FIRSTIO) SEQONLY(*NO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(IT326)

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

             RCLRSC     LVL(*CALLER)

             ENDPGM
