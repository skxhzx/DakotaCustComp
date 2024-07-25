/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR662CL   Pallet summary report. (Custom for CBI)                */
/*  01 Aug, 2003                                                     */
/*  Hemant Kapadia                                                   */
/*  Dave Sommerville                                                 */
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
/*    08/01/03  HNK                                                  */
/*      -  Created using OR660CL                                     */
/*                                                                   */
/*    12/18/03  HNK                                                  */
/*      -  Changed to print one copy on LP02 and one on LP11         */
/*    01/16/06  RH                                                   */
/*      -  Changed to use WORKLBL and PRINT and not print to LP02    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR662CL:    PGM        PARM(&CMD &RTYPE &WHSEA &RTID &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR662CL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PLTSUM)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR662PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Pallet Summary/Detail Report (PRD)')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing pallet summary/detail (PRD) report')

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

   /* Select label type  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LWTYPE +
                          *NE ' *CAT &Q *CAT 'R' *CAT &Q)
  /* 4.16 Change */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LWTRN# +
                          *NE ' *CAT '0')
  /* 4.16A Change */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LWTYPE +
                          *NE ' *CAT &Q *CAT 'M' *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select department */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LWTZON +
                          *EQ ' *CAT &Q *CAT 'PRD  ' *CAT &Q)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR662) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (WORKLBL) (ORDH) (PIRITEM)) +
                        FORMAT(OR662) QRYSLT(&QRYSLT) +
                        KEYFLD((&FILE/PSWHSE) (&FILE/PSRTID) +
                          (&FILE/PSCOMP) (&FILE/PSUNLD) +
                          (&FILE/PSPLID) +
                          (WORKLBL/LWSTOP) (WORKLBL/LWSEQ) +
                          (WORKLBL/LWITEM) (WORKLBL/LWUCOD)) +
                        JFLD((&FILE/PSWHSE WORKLBL/LWWHSE) +
                          (&FILE/PSRTID WORKLBL/LWRTE) (&FILE/PSPLID +
                          WORKLBL/LWPAL#) (WORKLBL/LWWHSE ORDH/OHWHSE) +
                          (WORKLBL/LWORD ORDH/OHORD) (WORKLBL/LWWHSE +
                          PIRITEM/ITWHSE) (WORKLBL/LWITEM +
                          PIRITEM/ITITEM)) JDFTVAL(*YES) +
                        OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

   /*        OVRPRTF    FILE(OR662PR) DEV(LP02) PAGRTT(90) OUTQ(*DEV)   */
             OVRPRTF    FILE(OR662PR) DEV(LP11) PAGRTT(90) OUTQ(*DEV)
             CALL       PGM(OR662) PARM(&CMD &RTYPE)

             OVRPRTF    FILE(OR662PR) DEV(LP11) PAGRTT(90) OUTQ(*DEV)
             OPNDBF     FILE(OR662) OPTION(*INP)
             POSDBF     OPNID(OR662) POSITION(*START)
             CALL       PGM(OR662) PARM(&CMD &RTYPE)

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
