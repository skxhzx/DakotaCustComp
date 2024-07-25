/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OPNSQTYCL  Calculate open slot quantities                        */
/*  24 April 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    04/24/01  DAS  4.15                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OPNSQTYCL:  PGM        PARM(&WHSE &WHDP &DISP &QALC1 &QALC2 &QALC3 +
                          &QTFR1 &QTFR2 &QTFR3 &QPCK1 &QPCK2 &QPCK3 +
                          &QRCV1 &QRCV2 &QRCV3 &QUNK1 &QUNK2 &QUNK3)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QALC1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QALC2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QALC3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QPCK1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QPCK2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QPCK3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QRCV1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QRCV2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QRCV3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QTFR1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QTFR2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QTFR3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QUNK1)      TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&QUNK2)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QUNK3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRN#)       TYPE(*CHAR) LEN(7)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

   /*** NOTE: If change made to &QRYSLT, also change LB841 ***/

             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(' ')
   /*        CHGVAR     VAR(&QRYSLT) VALUE('LBSTAT *NE ' *CAT &QUOTE + */
   /*                     *CAT 'C' *CAT &QUOTE)                        */
   /*        CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')       */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBWHSE +
                          *EQ ' *BCAT &WHSEA))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBWHDP +
                          *EQ ' *CAT &QUOTE *CAT &WHDP *CAT &QUOTE))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBDISP +
                          *EQ ' *CAT &QUOTE *CAT &DISP *CAT &QUOTE))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ')')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '(')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBWHS2 +
                          *EQ ' *BCAT &WHSEA))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBWHD2 +
                          *EQ ' *CAT &QUOTE *CAT &WHDP *CAT &QUOTE))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBDSP2 +
                          *EQ ' *CAT &QUOTE *CAT &DISP *CAT &QUOTE))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ')')

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(LB841) TOFILE(LABEL12) SHARE(*YES)
             OPNQRYF    FILE((LABEL12)) OPTION(*INP) FORMAT(LB841) +
                          QRYSLT(&QRYSLT)

             CALL       PGM(OPNSQTY) PARM(&WHSE &WHDP &DISP &QALC1 +
                          &QALC2 &QALC3 &QTFR1 &QTFR2 &QTFR3 &QPCK1 +
                          &QPCK2 &QPCK3 &QRCV1 &QRCV2 &QRCV3 &QUNK1 +
                          &QUNK2 &QUNK3)

             DLTOVR     FILE(LB841)
             RCLRSC     *CALLER

             ENDPGM
