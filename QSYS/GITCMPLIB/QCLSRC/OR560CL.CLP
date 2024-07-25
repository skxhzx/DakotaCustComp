/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR560CL   Pallet summary report.                                 */
/*  15 October, 1994                                                 */
/*  Hemant Kapadia                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    12/09/94  DAS                                                  */
/*      - Ignoring LBITEM = '*PIRPICK'                               */
/*                                                                   */
/*    02/16/95  DAS                                                  */
/*      - Revised OPNQRYF to include the warehouse along with the    */
/*        item as join fields.                                       */
/*                                                                   */
/*    05/01/95  DAS  2.10                                            */
/*      - Revised OPNQRYF to join OHWHSE to ITWHSE.                  */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*  Notes:                                                           */
/*                                                                   */
/*    The OPNQRYF statement is used to select the records needed     */
/*    to print the pallet summary. It is also used to arrange the    */
/*    records so the PIR records will print with there corresponding */
/*    fixed pallet. The corresponding fixed pallet number is stored  */
/*    in field LBCTR# in the PIR records. To get this field to       */
/*    jump into the LBPAL# field so the records could be sorted      */
/*    correctly a MAPFLD calculation was done using the special      */
/*    numeric field LBQRYF which is 0 for fixed items and 1 for      */
/*    PIR items. The calculation assumes that LBCTR# is 0 for fixed  */
/*    records.                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR560CL:    PGM        PARM(&CMD &RTYPE &WHSE &BATCH &ROUTE &WHDP +
                          &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR560CL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR560PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Pallet Summary/Detail Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing pallet summary/detail report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&BATCHA)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&Q)          TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&ROUTE)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&BATCHA) VALUE(&BATCH)
             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE( +
                      'LBWHSE *EQ ' *CAT &WHSEA *BCAT +
                 '*AND LBPBAT *EQ ' *CAT &BATCHA *BCAT +
                 '*AND LBRTE  *EQ ' *CAT &Q *CAT &ROUTE *CAT &Q *BCAT +
                 '*AND LBTYPE *NE ' *CAT &Q *CAT 'R' *CAT &Q *BCAT +
                 '*AND LBITEM *NE ' *CAT &Q *CAT '*PIRPICK' *CAT &Q)

             IF         COND(&WHDP *NE ' ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND +
                          LBWHDP *EQ' *BCAT &Q *CAT &WHDP *CAT &Q)
             ENDDO

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR560) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (ORDH) (PIRITEM)) +
                        FORMAT(OR560) +
                        QRYSLT(&QRYSLT) +
                        KEYFLD((LABEL/LBPBAT) +
                               (LABEL/LBWHSE) +
                               (LABEL/LBRTE)  +
                               (LABEL/LBWHDP) +
                               (*MAPFLD/LQPAL#) +
                               (LABEL/LBSTOP) +
                               (LABEL/LBSEQ)  +
                               (LABEL/LBITEM) +
                               (LABEL/LBUCOD)) +
                        JFLD((LABEL/LBWHSE ORDH/OHWHSE) +
                             (LABEL/LBORD  ORDH/OHORD) +
                             (LABEL/LBWHSE PIRITEM/ITWHSE)  +
                             (LABEL/LBITEM PIRITEM/ITITEM)) +
                        JDFTVAL(*YES) +
                        MAPFLD((MFTEMP 'LBQRYF - 1') +
                               (FIXMULT '%ABSVAL(MFTEMP)') +
                               (LQPAL# 'LBPAL# * FIXMULT + LBCTR#')) +
                        OPTIMIZE(*FIRSTIO) +
                        SEQONLY(*NO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(OR560) PARM(&CMD &RTYPE)

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
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
