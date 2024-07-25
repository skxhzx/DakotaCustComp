/*-------------------------------------------------------------------*/
/*                                                                   */
/*  #CRTOUTQ  - Create OUTQ for WRKRMTWTR command                    */
/*  26 December  2007                                                */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    12/26/07  JCJ  5.10                                            */
/*      - Copied off the internet                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
pgm
             DCL        VAR(&NUM) TYPE(*DEC) LEN(4 0) VALUE(1)
             DCL        VAR(&CHR) TYPE(*CHAR) LEN(4)
             DCL &O *CHAR 10
        LOOP:
             IF         COND(&NUM < 7111) THEN(DO)
             CHGVAR     VAR(&NUM) VALUE(&NUM + 1)
             CHGVAR     VAR(&CHR) VALUE(&NUM)
             CHGVAR     VAR(&O) VALUE('AZV' || &CHR)
             CRTOUTQ    OUTQ(OUTQ1/&O)    RMTSYS(*INTNETADR) +
                          RMTPRTQ('XXXXXXXXXXXXXXX') CNNTYPE(*IP) +
                          DESTTYPE(*OTHER) INTNETADR('1.2.3.4')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA(&O) +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)
     GOTO LOOP
        ENDDO
      END:
          WRKRMTWTR
ENDPGM
