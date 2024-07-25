/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT951CL   Receipts by item                                       */
/*  24 May, 2005                                                     */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*  11/17/06  RAH  5.10                                              */
/*      Enh:  Remove inclusion of the POMFR file in OPNQRYF.  This   */
/*            only included items that were date sensitive.          */
/*  11/28/07  RH   5.10b                                             */
/*      Fix:  Change to include all records on join, was NOT         */
/*            including records if POREMP wasn't found in PIRUSER    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT951CL:    PGM        PARM(&WHSEA &PITEM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&PITEM)  TYPE(*CHAR) LEN(15)
             DCL        VAR(&WHSEA)  TYPE(*CHAR) LEN(3)
             DCL        VAR(&QUOTE)  TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT) TYPE(*CHAR) LEN(2000)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PORWHS *EQ +
                          ' *BCAT &WHSEA)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
/* 510 a */  CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBITEM *EQ +
                          ' *BCAT &QUOTE *CAT &PITEM *CAT &QUOTE)
/* 510 d     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PMITEM *EQ +
                          ' *BCAT &QUOTE *CAT &PITEM *CAT &QUOTE)    */

/*  510 d    OVRDBF     FILE(POMFR)  SHARE(*YES)                     */
/*  510 d    OVRDBF     FILE(IT951A) TOFILE(POMFR) SHARE(*YES)       */
/*  510 a */ OVRDBF     FILE(LABEL)  SHARE(*YES)
/*  510 a */ OVRDBF     FILE(IT951A) TOFILE(LABEL) SHARE(*YES)

/*  510 d    OPNQRYF    FILE((POMFR) (PORCV) (PIRUSER)) +
                          FORMAT(IT951A) QRYSLT(&QRYSLT) +
                          KEYFLD((PMITEM) (PORDTE *ASCEND)) +
                          JFLD((PMTRN# PORTRN) (POREMP USEMP#)) +
                          SEQONLY(*NO)                               */
             OPNQRYF    FILE((LABEL) (PORCV) (PIRUSER)) +
                          FORMAT(IT951A) QRYSLT(&QRYSLT) +
                          KEYFLD((PORDTE *ASCEND)) JFLD((LBWHSE +
                          PORWHS) (LBLBL# PORLBL) (POREMP USEMP#)) +
                          JDFTVAL(*YES) SEQONLY(*NO)


/*  On with the show ... */

REPEAT:
             CALL       PGM(IT951) PARM(&WHSEA &PITEM)

DONE:
/*  Clean up before leaving */

/* 510 d     CLOF       OPNID(POMFR)     */
/* 510 d    DLTOVR     FILE(POMFR)       */
/* 510 a */  CLOF       OPNID(LABEL)
/* 510 a */  DLTOVR     FILE(LABEL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
