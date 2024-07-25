/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK392CL   Checker pallet details by route                        */
/*  29 October, 2001                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  05/10/02 HNK 4.16                                              */
/*    Fix - Add SEQONLY=*NO to open query statement.                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK392CL:    PGM        PARM(&WHSE &PRTID &PPLID &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PPGM)       TYPE(*CHAR) LEN(10) VALUE(CK392CL)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/
   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('CLWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('CLRTID  +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')


             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('CLPLID  +
                          *EQ ' *CAT &PPLID))


   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(CK391) TOFILE(CHKLBL) SHARE(*YES)
             OPNQRYF    FILE((CHKLBL) (LABEL) (PIRTRAN)) +
                          FORMAT(CK391) QRYSLT(&QRYSLT) +
                          KEYFLD((CHKLBL/CLLBL#)) +
                          JFLD((CHKLBL/CLWHSE LABEL/LBWHSE) +
                          (CHKLBL/CLLBL# LABEL/LBLBL#) +
                          (LABEL/LBTRN# PIRTRAN/PTTRN#)) +
                          JDFTVAL(*YES) MAPFLD((WBWHSE LBWHSE) +
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
                                 (WBVRFY  LBVRFY) +
                           ) SEQONLY(*NO)


             CALL       PGM(CK392) PARM(&WHSE &PRTID &PPLID &PPGM +
                          &RETURN)



GETOUT:
/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
