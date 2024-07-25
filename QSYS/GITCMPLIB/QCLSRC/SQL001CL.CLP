/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SQL001CL  Run SQL statement - MC 2/92                            */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*-------------------------------------------------------------------*/

 SQL001CL:   PGM        PARM(&STM &OUTPUT &OUTFILE &OUTMBR)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBROPT)  TYPE(*CHAR) LEN(8)
             DCL        VAR(&OUTFILE) TYPE(*CHAR) LEN(20)
             DCL        VAR(&OUTMBR)  TYPE(*CHAR) LEN(20)
             DCL        VAR(&OUTPUT)  TYPE(*CHAR) LEN(8)
             DCL        VAR(&STM)     TYPE(*CHAR) LEN(1280)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Validate input */

             IF         COND(&OUTPUT *EQ '*OUTFILE') THEN(DO)
             CHGVAR     VAR(&FILE) VALUE(%SST(&OUTFILE 1 10))
             CHGVAR     VAR(&LIB) VALUE(%SST(&OUTFILE 11 10))
             CHGVAR     VAR(&MBR) VALUE(%SST(&OUTMBR 3 10))
             CHGVAR     VAR(&MBROPT) VALUE(%SST(&OUTMBR 13 8))
             IF         COND(&LIB *NE '*CURLIB' *AND &LIB *NE +
                          '*LIBL') THEN(DO)
             CHKOBJ     OBJ(&LIB) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('Output +
                          library' *BCAT &LIB *BCAT 'not found') +
                          MSGTYPE(*ESCAPE)
             RETURN
             ENDDO
             ENDDO
             ENDDO

/* Run QM query */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE('Processing SQL statement')
             IF         COND(&OUTPUT *EQ '*OUTFILE') THEN(DO)
             STRQMQRY   QMQRY(SQL001QQ) OUTPUT(&OUTPUT) +
                          OUTFILE(&LIB/&FILE) OUTMBR(&MBR &MBROPT) +
                          SETVAR((A %SST(&STM 1 50)) (B %SST(&STM +
                          51 50)) (C %SST(&STM 101 50)) (D +
                          %SST(&STM 151 50)) (E %SST(&STM 201 50)) +
                          (F %SST(&STM 251 50)) (G %SST(&STM 301 +
                          50)) (H %SST(&STM 351 50)) (I %SST(&STM +
                          401 50)) (J %SST(&STM 451 50)) (K +
                          %SST(&STM 501 50)) (L %SST(&STM 551 50)) +
                          (M %SST(&STM 601 50)) (N %SST(&STM 651 +
                          50)) (O %SST(&STM 701 50)) (P %SST(&STM +
                          751 50)) (Q %SST(&STM 801 50)) (R +
                          %SST(&STM 851 50)) (S %SST(&STM 901 50)) +
                          (T %SST(&STM 951 50)) (U %SST(&STM 1001 +
                          50)) (V %SST(&STM 1051 50)) (W %SST(&STM +
                          1101 50)) (X %SST(&STM 1151 50)) (Y +
                          %SST(&STM 1201 50)) (Z %SST(&STM 1251 30)))
             MONMSG     MSGID(CPF0000) EXEC(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('Errors +
                          found in SQL statement. See detailed +
                          messages.') MSGTYPE(*ESCAPE)
             RETURN
             ENDDO
             ENDDO
             ELSE       CMD(DO)
             STRQMQRY   QMQRY(SQL001QQ) OUTPUT(&OUTPUT) SETVAR((A +
                          %SST(&STM 1 50)) (B %SST(&STM 51 50)) (C +
                          %SST(&STM 101 50)) (D %SST(&STM 151 50)) +
                          (E %SST(&STM 201 50)) (F %SST(&STM 251 +
                          50)) (G %SST(&STM 301 50)) (H %SST(&STM +
                          351 50)) (I %SST(&STM 401 50)) (J +
                          %SST(&STM 451 50)) (K %SST(&STM 501 50)) +
                          (L %SST(&STM 551 50)) (M %SST(&STM 601 +
                          50)) (N %SST(&STM 651 50)) (O %SST(&STM +
                          701 50)) (P %SST(&STM 751 50)) (Q +
                          %SST(&STM 801 50)) (R %SST(&STM 851 50)) +
                          (S %SST(&STM 901 50)) (T %SST(&STM 951 +
                          50)) (U %SST(&STM 1001 50)) (V %SST(&STM +
                          1051 50)) (W %SST(&STM 1101 50)) (X +
                          %SST(&STM 1151 50)) (Y %SST(&STM 1201 +
                          50)) (Z %SST(&STM 1251 30)))
             MONMSG     MSGID(CPF0000) EXEC(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('Errors +
                          found in SQL statement. See detailed +
                          messages.') MSGTYPE(*ESCAPE)
             RETURN
             ENDDO
             ENDDO

             ENDPGM
