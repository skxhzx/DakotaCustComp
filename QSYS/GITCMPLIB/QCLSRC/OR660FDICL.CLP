/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR660CL   Pallet Detail report for Bulk Picks in aisles          */
/*            14, 17, 18 and 22.                                     */
/*  04 May 2009                                                      */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/04/09  MLB  5.20                                            */
/*      -  Created.                                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*    This program is a copy of OR660CL that is used to list out     */
/*    Bulk Picks in aisles: 14, 17, 18 and 22 on rack levels > 2.    */
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

 OR660FDICL:    PGM      PARM(&CMD &RTYPE &WHSEA &RTID &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR660FDICL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PLTSUM)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR660PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Pallet Detail Report Bulk Picks')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing pallet detail report Bulk Picks')

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
             CHGVAR     VAR(&QRYSLT) VALUE('PSWHSE=' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select route ID   */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSRTID=' +
                         *CAT &Q *CAT &RTID *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select pallet types. */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(PSTYPE=' +
                          *CAT &Q *CAT 'O' *CAT &Q)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSTYPE=' +
                          *CAT &Q *CAT 'B' *CAT &Q *BCAT ')')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select generation  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PSGEN=1')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

  /* Aisles to select. */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBAISL = +
                          %VALUES(" 14" " 17" " 18" " 22")')

  /* Rack levels to select. */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBRLVL +
                          >=3')
   /* Select label type  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(LBTYPE +
                          =' *CAT &Q *CAT 'O' *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTYPE +
                          =' *CAT &Q *CAT 'B' *CAT &Q *CAT ')')

  /* Valid transactions. */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTRN# +
                         *NE ' *CAT '0')

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR660) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (LABEL13) (ORDH) (PIRITEM)) +
                        FORMAT(OR660) QRYSLT(&QRYSLT) +
                        KEYFLD((&FILE/PSWHSE) (&FILE/PSRTID) +
                          (&FILE/PSCOMP) +
                          (LABEL13/LBAISL) (LABEL13/LBDISP) +
                          (LABEL13/LBITEM) (LABEL13/LBUCOD)) +
                        JFLD((&FILE/PSWHSE LABEL13/LBWHSE) +
                          (&FILE/PSRTID LABEL13/LBRTE) (&FILE/PSPLID +
                          LABEL13/LBPAL#) (LABEL13/LBWHSE ORDH/OHWHSE) +
                          (LABEL13/LBORD ORDH/OHORD) (LABEL13/LBWHSE +
                          PIRITEM/ITWHSE) (LABEL13/LBITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                        OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(OR660) PARM('*BULK' &RTYPE &DEV &FORM)

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
