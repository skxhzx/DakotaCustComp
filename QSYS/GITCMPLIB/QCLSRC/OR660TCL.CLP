/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR660TCL   Truck Pallet Tote Report.                             */
/*  17 March, 2006                                                   */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/31/13  RBD  6.50                                            */
/*      - Enh: Changed key field for stop from label stop to         */
/*        stop/drop from RTESTP file.                                */
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

 OR660TCL:   PGM        PARM(&CMD &RTYPE &WHSEA &RTID &RETURN &DEV +
                          &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR660TCL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PLTSUM)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR660TPR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Truck Pallet Tote Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Truck Pallet Tote report')

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
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */


   /* Select warehouse  */
             CHGVAR     VAR(&QRYSLT) VALUE('PSWHSE *EQ ' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select route ID   */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSRTID +
                          *EQ ' *CAT &Q *CAT &RTID *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select type       */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(PSTYPE +
                          *EQ ' *CAT &Q *CAT 'O' *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSTYPE +
                          *EQ ' *CAT &Q *CAT 'B' *CAT &Q *BCAT ')')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select generation  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSGEN=1')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select label type  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTYPE +
                          *NE ' *CAT &Q *CAT 'R' *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTRN# +
                          *NE ' *CAT '0')

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR660T) TOFILE(&FILE) SHARE(*YES)
 /*          OPNQRYF    FILE((&FILE) (LABEL) (ORDH) (PIRITEM)) +
                        FORMAT(OR660T) QRYSLT(&QRYSLT) +
                        KEYFLD((&FILE/PSWHSE) (&FILE/PSRTID) +
                          (&FILE/PSCOMP) (&FILE/PSUNLD) +
                          (&FILE/PSPLID) +
                          (LABEL/LBSTOP) (LABEL/LBSEQ) +
                          (LABEL/LBITEM) (LABEL/LBUCOD)) +
                        JFLD((&FILE/PSWHSE LABEL/LBWHSE) +
                          (&FILE/PSRTID LABEL/LBRTE) (&FILE/PSPLID +
                          LABEL/LBPAL#) (LABEL/LBWHSE ORDH/OHWHSE) +
                          (LABEL/LBORD ORDH/OHORD) (LABEL/LBWHSE +
                          PIRITEM/ITWHSE) (LABEL/LBITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                        OPTIMIZE(*FIRSTIO)                           (650 D) */

             OPNQRYF    FILE((&FILE) (LABEL) (ORDH) (PIRITEM) (RTESTP)) +
                        FORMAT(OR660T) QRYSLT(&QRYSLT) +
                        KEYFLD((&FILE/PSWHSE) (&FILE/PSRTID) +
                          (&FILE/PSCOMP) (&FILE/PSUNLD) +
                          (&FILE/PSPLID) +
                          (RTESTP/RTSSD) (LABEL/LBSEQ) +
                          (LABEL/LBITEM) (LABEL/LBUCOD)) +
                        JFLD((&FILE/PSWHSE LABEL/LBWHSE) +
                          (&FILE/PSRTID LABEL/LBRTE) (&FILE/PSPLID +
                          LABEL/LBPAL#) (LABEL/LBWHSE ORDH/OHWHSE) +
                          (LABEL/LBORD ORDH/OHORD) (LABEL/LBWHSE +
                          PIRITEM/ITWHSE) (LABEL/LBITEM PIRITEM/ITITEM) +
                          (LABEL/LBRTE RTESTP/RTSRID)  +
                          (LABEL/LBSTOP RTESTP/RTSSTP)) JDFTVAL(*YES) +
                        OPTIMIZE(*FIRSTIO)                        /* (650 M) */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(OR660T) PARM(&CMD &RTYPE &DEV &FORM)

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
