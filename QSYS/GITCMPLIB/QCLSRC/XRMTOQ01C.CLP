/*-------------------------------------------------------------------*/
/*                                                                   */
/*  XRMTOQ01C - Just testing the API'S in WRKRMTWTR                  */
/*  26 December  2007                                                */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    12/26/07  JCJ  5.10                                            */
/*      - Copied off the internet                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
             PGM
             DCL        VAR(&O) TYPE(*CHAR) LEN(1000)
             DCL        VAR(&OBJ) TYPE(*CHAR) LEN(20)
             DCL        VAR(&D) TYPE(*CHAR) LEN(8) VALUE(X'000003E8')
             DCL        VAR(&IP) TYPE(*CHAR) LEN(8) VALUE(X'00000002')
             DCLF       FILE(QADSPOBJ)
             DLTF       FILE(QTEMP/OUTQS)
             MONMSG     MSGID(CPF0000)
             DSPOBJD    OBJ(*ALL/*ALL) OBJTYPE(*OUTQ) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/OUTQS)
             OVRDBF     FILE(QADSPOBJ) TOFILE(QTEMP/OUTQS)
LOOP:
             RCVF
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(END))
             CHGVAR     VAR(&OBJ) VALUE(&ODOBNM || &ODLBNM)
             CALL       PGM(QSPROUTQ) PARM(&O &D 'OUTQ0100' &OBJ +
                          X'00000000')
             IF         COND(%SST(&O 621 4) *EQ &IP) THEN(DO)
             SNDPGMMSG  MSG(&ODOBNM *BCAT ' ' *BCAT &ODLBNM *BCAT ' +
                          ' *BCAT %SST(&O 218 20) *BCAT %SST(&O 97 +
                          10) *BCAT %SST(&O 133 10) *BCAT %SST(&O +
                          473 10) *BCAT %SST(&O 638 1) *BCAT +
                          %SST(&O 639 10))
             ENDDO
             GOTO       CMDLBL(LOOP)
END:
             ENDPGM
