/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK110CL   Checker Entry                                          */
/*  09 October, 2001                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*  10/09/01  HNK  4.16                                              */
/*                                                                   */
/*  Revisions:                                                       */
/*  06/21/02 HNK 4.16A                                               */
/*    RCLRSC BEFORE GOING BACK TO LABEL AGAIN                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK110CL:    PGM        PARM(&WHSE &WHDP &EMP# &PSHFT &PCREW &PRTID +
                          &PRTE &PPLID &PPAL# &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Checker entry')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PRTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PPAL#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PSHFT)      TYPE(*CHAR) LEN(6)
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
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  Get options. */

AGAIN:

             CALL       PGM(CK110) PARM(&WHSE &WHDP &EMP# &PSHFT +
                          &PCREW &PRTID &PRTE &PPLID &PPAL# &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
             GOTO       CMDLBL(GETOUT)
               ENDDO

/*  Otherwise, run program. */

 REPORT:


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


   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(LABEL31) SHARE(*YES)
             OPNQRYF    FILE((LABEL31)) QRYSLT(&QRYSLT) +
                          KEYFLD((LABEL31/LBWHSE))

             CALL       PGM(CK112) PARM(&WHSE &WHDP &EMP# &PSHFT +
                          &PCREW &PRTID &PRTE &PPLID &PPAL# &RETURN)

             RCLRSC     LVL(*CALLER)

             GOTO       CMDLBL(AGAIN)

 /* Receive any messages and pass them on */

 GETOUT:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

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
