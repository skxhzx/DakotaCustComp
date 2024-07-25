/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT380CL   Replenishment                                          */
/*  31 October, 1994                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/20/95  DAS                                                  */
/*      - Revised OPNQRYF to include the warehouse along with the    */
/*        item as join fields.                                       */
/*                                                                   */
/*    05/10/96  HNK  2.13                                            */
/*      - Department selection disabled.                             */
/*      - Revised KEYFLD parm on OPNQRYF.                            */
/*      - Revised IT380CL to call IT380A instead of IT381.           */
/*                                                                   */
/*    07/03/96  HNK  2.14                                            */
/*      - Call IT380B program to clear work file, instead of         */
/*        CLRPFM in this program.                                    */
/*                                                                   */
/*    07/17/96  RH   2.14                                            */
/*      - Call IT380B program to clear work file after report        */
/*        tag so files will be cleared if it380cl is called from     */
/*        command line using CRTPTLRPL.                              */
/*                                                                   */
/*    07/29/96  RH   2.14                                            */
/*      - Call IT380D to verify warehouse #, display error msg.      */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT380CL:    PGM        PARM(&WHSE &JOBQ)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT380CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT380)

  /* Report program and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Replenishment labels')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing replenishment labels')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SDEF)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHSEN)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&LCMD)       TYPE(*CHAR) LEN(8)

/*           MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))   */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF         COND(&TYPE = '0') THEN(GOTO CMDLBL(REPORT))


/*  Get report options. */

             IF (&WHSE ='   ') THEN(DO)
             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
             SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO
             ENDDO

/* 214 D Clear work file. */
/* 214 D     CHGVAR     VAR(&WHSEN) VALUE(&WHSE) */
/* 214 D     CALL       PGM(IT380B) PARM(&WHSEN) */

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &JOBQ)) +
                          JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             MSGBFC     MESSAGE('Selecting records')

 REPORT:
/*  Verify warehouse. */
             CALL       PGM(IT380D)  PARM(&WHSE &RETURN)
   /*        CHGVAR     VAR(&WHSEN) VALUE(&WHSE)        */
             IF (&RETURN = '*ERROR') THEN(DO)
             IF (&TYPE = '1') THEN(DO)
             SNDPGMMSG  MSGID(IT38001) MSGF(PIRMSGF) MSGDTA(&WHSE) +
                          TOPGMQ(*PRV ('CRTPTLRPL')) MSGTYPE(*INFO)
               RETURN
             ENDDO
             SNDPGMMSG  MSGID(IT38001) MSGF(PIRMSGF) MSGDTA(&WHSE) +
                          MSGTYPE(*ESCAPE)
               RETURN
             ENDDO

/*  Clear work file. */

             CHGVAR     VAR(&WHSEN) VALUE(&WHSE)
             CALL       PGM(IT380B) PARM(&WHSEN)


   /* Create selection criteria string. */

   /* Select warehouse.                 */
             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)

   /* Must be an active slot.           */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT *EQ +
                          "A"')

   /* Must be a picking slot.           */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK *EQ +
                          "Y"')
   /* Must be a fixed slot OR pir slot  */
   /* PIR slot must be reserved and item type must be broken.  */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '((SLSTYP +
                          *EQ "F")' *BCAT '*OR' *BCAT '(SLSTYP *EQ +
                          "P"' *BCAT '*AND' *BCAT 'SLRSRV *EQ "Y"' +
                           *BCAT '*AND' *BCAT 'ITTYPE *EQ "B"))')

             OVRDBF     FILE(IT381) TOFILE(&FILE) SHARE(*YES)

             OPNQRYF    FILE((SLOT) (PIRITEM)) FORMAT(IT381) +
                          QRYSLT(&QRYSLT) +
                          KEYFLD((*MAPFLD/QLWHSE) +
                                 (*MAPFLD/QLWHDP) +
                                 (*MAPFLD/QLAISL) +
                                 (*MAPFLD/QLLOC ) +
                                 (*MAPFLD/QLRLVL) +
                                 (*MAPFLD/QLHAND)) +
                          JFLD((*MAPFLD/QLWHSE  PIRITEM/ITWHSE) +
                               (*MAPFLD/QLITEM  PIRITEM/ITITEM)) +
                          MAPFLD((QLWHSE  SLWHSE) +
                                 (QLWHDP  SLWHDP) +
                                 (QLITEM  SLITEM) +
                                 (QLDISP  SLDISP) +
                                 (QLAISL  SLAISL) +
                                 (QLLOC   SLLOC)  +
                                 (QLRLVL  SLRLVL) +
                                 (QLHAND  SLHAND) +
                                 (QLSTAT  SLSTAT) +
                                 (QLSDEF  SLSDEF) +
                                 (QLSTK1  SLSTK1) +
                                 (QLSTK2  SLSTK2) +
                                 (QLSTK3  SLSTK3) +
                                 (QLALC1  SLALC1) +
                                 (QLALC2  SLALC2) +
                                 (QLALC3  SLALC3) +
                                 (QLTFR1  SLTFR1) +
                                 (QLTFR2  SLTFR2) +
                                 (QLTFR3  SLTFR3) +
                                 (QLPCK1  SLPCK1) +
                                 (QLPCK2  SLPCK2) +
                                 (QLPCK3  SLPCK3) +
                                 (QLRCV1  SLRCV1) +
                                 (QLRCV2  SLRCV2) +
                                 (QLRCV3  SLRCV3))

             CALL       PGM(IT380A) PARM(&WHSE &RETURN)

/*           GOTO NOMSG                    */

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
