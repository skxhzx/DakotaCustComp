/*      (c) COPYRIGHT GFG FOODSERVICE, INC.                                */
/*          PROGRAM PROPERTY OF GFG                                        */
/*                                                                         */
/*     Library Name    - GFGTOOL                                           */
/*                                                                         */
/*     Program Name    - LSTFLCL                                           */
/*                                                                         */
/*     Title           - LIST FILE LAYOUTS                                 */
/*                                                                         */
/*     Type / Mode     - GENERAL CPP / (INTERACTIVE/BATCH)                 */
/*                                                                         */
/*     Data Area(s)    - NONE                                              */
/*                                                                         */
/*     Parameter(s)    - &FILLIST  - LIST OF FILE NAMES                    */
/*                       &FILELIB  - FILES LIBRARY NAME                    */
/*                       &OUT      - TYPE OF OUTPUT TO PROVIDE             */
/*                       &DRAWER   - SOURCE PAPER DRAWER                   */
/*                       &FULLOUTQ - OUT QUEUE & LIBRARY NAMES             */
/*                                                                         */
/*     Switche(s)      - NONE                                              */
/*                                                                         */
/*     Lockout(s)      - NONE                                              */
/*                                                                         */
/*     Change Activity -                                                   */
/*                                                                         */
             PGM        PARM(&FILLIST &FILELIB &OUT &DRAWER &FULLOUTQ)
             DCL        VAR(&CURNBR) TYPE(*DEC) LEN(5 0) VALUE(00000)
             DCL        VAR(&ELEMENT) TYPE(*CHAR) LEN(100)
             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILELIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FULLOUTQ) TYPE(*CHAR) LEN(20)
             DCL        VAR(&FILLIST) TYPE(*CHAR) LEN(502)
             DCL        VAR(&DRAWER) TYPE(*CHAR) LEN(1)
             DCL        VAR(&OUT) TYPE(*CHAR) LEN(6)
             DCL        VAR(&OUTQ) TYPE(*CHAR) LEN(10)
             DCL        VAR(&OUTQLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&TYPE) TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERRORSW) TYPE(*LGL) /* Std err */
             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7) /* Std err */
             DCL        VAR(&MSGDTA) TYPE(*CHAR) LEN(100) /* Std err */
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) /* Std err */
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) /* Std err */
             MONMSG     MSGID(CPF0000) EXEC(GOTO STDERR1) /* Std err */
             RTVJOBA    USER(&USER) TYPE(&TYPE)
             IF         COND(&TYPE *EQ '0') THEN(GOTO CMDLBL(#BEGIN))
/*                                                                         */
/*           SBMJOB     CMD(CALL PGM(GFGTOOL/LSTPGMDOCL)                   */
/*           SNDPGMMSG  MSG('Job-LSTPGMDOC submitted to batch.')           */
/*           RETURN                                                        */
#BEGIN:
             CHGVAR     VAR(&OUTQ) VALUE(%SST(&FULLOUTQ 1 10)) /* +
                          Extract OUTQ */
             CHGVAR     VAR(&OUTQLIB) VALUE(%SST(&FULLOUTQ 11 10)) /* +
                          Extract output queue library */
#FILE:
             EXTLST     LIST(&FILLIST) ELMLEN(10) ELEMENT(&ELEMENT) +
                          CURNBR(&CURNBR) /* Extract elements out of +
                          the list. */
             CHGVAR     VAR(&FILE) VALUE(&ELEMENT)
             IF         COND(&CURNBR *EQ 0) THEN(GOTO CMDLBL(#ERROR))
             IF         COND(&FILE *EQ ' ') THEN(GOTO CMDLBL(#DONE))
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Extracting file from list') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)
             CHKOBJ     OBJ(&FILELIB/&FILE) OBJTYPE(*FILE)
                        MONMSG     MSGID(CPF9815) EXEC(DO)
             SNDPGMMSG  MSG('File ' *CAT &FILE *BCAT 'in' *BCAT +
                          &FILELIB *TCAT ' does not exist. - No +
                          report generated')
                       GOTO       CMDLBL(#FILE)
                        ENDDO
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Retrieving file field data for +
                          ' *cat &FILE) TOPGMQ(*EXT) MSGTYPE(*STATUS)
             DSPFFD     FILE(&FILELIB/&FILE) OUTPUT(*OUTFILE) +
                          OUTFILE(QTEMP/SOURCE) /* Create outfile of +
                          file fields. */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Retrieving file data for ' *cat +
                          &FILE) TOPGMQ(*EXT) MSGTYPE(*STATUS)
             DSPFD      FILE(&FILELIB/&FILE) TYPE(*MBR) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/SOURCE1) /* +
                          Create outfile of file data. */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Retrieving file key fields for +
                          ' *cat &FILE) TOPGMQ(*EXT) MSGTYPE(*STATUS)
             DSPFD      FILE(&FILELIB/&FILE) TYPE(*ACCPTH) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/SOURCE2) /* +
                          Create outfile of file keys. */
             OVRPRTF    FILE(LSTFLP) TOFILE(*LIBL/LSTFLP) +
                          PAGESIZE(*N 80) DRAWER(&DRAWER) +
                          PAGRTT(*AUTO) DUPLEX(*YES) +
                          OUTQ(&OUTQLIB/&OUTQ) FORMTYPE(*STD) +
                          OUTPTY(3) SHARE(*YES)
             OVRDBF     FILE(SOURCE) TOFILE(QTEMP/SOURCE)
             OVRDBF     FILE(SOURCE1) TOFILE(QTEMP/SOURCE1)
             OVRDBF     FILE(SOURCE2) TOFILE(QTEMP/SOURCE2)
             CALL       PGM(*LIBL/LSTFL) PARM(&OUT)
             DLTF       FILE(QTEMP/SOURCE)
             DLTF       FILE(QTEMP/SOURCE1)
             DLTF       FILE(QTEMP/SOURCE2)
             GOTO       CMDLBL(#FILE)
#DONE:
             RETURN
#ERROR:
 STDERR1:               /* Standard error handling routine */
             IF         &ERRORSW SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE) /* Func chk */
                        CHGVAR     VAR(&ERRORSW) VALUE('1') /* Set to fail ir +
                          error occurs */
 STDERR2:    RCVMSG     MSGTYPE(*DIAG) MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         (&MSGID *EQ '       ') GOTO STDERR3
                        SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                        GOTO       STDERR2 /* Loop back for addl diagnostics */
 STDERR3:    RCVMSG     MSGTYPE(*EXCP) MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*ESCAPE)
ENDPGM
