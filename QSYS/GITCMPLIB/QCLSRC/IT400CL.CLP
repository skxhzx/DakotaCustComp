/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT400CL   Shelf life expiration report                           */
/*  29 March, 1996                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/20/95  DAS  2.13                                            */
/*      - Moved PIRITMS fields into PIRITEM.                         */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    10/13/99  HNK  4.13                                            */
/*      - &WHDP added.                                               */
/*    09/11/03  RH   4.17A                                           */
/*      - Add ITEMMSC TO OPNQRYF                                     */
/*    09/14/10  RH   5.30a                                           */
/*      - Enh:Change QRYSLT to select slots with entered date > 0.   */
/*    07/07/14  RTR  6.50a                                           */
/*      - Fix: Change printer override to outq instead of dev.       */
/*    07/15/14  GJA  6.50a                                           */
/*      - Enh: Alow select and sort by aisle                         */
/*                                                                   */
/*    04/20/16  MLB  7.00                                            */
/*      - Fix: Revised pgm to pass &Aisle and &Sort on SBMJOB cmd    */
/*        that were added in 6.50a mod. Was causing a CPF4101 level  */
/*        check error when submitted to batch.                       */
/*      - Note: This patch requires an update to the PIRRPT menu     */
/*        opt# 15 to add 2 additional parms. And Webfacing updated.  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT400CL:    PGM        PARM(&WHSE &WHDP &RETURN &DEV &FORM &AISLE &SORT) +
                                                                  /* (700 M) */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT400CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT400)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IT401PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Shelf life expiration report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Shelf life expiration report')

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
/*6.50b*/    DCL        VAR(&AISLE)      TYPE(*CHAR) LEN(3)
/*6.50b*/    DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &RETURN +
                           &JOBQ &DEV &FORM &AISLE &SORT) /*6.50b*/

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE  +
                          &WHDP &RETURN &DEV &FORM &AISLE &SORT)) JOB(&SBMPGM) +
                                                                  /* (700 M) */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

   /*    OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                      FORMTYPE(&FORM)                      /* 650aD */
         OVRPRTF    FILE(&PRTF) OUTQ(&DEV) FORMTYPE(&FORM) /* 650aM */
         MONMSG     MSGID(CPF0000)                         /* 650aA */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('ITWHSE *EQ ' *CAT &WHSE)

             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

/*6.50b*/    IF (&AISLE *NE '   ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL *EQ +
                          ' *BCAT &QUOTE *CAT &AISLE *CAT &QUOTE)
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITSLIF > 0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')      /* 530a */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLENTD > 0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT +
                          *NE' *BCAT &QUOTE *CAT 'V' *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT +
                          *NE' *BCAT &QUOTE *CAT 'Z' *CAT &QUOTE)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(IT401) TOFILE(&FILE) SHARE(*YES)
/*6.50b*/    IF (&SORT *EQ '1') THEN(DO)
             OPNQRYF    FILE((&FILE) (PIRITEM) (ITEMMSC)) +
                          FORMAT(IT401) QRYSLT(&QRYSLT) +
                          KEYFLD((PIRITEM/ITWHSE) (ITEMMSC/IMBNBR) +
                          (PIRITEM/ITITEM)) +
                          JFLD((PIRITEM/ITWHSE SLOT/SLWHSE) +
                          (PIRITEM/ITITEM SLOT/SLITEM) +
                          (PIRITEM/ITITEM ITEMMSC/IMITEM)) +
                          JDFTVAL(*YES) SEQONLY(*NO) OPTIMIZE(*FIRSTIO)
/*6.50b*/    ENDDO

/*6.50b*/    IF (&SORT *EQ '2') THEN(DO)
/*6.50b*/    OPNQRYF    FILE((&FILE) (PIRITEM) (ITEMMSC)) +
/*6.50b*/                 FORMAT(IT401) QRYSLT(&QRYSLT) +
/*6.50b*/                 KEYFLD((PIRITEM/ITWHSE) +
/*6.50b*/                 (SLOT/SLAISL) (SLOT/SLDISP) +
/*6.50b*/                 (PIRITEM/ITITEM)) +
/*6.50b*/                 JFLD((PIRITEM/ITWHSE SLOT/SLWHSE) +
/*6.50b*/                 (PIRITEM/ITITEM SLOT/SLITEM) +
/*6.50b*/                 (PIRITEM/ITITEM ITEMMSC/IMITEM)) +
/*6.50b*/                 JDFTVAL(*YES) SEQONLY(*NO) OPTIMIZE(*FIRSTIO)
/*6.50b*/    ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(IT401)

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
