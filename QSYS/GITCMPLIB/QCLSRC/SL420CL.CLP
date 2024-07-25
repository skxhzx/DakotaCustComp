/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL420CL   Available pick slots by aisle                          */
/*            Added option to print overflow slots. (650 A)          */
/*  21 january, 2002                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  04/08/05  RLP  5.00                                              */
/*    - Added "view" to options                                      */
/*    - changed to use newly created logical SLOT8                   */
/*                                                                   */
/*  05/02/13  RBD  6.50                                              */
/*    - Added option to print overflow slots.                        */
/*    - Added slot location to sort.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL420CL:    PGM        PARM(&WHSE &WHDP &STYP &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL420CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL420)

  /* Report program and printer file name. */

             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SL421PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
/* 650 M */               VALUE('Available pick or overflow slots')
/* 650 D                  VALUE('Available pick slots')              */
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
/* 650 M */               VALUE('Printing available pick or overflow slots')
/* 650 D                  VALUE('Printing available pick slots')     */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&AISL)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SEQ)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&STYP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

/*(650 D)    CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &STYP &AISL    */
/*(650 M)*/  CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &STYP &AISL &PICK +
                          &RETURN &VP &JOBQ &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &STYP +
                          &RETURN &DEV &FORM)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLITEM *EQ +
                          ' *BCAT &QUOTE *CAT &QUOTE)
/*(650 D)    CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     */
/*(650 D)    CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK *EQ +
                          ' *BCAT &QUOTE *CAT Y *CAT &QUOTE)         */
/*(650 A)*/  IF (&PICK *EQ 'P' ) THEN(DO)
/*(650 A)*/  CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
/*(650 A)*/  CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK *EQ +
                          ' *BCAT &QUOTE *CAT Y *CAT &QUOTE)
/*(650 A)*/  ENDDO
/*(650 A)*/  ELSE       CMD(DO)
/*(650 A)*/  CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
/*(650 A)*/  CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK *EQ +
                          ' *BCAT &QUOTE *CAT N *CAT &QUOTE)
/*(650 A)*/  ENDDO

   /* 5.00 */
   /* If viewing the report, select all records for this warehouse */
   /* Skip all other selection. */

             IF         COND(&VP *EQ 'V') THEN(GOTO CMDLBL(VIEW))

             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF (&STYP *NE 'B') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTYP *EQ +
                          ' *BCAT &QUOTE *CAT &STYP *CAT &QUOTE)
             ENDDO

             IF (&AISL *NE '*AL' ) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL *EQ +
                          ' *BCAT &QUOTE *CAT &AISL *CAT &QUOTE)
             ENDDO

 VIEW:

   /* Use OPNQRYF to select and order the records we need */

/*           OVRDBF     FILE(SLOT1) SHARE(*YES)  */ /* 5.00 M */
             OVRDBF     FILE(SLOT8) SHARE(*YES)     /* 5.00 A */

/*           OPNQRYF    FILE((SLOT1)) QRYSLT(&QRYSLT) +
                          KEYFLD((SLOT1/SLWHSE) (SLOT1/SLWHDP) +
                          (SLOT1/SLAISL) (SLOT1/SLPSEQ) (SLOT1/SLRLVL) +
                          (SLOT1/SLHAND)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)   */  /* 500 M */

/* 500 A */
/* 650 D     OPNQRYF    FILE((SLOT8)) QRYSLT(&QRYSLT) +
                          KEYFLD((SLOT8/SLWHSE) (SLOT8/SLWHDP) +
                          (SLOT8/SLSTYP) (SLOT8/SLAISL) +
                          (SLOT8/SLRLVL) (SLOT8/SLHAND)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO) */  /* 650 D*/

/* 650 M*/   OPNQRYF    FILE((SLOT8)) QRYSLT(&QRYSLT) +
                          KEYFLD((SLOT8/SLWHSE) (SLOT8/SLWHDP) +
                          (SLOT8/SLSTYP) (SLOT8/SLAISL) (SLOT8/SLLOC) +
                          (SLOT8/SLRLVL) (SLOT8/SLHAND)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

/*  If user viewed the data then we are done so exit. */

             IF (&VP = 'V') THEN(DO)
/*(650 D)    CALL       PGM(SL422) PARM(&WHSE &WHDP &STYP &AISL)     */
/*(650 M)*/  CALL       PGM(SL422) PARM(&WHSE &WHDP &STYP &AISL &PICK)
               GOTO       CMDLBL(OUT)
             ENDDO

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

                CALL       PGM(SL421)

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
