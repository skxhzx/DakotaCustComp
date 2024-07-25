/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK394CL   Checker Item exceptions                                */
/*  30 October, 2001                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revision                                                         */
/*   06/20/02 HNK 4.16                                               */
/*     - Merge labels were incorrectly showing up in unchecked items */
/*       Fix by adding CK391A file and RPG program CK391A.           */
/*                                                                   */
/*   01/21/11 GJA 6.40a                                              */
/*     - Fix:  Remove member at exit.                                */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK394CL:    PGM        PARM(&PWHSE &PRTID &PPLID &PITEM)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PITEM)      TYPE(*CHAR) LEN(15)
             DCL        VAR(&PPGM)       TYPE(*CHAR) LEN(10) VALUE(CK394CL)
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

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &PWHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRTE  +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBPAL#  +
                          *EQ ' *CAT &PPLID))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBGRP1  +
                          *EQ ' *BCAT &QUOTE *CAT S *CAT &QUOTE))

   /* 416  change */

             OVRDBF     FILE(LABEL90) SHARE(*YES)
             OPNQRYF    FILE((LABEL90)) QRYSLT(&QRYSLT)

             CALL       PGM(GETUNQMEM) PARM(*REUSE CK391A &MEMBER)
             OVRDBF     FILE(CK391A) MBR(&MEMBER) SHARE(*YES)

             CALL       PGM(CK391A)

             DLTOVR     FILE(LABEL90)

             OVRDBF     FILE(CK391) TOFILE(CK391A) MBR(&MEMBER) +
                          SHARE(*YES)

             OPNQRYF    FILE((CK391A) (CHKLBL) (PIRTRAN)) +
                          FORMAT(CK391) KEYFLD((CK391A/WBLBL#)) +
                          JFLD((CK391A/WBWHSE CHKLBL/CLWHSE) +
                          (CK391A/WBLBL# CHKLBL/CLLBL#) +
                          (CK391A/WBTRN# PIRTRAN/PTTRN#)) +
                          JDFTVAL(*ONLYDFT) SEQONLY(*NO)

             CALL       PGM(CK392) PARM(&PWHSE &PRTID &PPLID &PPGM +
                          &RETURN)


   /* Use OPNQRYF to select and order the records we need */

   /*        OVRDBF     FILE(CK391) TOFILE(LABEL) SHARE(*YES)  */
   /*        OPNQRYF    FILE((LABEL) (CHKLBL)(PIRTRAN)) +      */
   /*                     FORMAT(CK391) QRYSLT(&QRYSLT) +      */
   /*                     KEYFLD((LABEL/LBLBL#)) +             */
   /*                     JFLD((LABEL/LBWHSE CHKLBL/CLWHSE) +  */
   /*                     (LABEL/LBLBL# CHKLBL/CLLBL#) +       */
   /*                     (LABEL/LBTRN# PIRTRAN/PTTRN#)) +     */
   /*                     JDFTVAL(*ONLYDFT)                    */

   /*        CALL       PGM(CK392) PARM(&PWHSE &PRTID &PPLID &PPGM +*/
   /*                     &RETURN)                                  */

/*  Clean up before leaving */

   /* 6.40a  DLTOVR     FILE(CK391A)               */
             RCLRSC     LVL(*CALLER)
   /* 6.40a  CLRPFM     FILE(CK391A) MBR(&MEMBER)  */
   /* 6.40a Clean up file members before leaving */
             CLOF       OPNID(CK391A)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(CK391A) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             RMVM       FILE(CK391A) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
   /* 6.40a */

             ENDPGM
