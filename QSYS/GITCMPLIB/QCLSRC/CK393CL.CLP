/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK393CL   Items details by pallet                                */
/*  30 October, 2001                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revision                                                         */
/*  08/30/02 HNK 4.16                                                */
/*   - Map fields                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK393CL:    PGM        PARM(&PWHSE &PRTID &PPLID &PITEM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PITEM)      TYPE(*CHAR) LEN(15)
             DCL        VAR(&PPGM)       TYPE(*CHAR) LEN(10) VALUE(CK393CL)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PTRN#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('CLWHSE *EQ ' *CAT &PWHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('CLRTID  +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('CLPLID  +
                          *EQ ' *CAT &PPLID))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBITEM  +
                          *EQ ' *BCAT &QUOTE *CAT &PITEM *CAT &QUOTE))


   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(CK391) TOFILE(CHKLBL) SHARE(*YES)
             OPNQRYF    FILE((CHKLBL) (LABEL) (PIRTRAN)) +
                          FORMAT(CK391) QRYSLT(&QRYSLT) +
                          KEYFLD((CHKLBL/CLLBL#)) +
                          JFLD((CHKLBL/CLWHSE LABEL/LBWHSE) +
                          (CHKLBL/CLLBL# LABEL/LBLBL#) +
                          (LABEL/LBTRN# PIRTRAN/PTTRN#)) +
                          JDFTVAL(*YES) +
                          MAPFLD((WBWHSE LBWHSE) +
                                 (WBWHDP LBWHDP) +
                                 (WBSEQ   LBSEQ) +
                                 (WBITEM  LBITEM) +
                                 (WBPBAT  LBPBAT) +
                                 (WBAISL  LBAISL) +
                                 (WBLOC   LBLOC) +
                                 (WBRLVL  LBRLVL) +
                                 (WBHAND  LBHAND) +
                                 (WBPSEQ  LBPSEQ) +
                                 (WBSTYP  LBSTYP) +
                                 (WBQRYF  LBQRYF) +
                                 (WBDISP  LBDISP) +
                                 (WBQAVL  LBQAVL) +
                                 (WBWHS2  LBWHS2) +
                                 (WBWHD2  LBWHD2) +
                                 (WBASL2  LBASL2) +
                                 (WBLOC2  LBLOC2) +
                                 (WBLVL2  LBLVL2) +
                                 (WBHND2  LBHND2) +
                                 (WBDSP2  LBDSP2) +
                                 (WBRTE   LBRTE) +
                                 (WBSTOP  LBSTOP) +
                                 (WBORD   LBORD) +
                                 (WBSPCL  LBSPCL) +
                                 (WBPO    LBPO) +
                                 (WBUTYP  LBUTYP) +
                                 (WBUCOD  LBUCOD) +
                                 (WBUCUB  LBUCUB) +
                                 (WBCUBE  LBCUBE) +
                                 (WBUWGT  LBUWGT) +
                                 (WBSWGT  LBSWGT) +
                                 (WBQALC  LBQALC) +
                                 (WBQRMN  LBQRMN) +
                                 (WBQPCK  LBQPCK) +
                                 (WBTIE   LBTIE) +
                                 (WBHIGH  LBHIGH) +
                                 (WBGRP1  LBGRP1) +
                                 (WBGRP2  LBGRP2) +
                                 (WBTYPE  LBTYPE) +
                                 (WBLBL#  LBLBL#) +
                                 (WBPAL#  LBPAL#) +
                                 (WBTRN#  LBTRN#) +
                                 (WBCTR#  LBCTR#) +
                                 (WBSTAT  LBSTAT) +
                                 (WBPRTY  LBPRTY) +
                                 (WBSDTE  LBSDTE) +
                                 (WBSTIM  LBSTIM) +
                                 (WBRDTE  LBRDTE) +
                                 (WBVRFY  LBVRFY))


             CALL       PGM(CK392) PARM(&PWHSE &PRTID &PPLID &PPGM +
                          &RETURN)



GETOUT:
/*  Clean up before leaving */
             DLTOVR     FILE(CK391)
             RCLRSC     LVL(*CALLER)

             ENDPGM
