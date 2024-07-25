/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT315CL   Inventory adjustments report                           */
/*  07 November, 1994                                                */
/*  Hemant Kapadia                                                   */
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
/*      - Add PARM $CODE to select for one or all adjustment codes.  */
/*    10/10/99  RH   4.13                                            */
/*      - Fix to select for department.                              */
/*    02/16/01  RH   4.15a                                           */
/*      - Add IT317P program to write qry file records and link      */
/*        file records to physical file, if 1 item is selected       */
/*        will display the linked item records.                      */
/*    06/05/01  DAS  4.15b                                           */
/*      - Added MONMSG's at very end of program to prevent never     */
/*        ending loop if one of the commands failed.                 */
/*                                                                   */
/*    07/06/06  MLB  5.10                                            */
/*      - Enh: Revised program to redisplay options program when     */
/*        F12=Cancel pressed when View option is selected.           */
/*    08/25/10  RH   5.30a                                     530a  */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*    01/14/09  RH   JORA CUSTOM JORDANO'S                           */
/*      - Only select X1 adjustments with qty > 0.                   */
/*    07/13/09  RH   JORA CUSTOM JORDANO'S                           */
/*      - FIX: QRYSLT was wrong for X1 selection.                    */
/*-------------------------------------------------------------------*/

 IT315CL:    PGM        PARM(&WHSE &RETURN &JOBQ &DEV &FORM &FMDT +
                            &TODT &VP &WHDP &SORT &ITEM &DISP &CODE)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (530aA) */

             DCL        VAR(&JORDANOS) TYPE(*CHAR) LEN(10) +
                          VALUE('JORDANOS  ')                     /* (JDO A) */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT315CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT315)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ITEMADJ)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(IT316APR)
             DCL        VAR(&PRTF2) TYPE(*CHAR) LEN(10) VALUE(IT316BPR)
             DCL        VAR(&PRTF3) TYPE(*CHAR) LEN(10) VALUE(IT316CPR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Inventory adjustments')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Inventory adjustments report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (530aA) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (530aA) */
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
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
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&CODE)       TYPE(*CHAR) LEN(2)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
                                                                  /* (530aA) */
/* Retrieve client id.                                               (530aA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (530aA) */
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

options:                                                          /* (510 A) */
             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &FMDT &TODT &VP &WHDP &SORT &ITEM +
                          &DISP &CODE)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
/*             RETURN                                                (510 D) */
               GOTO  CMDLBL(OUT)                                  /* (510 M) */
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &VP &WHDP +
                          &SORT &ITEM &DISP &CODE)) +
                          JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:  /* ( Chg 2.09 ) */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('IAWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('IADATE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('IADATE  +
                          *LE ' *CAT &TODT))
             IF         COND(&ITEM *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IAITEM  +
                          *EQ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)
             ENDDO
             IF         COND(&CODE *NE '  ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IACODE  +
                          *EQ' *BCAT &QUOTE *CAT &CODE *CAT &QUOTE)
             ENDDO
  /* JORDANO'S CUSTOM   */
             IF         COND(&CLIENT *EQ &JORDANOS)  THEN(DO)     /* (JOR A) */
             IF         COND(&CODE *EQ 'X1') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('(IAQTY1 +
                          *NE ' *CAT '0'))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
 /*          CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND') */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('IAQTY2  +
                          *NE ' *CAT '0)'))
               ENDDO
             ENDDO                                                /* (JOR A) */

  /* 4.13  Add code for department selection.       */
             IF         COND(&WHDP *NE '     ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IAWHDP +
                          *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF         COND(&DISP *NE *ALL) THEN(DO)
  /*         CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')   */
  /*         CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IAWHDP + */
  /*                      *EQ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)*/
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IADISP +
                          *EQ' *BCAT &QUOTE *CAT &DISP *CAT &QUOTE)
             ENDDO


   /* Use OPNQRYF to select and order the records we need */

  /* 4.15    IF (&SORT = '1') THEN(DO)                          */
             OVRDBF     FILE(IT316A) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (PIRITEM)) FORMAT(IT316A) +
                          QRYSLT(&QRYSLT) KEYFLD((ITEMADJ/IAWHSE) +
                          (ITEMADJ/IAITEM) (ITEMADJ/IADATE) +
                          (ITEMADJ/IATIME) (ITEMADJ/IADISP)) +
                          JFLD((ITEMADJ/IAWHSE +
                          PIRITEM/ITWHSE *EQ) (ITEMADJ/IAITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                          OPTIMIZE(*FIRSTIO) SEQONLY(*NO)
  /* 4.15    ENDDO                                                 */
  /*         IF (&SORT = '2') THEN(DO)                             */
  /*         OVRDBF     FILE(IT316B) TOFILE(&FILE) SHARE(*YES)     */
  /*         OPNQRYF    FILE((&FILE) (PIRITEM)) FORMAT(IT316B) +   */
  /*                      QRYSLT(&QRYSLT) KEYFLD((ITEMADJ/IAWHSE) +*/
  /*                      (ITEMADJ/IAITEM) (ITEMADJ/IADISP) +      */
  /*                      (ITEMADJ/IADATE) (ITEMADJ/IATIME)) +     */
  /*                      JFLD((ITEMADJ/IAWHSE +                   */
  /*                      PIRITEM/ITWHSE *EQ) (ITEMADJ/IAITEM +    */
  /*                      PIRITEM/ITITEM)) JDFTVAL(*YES) +         */
  /*                      OPTIMIZE(*FIRSTIO) SEQONLY(*NO)          */
  /*         ENDDO                                                 */
  /*         IF (&SORT = '3') THEN(DO)                             */
  /*         OVRDBF     FILE(IT316C) TOFILE(&FILE) SHARE(*YES)     */
  /*         OPNQRYF    FILE((&FILE) (PIRITEM)) FORMAT(IT316C) +   */
  /*                      QRYSLT(&QRYSLT) KEYFLD((ITEMADJ/IAWHSE) +*/
  /*                      (ITEMADJ/IADISP) (ITEMADJ/IADATE) +      */
  /*                      (ITEMADJ/IATIME)) +                      */
  /*                      JFLD((ITEMADJ/IAWHSE +                   */
  /*                      PIRITEM/ITWHSE *EQ) (ITEMADJ/IAITEM +    */
  /*                      PIRITEM/ITITEM)) JDFTVAL(*YES) +         */
  /*                      OPTIMIZE(*FIRSTIO) SEQONLY(*NO)          */
  /*         ENDDO                                                 */

/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE IT317 &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT317A +
                              IT317 &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT317B +
                              IT317 &MEMBER)
                CALL       PGM(GETWRKMEML) PARM(*REUSE IT317C +
                              IT317 &MEMBER)
             OVRDBF     FILE(IT317) TOFILE(*FILE) MBR(&MEMBER) +
                          SHARE(*YES)
             OVRDBF     FILE(IT317A) TOFILE(*FILE) MBR(&MEMBER) +
                          SHARE(*YES)
             OVRDBF     FILE(IT317B) TOFILE(*FILE) MBR(&MEMBER) +
                          SHARE(*YES)
             OVRDBF     FILE(IT317C) TOFILE(*FILE) MBR(&MEMBER) +
                          SHARE(*YES)

/*    - Add any link records, write QUERY file to physical file. */
             CALL       PGM(IT317P) PARM(&WHSE &FMDT &TODT &ITEM &DISP +
                        &CODE)

 VIEW:

             IF (&VP = 'V') THEN(DO)
             IF (&SORT = '1') THEN(DO)
             CALL       PGM(IT317A) PARM(&WHSE &FMDT &TODT &ITEM &DISP +
                        &CODE &RETURN)                            /* (510 M) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO

             IF (&SORT = '2') THEN(DO)
             CALL       PGM(IT317B) PARM(&WHSE &FMDT &TODT &ITEM &DISP +
                        &CODE &RETURN)                            /* (510 M) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO

             IF (&SORT = '3') THEN(DO)
             CALL       PGM(IT317C) PARM(&WHSE &FMDT &TODT &ITEM &DISP +
                        &CODE &RETURN)                            /* (510 M) */
/*             GOTO       CMDLBL(OUT)                                (510 D) */
             ENDDO
             IF         COND(&RETURN = '*CANCEL') THEN(DO)        /* (510 A) */
               CHGVAR     VAR(&RETURN) VALUE('        ')          /* (510 A) */
               DLTOVR     FILE(*ALL) LVL(*JOB)                    /* (510 A) */
               RCLRSC     LVL(*CALLER)                            /* (510 A) */
               MONMSG     MSGID(CPF9841)                          /* (510 A) */
               GOTO       CMDLBL(OPTIONS)                         /* (510 A) */
             enddo                                                /* (510 A) */
             ELSE       CMD(DO)                                   /* (510 A) */
               GOTO       CMDLBL(OUT)                             /* (510 A) */
             enddo                                                /* (510 A) */
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)


 /* REPORT:   ( Chg 2.09 ) */

   /* Override printer file. */

             IF (&SORT = '1') THEN(DO)
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT316A) PARM(&FMDT &TODT &ITEM &DISP &CODE)
             ENDDO

             IF (&SORT = '2') THEN(DO)
             OVRPRTF    FILE(&PRTF2) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT316B) PARM(&FMDT &TODT &ITEM &DISP &CODE)
             ENDDO

             IF (&SORT = '3') THEN(DO)
             OVRPRTF    FILE(&PRTF3) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(IT316C) PARM(&FMDT &TODT &ITEM &DISP &CODE)
             ENDDO

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

             DLTOVR     FILE(IT317)
             MONMSG     MSGID(CPF9841)             /* 415b A */
             DLTOVR     FILE(IT317A)
             MONMSG     MSGID(CPF9841)             /* 415b A */
             DLTOVR     FILE(IT317B)
             MONMSG     MSGID(CPF9841)             /* 415b A */
             DLTOVR     FILE(IT317C)
             MONMSG     MSGID(CPF9841)             /* 415b A */
             RCLRSC     LVL(*CALLER)
/*           CLRPFM     FILE(IT317) MBR(&MEMBER)                     (510 D) */
/*           MONMSG     MSGID(CPF3133 CPF3141)        415b A         (510 D) */
             RCLRSC     LVL(*CALLER)                              /* (510 A) */
             IF         COND(&MEMBER > ' ') THEN(DO)              /* (510 A) */
               RMVM       FILE(IT317A) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
               RMVM       FILE(IT317B) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
               RMVM       FILE(IT317C) MBR(&MEMBER)               /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
               RMVM       FILE(IT317) MBR(&MEMBER)                /* (510 A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                            CPF3273 CPF7301 CPF7310)              /* (510 A) */
             ENDDO                                                /* (510 A) */

             ENDPGM
