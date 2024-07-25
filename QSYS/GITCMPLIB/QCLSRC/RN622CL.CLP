/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN622CL   RF-Return whole order w UCI                            */
/*  08 August 2007                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    08/08/07  RH   5.10                                            */
/*      -  Created for Packers using RN122                           */
/*    09/10/07  HNK  5.10a                                           */
/*      -  Add 3 parms &dlvy, &BILL and &PSLS                        */
/*-------------------------------------------------------------------*/

 RN622CL:    PGM        PARM(&WHSE &RETURN &LORD &MPUT &CODE +
                             &DCDE &USER &CORD &INVF &DLVY &BILL &PSLS)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN622CL)

  /*  OPNQRY file. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Return whole order')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&LORD)       TYPE(*CHAR) LEN(7)
             DCL        VAR(&MPUT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&CODE)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&DCDE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&CORD)       TYPE(*CHAR) LEN(7)
             DCL        VAR(&INVF)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')
             DCL        VAR(&DLVY)       TYPE(*CHAR) LEN(9)
             DCL        VAR(&BILL)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&PSLS)       TYPE(*CHAR) LEN(4)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBORD +
                           *EQ ' *CAT &LORD)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT  '(LBTYPE  +
                          *EQ "O" *OR LBTYPE *EQ "B")')
 /*          CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTYPE + */
 /*                        *EQ ' *CAT &QUOTE *CAT O *CAT &QUOTE)   */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBQPCK *GT' +
                          *BCAT '0')

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(RN622) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(RN622) +
                          QRYSLT(&QRYSLT) KEYFLD((*MAPFLD/LQLBL#)) +
                          MAPFLD((LQWHSE  LBWHSE) +
                                 (LQWHDP  LBWHDP) +
                                 (LQSEQ   LBSEQ) +
                                 (LQITEM  LBITEM) +
                                 (LQPBAT  LBPBAT) +
                                 (LQAISL  LBAISL) +
                                 (LQLOC   LBLOC) +
                                 (LQRLVL  LBRLVL) +
                                 (LQHAND  LBHAND) +
                                 (LQPSEQ  LBPSEQ) +
                                 (LQSTYP  LBSTYP) +
                                 (LQQRYF  LBQRYF) +
                                 (LQDISP  LBDISP) +
                                 (LQQAVL  LBQAVL) +
                                 (LQWHS2  LBWHS2) +
                                 (LQWHD2  LBWHD2) +
                                 (LQASL2  LBASL2) +
                                 (LQLOC2  LBLOC2) +
                                 (LQLVL2  LBLVL2) +
                                 (LQHND2  LBHND2) +
                                 (LQDSP2  LBDSP2) +
                                 (LQRTE   LBRTE) +
                                 (LQSTOP  LBSTOP) +
                                 (LQORD   LBORD) +
                                 (LQSPCL  LBSPCL) +
                                 (LQPO    LBPO) +
                                 (LQUTYP  LBUTYP) +
                                 (LQUCOD  LBUCOD) +
                                 (LQUCUB  LBUCUB) +
                                 (LQCUBE  LBCUBE) +
                                 (LQUWGT  LBUWGT) +
                                 (LQSWGT  LBSWGT) +
                                 (LQQALC  LBQALC) +
                                 (LQQRMN  LBQRMN) +
                                 (LQQPCK  LBQPCK) +
                                 (LQTIE   LBTIE) +
                                 (LQHIGH  LBHIGH) +
                                 (LQGRP1  LBGRP1) +
                                 (LQGRP2  LBGRP2) +
                                 (LQTYPE  LBTYPE) +
                                 (LQLBL#  LBLBL#) +
                                 (LQPAL#  LBPAL#) +
                                 (LQTRN#  LBTRN#) +
                                 (LQCTR#  LBCTR#) +
                                 (LQSTAT  LBSTAT) +
                                 (LQPRTY  LBPRTY) +
                                 (LQSDTE  LBSDTE) +
                                 (LQSTIM  LBSTIM) +
                                 (LQRDTE  LBRDTE) +
                                 (LQVRFY  LBVRFY) +
                                 )

   /* Call program to process return order */

             MSGBFC     MESSAGE('Processing return order')
             CALL       PGM(RN622) PARM(&WHSE &RETURN &LORD &MPUT +
                          &CODE &DCDE &USER &CORD &INVF &DLVY &BILL &PSLS)

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
