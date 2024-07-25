/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SCD320CL  Slots with Check Digit, Report                         */
/*  07 January, 2001                                                 */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*   04/15/04  DAS  4.17                                             */
/*     - Added parms &STAT and &HEAD.                                */
/*   09/11/07  RBD  5.10                                             */
/*     - Fix: If view, ignore whse and dept selections, as all       */
/*       whse's and dept's must be included so that user may         */
/*       position to any whse or dept within the view pgm, SCD322.   */
/*     - Enh: Revise to accomodate multiple check digits.            */
/*       Create new work file SCD323A to contain check digits from   */
/*       both slotdgt and slotdgta.                                  */
/*   04/08/09  RBD  5.20                                             */
/*     - Undo 5.10 fix, it was not necessary. Removed code           */
/*       for readability.                                            */
/*   01/29/11  GJA  6.40a                                            */
/*     - Fix: Remove member at exit.                                 */
/*                                                                   */
/*   08/01/18  MLB  7.20                                             */
/*     - Fix: Revised 5.10 mod to move code after :REPORT tag.       */
/*       Code wasn't being executed when submitted to batch.         */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*CD320CL:   PGM        PARM(&WHSE &WHDP &RETURN &DEV &FORM) 417D */
 SCD320CL:   PGM        PARM(&WHSE &WHDP &SLTYP &STAT +
                             &RETURN &DEV &FORM &HEAD)     /* 417M */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SCD320CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) VALUE(SCD320)

  /* Report program and printer file name. */

/***510 D    DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOTDGT)  */
/***510 M*/  DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SCD323A)
             DCL        VAR(&FILE2) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SCD321PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Slots and Check digit Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Slots and Check Digit +
                          Report')

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
             DCL        VAR(&SLTYP)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(4) /* 417A */
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&HEAD)       TYPE(*CHAR) LEN(50) /*417A*/

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

        /*   CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SLTYP &RETURN +  */
        /*                &VP &JOBQ &DEV &FORM)          417D */
             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SLTYP &STAT +
                          &RETURN &VP &JOBQ &DEV &FORM &HEAD)  /* 417M */

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
       /*    SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP +    */
       /*                 &RETURN &DEV &FORM)) JOB(&SBMPGM)    417D */
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &SLTYP +
                          &STAT &RETURN &DEV &FORM &HEAD)) +
                          JOB(&SBMPGM) /*417M*/
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/* Build SCD323A work file          (510 A) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE SCD323A &MEMBER)
             OVRDBF     FILE(SCD323A) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(SCD323)

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)

             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF (&SLTYP = 'O') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK +
                          *NE' *BCAT &QUOTE *CAT 'Y' *CAT &QUOTE)
             ENDDO

             IF (&SLTYP = 'P') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK +
                          *EQ' *BCAT &QUOTE *CAT 'Y' *CAT &QUOTE)
             ENDDO

   /* 417 A  Begin */
             IF (&STAT *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT +
                          *EQ' *BCAT &QUOTE *CAT &STAT *CAT &QUOTE)
             ENDDO
   /* 417 A  End */
 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SCD321) TOFILE(&FILE) MBR(&MEMBER) +
                          SHARE(*YES)
/***510 D*   OPNQRYF    FILE((&FILE) (&FILE2)) FORMAT(SCD321) +
                          QRYSLT(&QRYSLT) KEYFLD((SLOTDGT/SCDWHS) +
                          (SLOTDGT/SCDWHD) (SLOTDGT/SCDDSP)) +
                          JFLD((SCDWHS SLWHSE) (SCDWHD SLWHDP) +
                          (SCDDSP SLDISP)) JDFTVAL(*NO) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)   *****/

             OPNQRYF    FILE((&FILE &MEMBER) (&FILE2)) +
                          FORMAT(SCD321) QRYSLT(&QRYSLT) +
                          KEYFLD((SCD323A/SWKWHS) (SCD323A/SWKWHD) +
                          (SCD323A/SWKDSP)) JFLD((SWKWHS SLWHSE) +
                          (SWKWHD SLWHDP) (SWKDSP SLDISP)) +
                          JDFTVAL(*NO) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO) /* 510 A*/

/*  If user viewed the data then we are done so exit. */

             IF (&VP = 'V') THEN(DO)
         /*  CALL       PGM(SCD322) PARM(&WHSE &WHDP &SLTYP)  417D */
             CALL       PGM(SCD322) PARM(&WHSE &WHDP &SLTYP &STAT +
                          &HEAD) /*417M*/
               GOTO       CMDLBL(OUT)
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

        /*   CALL       PGM(SCD321)      417D */
             CALL       PGM(SCD321) PARM(&HEAD)  /*417M*/

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

/*  Cleanup SCD323A work file   (510 A) */
/*6.40a      ALCOBJ     OBJ((SCD323A *FILE *EXCL &MEMBER)) WAIT(0) */
/*6.40a      MONMSG     MSGID(CPF1002)                             */
/*6.40a */   RCLRSC     LVL(*CALLER)
/*6.40A */   CLOF       OPNID(SCD323A)
/*6.40a */   MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(SCD323A)
             MONMSG     MSGID(CPF9841)
/*6.40a */   RMVM       FILE(SCD323A) MBR(&MEMBER)
/*6.40a */   MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
/*6.40a */                CPF7301 CPF7310 CPF0001)
/*6.40a      CLRPFM     FILE(SCD323A) MBR(&MEMBER)                 */
/*6.40a      MONMSG     MSGID(CPF3130 CPF3156 CPF3203)             */
/*6.40a      DLCOBJ     OBJ((SCD323A *FILE *EXCL &MEMBER))         */

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
