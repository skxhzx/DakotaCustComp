/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK365CL   Ship Check List                                        */
/*  21 August, 2003                                                  */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revision                                                         */
/*    08/21/03  RH   CBIa                                            */
/*      - Pass parms for printing, add OVRFLW and PAGRTT             */
/*                                                                   */
/*    12/16/03  HNK  CBIb                                            */
/*      - Use &PTRN# for printing one transaction only.              */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK365CL:    PGM        PARM(&PWHSE &PRTID &PDEV &PFORM &PTRN#)

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
             DCL        VAR(&PDEV)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&PFORM)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(CK365PR)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             IF (&PTRN# *GT '0000000') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE('LBTRN# *EQ ' *CAT &PTRN#)
             GOTO SKIP
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &PWHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBRTE  +
                          *EQ ' *BCAT &QUOTE *CAT &PRTID *CAT &QUOTE))

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LBGRP1  +
                          *EQ ' *BCAT &QUOTE *CAT S *CAT &QUOTE))

SKIP:
             OVRDBF     FILE(LABEL90) SHARE(*YES)
             OPNQRYF    FILE((LABEL90)) QRYSLT(&QRYSLT)

             CALL       PGM(GETUNQMEM) PARM(*REUSE CK365A &MEMBER)
             OVRDBF     FILE(CK365A) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(CK365A)

             DLTOVR     FILE(LABEL90)

             OVRDBF     FILE(CK365) TOFILE(CK365A) MBR(&MEMBER) +
                          SHARE(*YES)

             OPNQRYF    FILE((CK365A)) FORMAT(CK365) +
                          KEYFLD((CK365A/WBPAL#) (CK365A/WBDISP))

             OVRPRTF    FILE(&PRTF1) DEV(&PDEV) OUTQ(*DEV) +
                          FORMTYPE(&PFORM) OVRFLW(48) PAGRTT(90)

             CALL       PGM(CK365) PARM(&PWHSE &PRTID &PPGM +
                          &RETURN)


/*  Clean up before leaving */

             DLTOVR     FILE(CK365A)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(CK365A) MBR(&MEMBER)

             ENDPGM
