             PGM        PARM(&UMSG)

             DCL        VAR(&UMSG) TYPE(*CHAR) LEN(3000)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA(&UMSG) +
                          TOMSGQ(*SYSOPR)

endpgm
