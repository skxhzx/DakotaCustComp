/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT380CCL  Replenishment                                          */
/*  15 May, 1996                                                     */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT380CCL:   PGM        PARM(&WHSE &WHDP &NRPL &FRSL &AISL &SDEF +
                          &ITMTYPE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT380CCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT380C)

  /* Report program and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RPLFILEA)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Replenishment labels')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing replenishment labels')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&AISL)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&AISLW)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FRSL)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&ITMTYPE)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&NRPL)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SDEF)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODAY)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE15)     TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

/*           MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))   */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)


/*  Get report options. */


             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &NRPL &FRSL +
                          &AISL &SDEF &ITMTYPE &RETURN &JOBQ)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &NRPL +
                        &FRSL &AISL &SDEF &ITMTYPE)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             MSGBFC     MESSAGE('Selecting records')

 REPORT:

             CHGVAR     VAR(&WHSE15) VALUE(&WHSE)

   /* Create selection criteria string. */

   /* Select warehouse.                 */
             CHGVAR     VAR(&QRYSLT) VALUE('RLWHSE *EQ ' *CAT &WHSE)

   /* Select department.                */
             IF         COND(&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

   /* Select aisle.                                  */
             IF         COND(&AISL *NE '*ALL') THEN(DO)
               CHGVAR     VAR(&AISLW) VALUE(%SST(&AISL 2 3))
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
               CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLTAIL *EQ +
                            ' *CAT &QUOTE *CAT &AISLW *CAT &QUOTE)
             ENDDO

   /* Select replenishment slot def.    */
             IF         COND(&SDEF *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLSDEF *EQ +
                         ' *CAT &QUOTE *CAT &SDEF *CAT &QUOTE)
             ENDDO

   /* Select broken case items only.    */
             IF         COND(&ITMTYPE *EQ '*BROKEN   ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLTYPE *EQ +
                         "B"')
             ENDDO

   /* Select non-broken case items only.  */
             IF         COND(&ITMTYPE *EQ '*NONBROKEN') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLTYPE *NE +
                         "B"')
             ENDDO

   /* Select only that will free up slot. */
             IF         COND(&FRSL *EQ '*YES') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLFREE *EQ +
                          "Y"')
             ENDDO

   /* Must be an active (Pick) slot.           */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RLSTAT *EQ +
                          "A"')


             OVRDBF     FILE(RPLFILEA) SHARE(*YES)

             OPNQRYF    FILE((RPLFILEA)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((RLWHSE) (RLWHDP) +
                          (RLSEQ#))

             CALL       PGM(OR533) PARM(&WHSE15 &NRPL &RETURN)

             GOTO NOMSG

/*  Receive any messages and pass them on  */

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

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
