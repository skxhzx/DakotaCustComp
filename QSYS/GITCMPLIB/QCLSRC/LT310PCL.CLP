/*-------------------------------------------------------------------*/
/*  CHENEY BROTHERS 2018                                             */
/*                                                                   */
/*  AUTHOR:  TOM FORREST    TDF  04/24/2018                          */
/*                                                                   */
/*  PROGRAM: CALLED FROM LT310 TO ALLOW PRINT OPTION                 */
/*           WORKLIST  #2016133                                      */
/*-------------------------------------------------------------------*/
             PGM        PARM(&PWHSE &PSLOT &PPRT)

             DCL        VAR(&PWHSE) TYPE(*CHAR) LEN(3)
             DCL        VAR(&PSLOT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PPRT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)

             RTVJOBA    USER(&USER)

             DLTF       FILE(QTEMP/LICACTIVET)
             MONMSG     MSGID(CPF0000)

             CRTLF      FILE(QTEMP/LICACTIVET) +
                          SRCFILE(PIRMODS700/QDDSFILES) +
                          OPTION(*NOSOURCE *NOLIST)

             OVRDBF     FILE(LICACTIVET) TOFILE(QTEMP/LICACTIVET)
             OVRPRTF    FILE(QSYSPRT) DEV(&PPRT) OUTQ(&PPRT)
             IF         COND(&USER *EQ 'TOMF ') THEN(OVRPRTF +
                          FILE(QSYSPRT) DEV(&PPRT) OUTQ(&PPRT) +
                          HOLD(*YES))
             CALL       PGM(LT310P) PARM(&PWHSE &PSLOT)

             DLTF       FILE(QTEMP/LICACTIVET)
             DLTOVR     FILE(*ALL)

             ENDPGM
