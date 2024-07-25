/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN123CL   Return whole order Auto Put Away                       */
/*  09 November, 2004                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    11/09/04   V5.0                                                */
/*      - Created using RN122                                        */
/*-------------------------------------------------------------------*/

 RN123CL:    PGM        PARM(&WHSE &RETURN &LORD &MPUT &CODE +
                             &DCDE &USER &CORD &INVF &PBAT)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RN123CL)

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
             DCL        VAR(&PBAT)       TYPE(*CHAR) LEN(7)
             DCL        VAR(&RPRT)       TYPE(*CHAR) LEN(1) VALUE('N')

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
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBQPCK *GT' +
                          *BCAT '0')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT  '(LBTYPE  +
                          *EQ "O" *OR LBTYPE *EQ "B")')
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBTYPE *EQ' +  */
/*                        *BCAT 'O')                                     */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBPBAT *NE' +
                          *BCAT &PBAT)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(RN123) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(RN123) +
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
   /*        CPYFRMQRYF FROMOPNID(RN122) TOFILE(PIR900FRH/W1LABEL) + */
   /*                     MBROPT(*ADD) CRTFILE(*YES)                 */

   /* Call program to process return order */

             MSGBFC     MESSAGE('Processing return order')
             CALL       PGM(RN123) PARM(&WHSE &RETURN &LORD &MPUT +
                        &CODE &DCDE &USER &CORD &INVF &PBAT)

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
