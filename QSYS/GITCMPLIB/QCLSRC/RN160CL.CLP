/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN160CL   Customer returns listing                               */
/*  11 May 1999                                                      */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    03/01/95  DAS  2.09                                            */
/*      - OPNQRYF statement was being skipped when running from      */
/*        the JOBQ. Moved REPORT tag to befor the OPNQRYF statement. */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    12/07/98  RH   4.10                                            */
/*      - Add PARM $CODE to select for one or all return codes.      */
/*    12/08/14  LMC  6.50a                                           */
/*      - Add sort by Route/item/date option 3                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RN160CL:    PGM        PARM(&WHSE &RETURN &JOBQ &DEV &FORM &FMDT +
                            &TODT &VP &SORT &ITEM &CODE)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN160CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN160)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ORRTN)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(RN161APR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(RN161BPR)
             DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) +
                          VALUE(RN161CPR) /*650aA*/

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Customer returns')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Customer returns report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
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
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&CODE)       TYPE(*CHAR) LEN(2)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &FMDT &TODT &VP &SORT &ITEM +
                          &CODE)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &VP +
                          &SORT &ITEM &CODE)) +
                          JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:  /* ( Chg 2.09 ) */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('ORWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('ORRDTE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('ORRDTE  +
                          *LE ' *CAT &TODT))
             IF         COND(&ITEM *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ORITEM  +
                          *EQ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)
             ENDDO
             IF         COND(&CODE *NE '  ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ORRCOD  +
                          *EQ' *BCAT &QUOTE *CAT &CODE *CAT &QUOTE)
             ENDDO


   /* Use OPNQRYF to select and order the records we need */

             IF (&SORT = '1') THEN(DO)
             OVRDBF     FILE(RN161A) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (PIRITEM)) FORMAT(RN161A) +
                          QRYSLT(&QRYSLT) KEYFLD((ORRTN/ORWHSE) +
                          (ORRTN/ORITEM) (ORRTN/ORRDTE) +
                          (ORRTN/ORRTIM)) +
                          JFLD((ORRTN/ORWHSE +
                          PIRITEM/ITWHSE *EQ) (ORRTN/ORITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                          OPTIMIZE(*FIRSTIO) SEQONLY(*NO)
             ENDDO
             IF (&SORT = '2') THEN(DO)
             OVRDBF     FILE(RN161B) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (PIRITEM)) FORMAT(RN161B) +
                          QRYSLT(&QRYSLT) KEYFLD((ORRTN/ORWHSE) +
                          (ORRTN/ORRDTE) (ORRTN/ORRTIM) +
                          (ORRTN/ORITEM)) +
                          JFLD((ORRTN/ORWHSE +
                          PIRITEM/ITWHSE *EQ) (ORRTN/ORITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                          OPTIMIZE(*FIRSTIO) SEQONLY(*NO)
             ENDDO

/*650aA Begins */
             IF (&SORT = '3') THEN(DO)
             OVRDBF     FILE(RN161C) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (PIRITEM) (ORDH) (RTEHED)) +
                          FORMAT(RN161C) +
                          QRYSLT(&QRYSLT) KEYFLD((ORRTN/ORWHSE) +
                          (RTEHED/RHRTE)                +
                          (ORRTN/ORITEM)  +
                          (ORRTN/ORRDTE) (ORRTN/ORRTIM)) +
                          JFLD((ORRTN/ORWHSE +
                          PIRITEM/ITWHSE *EQ) (ORRTN/ORITEM +
                          PIRITEM/ITITEM)                +
                          (ORRTN/ORWHSE ORDH/OHWHSE *EQ) +
                          (ORRTN/ORORD ORDH/OHCORD )  +
                          (ORRTN/ORWHSE RTEHED/RHWHSE *EQ) +
                          (ORDH/OHRTE RTEHED/RHRTID )) +
                          JDFTVAL(*YES) +
                          OPTIMIZE(*FIRSTIO) SEQONLY(*NO)
             ENDDO
/*650aA Ends */

 VIEW:

             IF (&VP = 'V') THEN(DO)
             IF (&SORT = '1') THEN(DO)
             CALL       PGM(RN162A) PARM(&WHSE &FMDT &TODT &ITEM +
                        &CODE)
               GOTO       CMDLBL(OUT)
             ENDDO

             IF (&SORT = '2') THEN(DO)
             CALL       PGM(RN162B) PARM(&WHSE &FMDT &TODT &ITEM +
                        &CODE)
               GOTO       CMDLBL(OUT)
             ENDDO

             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


 /* REPORT:   ( Chg 2.09 ) */

   /* Override printer file. */

             IF (&SORT = '1') THEN(DO)
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN161A) PARM(&FMDT &TODT &ITEM &CODE)
             ENDDO

             IF (&SORT = '2') THEN(DO)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN161B) PARM(&FMDT &TODT &ITEM &CODE)
             ENDDO

/*650aA Begins */
             IF (&SORT = '3') THEN(DO)
             OVRPRTF    FILE(&PRTF3) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(RN161C) PARM(&FMDT &TODT &ITEM &CODE)
             ENDDO
/*650aA Ends   */


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
