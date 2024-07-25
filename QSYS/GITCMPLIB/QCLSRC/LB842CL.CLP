/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LB842CL   Work with open labels for item                         */
/*  24 April 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    04/24/01  DAS  4.15                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LB842CL:    PGM        PARM(&CMD &WHSE &ITEM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRN#)       TYPE(*CHAR) LEN(7)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

   /*** NOTE: If change made to &QRYSLT, also change OPNIQTYCL ***/

             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(' ')
   /*        CHGVAR     VAR(&QRYSLT) VALUE('LBSTAT *NE ' *CAT &QUOTE + */
   /*                     *CAT 'C' *CAT &QUOTE)                        */
   /*        CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')       */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBWHSE +
                          *EQ ' *BCAT &WHSEA))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBITEM +
                          *EQ ' *CAT &QUOTE *CAT &ITEM *CAT &QUOTE))

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(LB842) TOFILE(LABEL12) SHARE(*YES)
             OPNQRYF    FILE((LABEL12)) OPTION(*ALL) FORMAT(LB842) +
                          QRYSLT(&QRYSLT) KEYFLD((LBLBL#))

             CALL       PGM(LB842) PARM(&CMD &WHSE &ITEM)

             DLTOVR     FILE(LB842)
             RCLRSC     *CALLER

             ENDPGM
