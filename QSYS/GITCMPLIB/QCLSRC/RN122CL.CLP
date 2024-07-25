/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN122CL   Return whole order                                     */
/*  18 June, 2002                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    12/15/03  RH   4.17                                            */
/*      -  FIX: Added LBTYPE = O TO QRYSLT.                          */
/*    04/18/06  RH   5.00                                            */
/*      -  FIX: Added LBTYPE = B TO QRYSLT.                          */
/*    05/04/09  MLB  5.20                                            */
/*      -  FIX: Added two new parms: Quick Return Y/N and Export     */
/*         Quick Returns Y/N.                                        */
/*    11/20/09  RH   5.30                                            */
/*      -  ENH: Added Memo field to parms.                           */
/*    10/28/11  GJA  6.40A                                           */
/*      -  ENH: Added Invoice number to parms.                       */
/*    06/24/20  LMC  7.40A                                           */
/*      -  ENH: Added packer org code to parms.                      */
/*    06/23/21  LMC  7.50A                                           */
/*      -  ENH: Added pltlcns and return label.                      */
/*-------------------------------------------------------------------*/

 RN122CL:    PGM        PARM(&WHSE &RETURN &LORD &MPUT &CODE &DCDE +
                          &USER &CORD &INVF &QUICK &REXQ &MEMO +
                          &INV# &PCKORG &PLTLCNS &PICKLABEL)
        /*                   &MEMO &INV#)                           (740aM) */
        /*                   &USER &CORD &INVF &QUICK &REXQ &MEMO)  (640 M) */
        /*                   &DCDE &USER &CORD &INVF &QUICK &REXQ)  (520 M) */
        /*                   &DCDE &USER &CORD &INVF)    */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN122CL)

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
             DCL        VAR(&MEMO)       TYPE(*CHAR) LEN(30)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')
             DCL        VAR(&QUICK)      TYPE(*CHAR) LEN(1)       /* (520 A) */
             DCL        VAR(&REXQ)       TYPE(*CHAR) LEN(1)       /* (520 A) */
             DCL        VAR(&INV#)       TYPE(*CHAR) LEN(9)       /* (640 A) */
             DCL        VAR(&PCKORG) TYPE(*DEC) LEN(4 0) /* (740 A) */
             DCL        VAR(&PLTLCNS) TYPE(*CHAR) LEN(10) /* (750 A) */
             DCL        VAR(&PICKLABEL) TYPE(*CHAR) LEN(10) /* (750 +
                          A) */

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

             OVRDBF     FILE(RN122) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(RN122) +
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
             CALL       PGM(RN122) PARM(&WHSE &RETURN &LORD &MPUT +
                          &CODE &DCDE &USER &CORD &INVF &QUICK +
                          &REXQ &MEMO &INV# &PCKORG &PLTLCNS +
                          &PICKLABEL)
   /*                   &REXQ &MEMO &INV#)                           740aM */
   /*                   &CODE &DCDE &USER &CORD &INVF &QUICK &REXQ + 6.40 */
   /*                   &MEMO)                                       6.40 */
   /*                   &CODE &DCDE &USER &CORD &INVF &MEMO)  5.20   */
   /*                   &CODE &DCDE &USER &CORD &INVF)               */
   /*        CPYFRMQRYF FROMOPNID(RN122) TOFILE(PIR900FRH/W1LABEL) + */
   /*                     MBROPT(*ADD) CRTFILE(*YES)                 */

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
