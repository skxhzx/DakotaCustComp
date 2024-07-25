/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR667CL   Truck Pallet Dtl rpt Loader Merge Compartments:        */
/*            1,2,C,H,I,O,X                                          */
/*                                                                   */
/*  July 10, 2006                                                    */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
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
/*    This a copy of Clp 'OR664CL'                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR667CL:    PGM        PARM(&CMD &RTYPE &WHSEA &RTID &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR667CL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PLTSUM)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR667PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Pallet Detail Report (MergeC)')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing pallet detail report (MergeC)')

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

   /* Select type  4.16 Change */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(PSTYPE +
                          *EQ ' *CAT &Q *CAT 'O' *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSTYPE +
                          *EQ ' *CAT &Q *CAT 'B' *CAT &Q *BCAT ')')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select generation  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSGEN=1')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select compartment */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSCOMP +
                          *NE ' *CAT &Q *CAT 'D' *CAT &Q)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSCOMP +
                          *NE ' *CAT &Q *CAT 'F' *CAT &Q)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSCOMP +
                          *NE ' *CAT &Q *CAT 'P' *CAT &Q)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSCOMP +
                          *NE ' *CAT &Q *CAT 'R' *CAT &Q)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSCOMP +
                          *NE ' *CAT &Q *CAT '3' *CAT &Q)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
   /* Select label type  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTYPE +
                          *NE ' *CAT &Q *CAT 'R' *CAT &Q)
  /* 4.16 Change */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTRN# +
                          *NE ' *CAT '0')

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR667) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (LABEL) (ORDH) (PIRITEM)) +
                        FORMAT(OR667) QRYSLT(&QRYSLT) +
                        KEYFLD((&FILE/PSWHSE) (&FILE/PSRTID) +
                          (&FILE/PSCOMP) (&FILE/PSUNLD) +
                          (&FILE/PSPLID) +
                          (LABEL/LBSTOP) (LABEL/LBDISP) (LABEL/LBSEQ) +
                          (LABEL/LBITEM) (LABEL/LBUCOD)) +
                        JFLD((&FILE/PSWHSE LABEL/LBWHSE) +
                          (&FILE/PSRTID LABEL/LBRTE) (&FILE/PSPLID +
                          LABEL/LBPAL#) (LABEL/LBWHSE ORDH/OHWHSE) +
                          (LABEL/LBORD ORDH/OHORD) (LABEL/LBWHSE +
                          PIRITEM/ITWHSE) (LABEL/LBITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                        OPTIMIZE(*FIRSTIO)



             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 /* Print file overflow line is 45        */

             OVRPRTF    FILE(OR667PR) DEV(LP10) PAGRTT(90) OUTQ(*DEV) +
                        COPIES(1)
             CALL       PGM(OR667) PARM(&CMD &RTYPE)

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
