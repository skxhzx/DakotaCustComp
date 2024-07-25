/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RL500CL   Reprint Receiving Labels                               */
/*  20 February 1995                                                 */
/*  Max Blacknik - GFG Foodservice, Inc.                             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RL500CL:    PGM        PARM(&WHSE &BATCHNBR &FULLOUTQ)
             DCL        VAR(&WHSE) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&WHSEA) TYPE(*CHAR) LEN(3)
             DCL        VAR(&BATCHNBR) TYPE(*DEC) LEN(7 0)
             DCL        VAR(&BATCHA) TYPE(*CHAR) LEN(7)
             DCL        VAR(&FULLOUTQ) TYPE(*CHAR) LEN(20)
             DCL        VAR(&OUTQ) TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT) TYPE(*CHAR) LEN(1000) +

             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
             CHGVAR     VAR(&BATCHA) VALUE(&BATCHNBR)
             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSEA +
                          *BCAT '*AND LBPBAT *EQ ' *CAT &BATCHA)

             CHGVAR     VAR(&OUTQ) VALUE(%SST(&FULLOUTQ 1 10)) /* +
                          Extract OUTQ. */
             OVRDBF     FILE(LABEL) SHARE(*YES)
             OPNQRYF    FILE((LABEL)) QRYSLT(&QRYSLT) +
                          KEYFLD((LBWHSE) (LBPBAT) (LBTRN#)) +
                          OPTIMIZE(*MINWAIT)
             CALL       PGM(RL500) PARM(&WHSE &BATCHNBR &OUTQ)

             CLOF       OPNID(LABEL)
             MONMSG     MSGID(CPF4519 CPF4520)
             RCLRSC     LVL(*CALLER)

             ENDPGM
