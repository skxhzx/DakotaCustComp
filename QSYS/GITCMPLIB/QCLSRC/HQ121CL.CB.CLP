/*-------------------------------------------------------------------*/
/*                                                                   */
/*  HQ121CL   Custom program for Cheney to update pick slot qty      */
/*            derieved from host total qty.                          */
/*  17 April, 2002                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions:                                                       */
/*  11/01/07  MLB  5.10                                              */
/*    - Revised program to add OVRDBF to LABEL file to set           */
/*      SEQONLY(*NO) to eliminate CPF4028 error which filled up      */
/*      joblog causing HQ121CL to end abnormally.                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 HQ121CL:    PGM        PARM(&WHSE &WHDP &AISLE &MEMBER &OUTQ &FORM)


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&AISLE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RPT)        TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
/*-------------------------------------------------------------------*/

/*  On with the show ... */


   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)

             IF (&WHDP *NE 'ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF (&AISLE *NE 'ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL *EQ +
                          ' *BCAT &QUOTE *CAT &AISLE *CAT &QUOTE)
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK *EQ +
                          ' *BCAT &QUOTE *CAT Y *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLITEM *NE +
                          ' *BCAT &QUOTE *CAT &QUOTE)

   /* Override printer file. */

             OVRPRTF    FILE(HQ121PR) OUTQ(&OUTQ) FORMTYPE(&FORM)

   /* Override Database file. */

             OVRDBF     FILE(IMPFPQTY) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(LABEL) SEQONLY(*NO)                  /* (510 A) */
             OVRDBF     FILE(SLOT1) SHARE(*YES)

             OPNQRYF    FILE((SLOT1)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((SLOT1/SLWHSE) (SLOT1/SLWHDP) +
                          (SLOT1/SLDISP)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)

 /* PRINT ALL */

             CALL       PGM(HQ121) PARM(&WHDP &AISLE)


/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
