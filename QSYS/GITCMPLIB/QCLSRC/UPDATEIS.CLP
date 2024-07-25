/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UPDATEIS  Update I-Supply to 2.11/12                             */
/*  07 May 1996                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UPDATEIS:   PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Update existing files with revised formats.  */

   /* File SLOTDEF */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Updating file SLOTDEF.') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RMVMSG     CLEAR(*ALL)

             CPYF       FROMFILE(SLOTDEF) TOFILE(N.SLOTDEF) +
                          MBROPT(*ADD) FMTOPT(*MAP *DROP)

             DLTF       FILE(ITEMDEF1)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(ITEMDEF2)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(SLOTDEF)
             MONMSG     MSGID(CPF2105)
             RNMOBJ     OBJ(N.SLOTDEF)  OBJTYPE(*FILE) NEWOBJ(SLOTDEF)
             CRTLF      FILE(PIRF/ITEMDEF1) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)
             CRTLF      FILE(PIRF/ITEMDEF2) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)

   /* File PIRTRAN */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Updating file PIRTRAN.') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RMVMSG     CLEAR(*ALL)

             DLTF       FILE(PIRTRAN1)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(PIRTRAN2)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(LABEL5)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(LABEL8)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(PIRTRAN)
             MONMSG     MSGID(CPF2105)
             RNMOBJ     OBJ(N.PIRTRAN)  OBJTYPE(*FILE) NEWOBJ(PIRTRAN)
             CRTLF      FILE(PIRF/PIRTRAN1) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)
             CRTLF      FILE(PIRF/PIRTRAN2) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)
             CRTLF      FILE(PIRF/LABEL5) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)
             CRTLF      FILE(PIRF/LABEL8) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)

   /* File PIRDICT */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Updating file PIRDICT.') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RMVMSG     CLEAR(*ALL)

             DLTF       FILE(PIRDICT)
             MONMSG     MSGID(CPF2105)
             RNMOBJ     OBJ(N.PIRDICT)  OBJTYPE(*FILE) NEWOBJ(PIRDICT)

/* Update REPORTS file. */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Updating file REPORTS.') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CALL       PGM(UT160)
             DLTF       FILE(NREPORTS)

/* Updates finished successfully. Return without sending messages. */

             CHGVAR     VAR(&RETURN) VALUE('*OK')
             RETURN

 GETOUT:

/*  Receive any messages and pass them on  */

             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:
             ENDPGM
