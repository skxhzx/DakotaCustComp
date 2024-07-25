/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SGC100CL    SPRINGFIELD TOTAL SALES                              */
/*  29 March 2011                                                    */
/*  Roxanne Harrsion                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    03/29/11  RH   6.40                                            */
/*      - Created - Custom for Springfield                           */
/*    03/30/11  GJA  6.40A                                           */
/*      - Enh: Change to use QRYSLT, sum total fields                */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SGC100CL:   PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&WHSE)       TYPE(*CHAR)  LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get report options. */

             CHGVAR     VAR(&WHDP) VALUE(' ')
             CHGVAR     VAR(&DISP) VALUE(' ')
             CLRPFM     FILE(SGCTLS)
   /* Qry reads 'ITEMSLS' file, sums item week totals, writes record. */
             OVRDBF     FILE(SGCAMTSUM) TOFILE(ITEMSLS) SHARE(*YES)
             OPNQRYF    FILE(ITEMSLS) FORMAT(SGCAMTSUM) +
                          KEYFLD((IHITEM)) GRPFLD(IHITEM) +
                          MAPFLD((AMTSUM '%SUM(IHTQSW)')) +
                          OPTIMIZE(*ALLIO)
             CALL       PGM(SGC100) PARM(&WHSE &WHDP)

 /* Receive any messages and pass them on */

 GETOUT:
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

   /* Clean up before leaving */

             DLTOVR     FILE(SGCAMTSUM)

             RCLRSC     LVL(*CALLER)

             ENDPGM
