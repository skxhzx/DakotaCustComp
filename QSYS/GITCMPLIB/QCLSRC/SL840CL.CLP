/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL840CL   Display open labels for slot                           */
/*  11 March 2004                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    03/11/04  RH   4.17                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL840CL:    PGM        PARM(&CMD &WHSE &WHDP &DISP)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
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

   /*** NOTE: If change made to &QRYSLT, also change OPNSQTYCL ***/

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

             OVRDBF     FILE(SL840) TOFILE(LABEL12) SHARE(*YES)
             OPNQRYF    FILE((LABEL12)) OPTION(*ALL) FORMAT(SL840) +
                          QRYSLT(&QRYSLT) KEYFLD((LBLBL#))

             CALL       PGM(SL840) PARM(&CMD &WHSE &WHDP &DISP)

             DLTOVR     FILE(SL840)
             RCLRSC     *CALLER

             ENDPGM
