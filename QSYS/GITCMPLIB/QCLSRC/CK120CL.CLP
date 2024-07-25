/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK120CL   Checker Balance items                                  */
/*  23 October, 2001                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*  10/23/01  HNK  4.16                                              */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*  03/20/02 HNK 4.16a                                               */
/*    Fix - Add SEQONLY=*NO to open query statement.                 */
/*                                                                   */
/*  06/09/02 HNK 4.16b                                               */
/*    Fix -                                                          */
/*                                                                   */
/*  01/21/11 GJA 6.40a                                               */
/*    Fix - was not removing member on exit                          */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK120CL:    PGM        PARM(&WHSE &PRTID &PPLID &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Checker Balance items')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
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

/*           MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))  */
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBGRP1  +
                          *EQ ' *BCAT &QUOTE *CAT S *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRTE   +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')


             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBPAL#  +
                          *EQ ' *CAT &PPLID))

   /* 416b change */

             OVRDBF     FILE(LABEL90) SHARE(*YES)
             OPNQRYF    FILE((LABEL90)) QRYSLT(&QRYSLT)

             CALL       PGM(GETUNQMEM) PARM(*REUSE CK120A &MEMBER)
             OVRDBF     FILE(CK120A) MBR(&MEMBER) SHARE(*YES)

             CALL       PGM(CK120A)

             DLTOVR     FILE(LABEL90)

             OVRDBF     FILE(CK120) TOFILE(CK120A) MBR(&MEMBER) +
                          SHARE(*YES)

             OPNQRYF    FILE((CK120A) (CHKLBL)) FORMAT(CK120) +
                          KEYFLD((CK120A/WBLBL#)) +
                          JFLD((CK120A/WBWHSE CHKLBL/CLWHSE) +
                          (CK120A/WBLBL# CHKLBL/CLLBL#)) +
                          JDFTVAL(*ONLYDFT) SEQONLY(*NO)

             CALL       PGM(CK120) PARM(&WHSE &PRTID &PPLID &RETURN)



   /* 4.16B DELETE                                                 */

   /* Use OPNQRYF to select and order the records we need */

   /*        OVRDBF     FILE(CK120) TOFILE(LABEL) SHARE(*YES)      */
   /*        OPNQRYF    FILE((LABEL) (CHKLBL)) FORMAT(CK120) +     */
   /*                     QRYSLT(&QRYSLT) KEYFLD((LABEL/LBLBL#)) + */
   /*                     JFLD((LABEL/LBWHSE CHKLBL/CLWHSE) +      */
   /*                     (LABEL/LBLBL# CHKLBL/CLLBL#)) +          */
   /*                     JDFTVAL(*ONLYDFT) SEQONLY(*NO)           */

   /*        CALL       PGM(CK120) PARM(&WHSE &PRTID &PPLID &RETURN)*/


 /* Receive any messages and pass them on */

 GETOUT:

   /* Clean up before leaving */

   /* 6.40a  DLTOVR     FILE(CK120A)             */
             RCLRSC     LVL(*CALLER)
   /* 6.40a  CLRPFM     FILE(CK120A) MBR(&MEMBER)*/
   /* 6.40a Clean up file members before leaving */
             CLOF       OPNID(CK120A)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(CK120A) LVL(*JOB)
             MONMSG     MSGID(CPF9841)
             RMVM       FILE(CK120A) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
   /* 6.40a */

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

             ENDPGM
