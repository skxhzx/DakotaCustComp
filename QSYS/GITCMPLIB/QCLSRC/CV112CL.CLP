/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CV112CL   Convert old PIRTRAN file to new PIRTRAN file.          */
/*  25 January, 1996                                                */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/18/96  DAS  2.11                                            */
/*      - Revised to work with 'N.' files.  This version of the      */
/*        PIRTRAN file will become the standard version instead of   */
/*        just EPM's version. It just makes life easier.             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CV112CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Updating new transaction file')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYFLAG)    TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Convert PIRTRAN file. */

             OVRDBF     FILE(INPUT)   TOFILE(PIRTRAN)
             OVRDBF     FILE(PIRTRAN) TOFILE(N.PIRTRAN)

             CALL       PGM(CV112)

/*  Get rid of old and bring in the new. */

             DLTF       FILE(LABEL5)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(LABEL7)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(LABEL8)
             MONMSG     MSGID(CPF2105)

             DLTF       FILE(PIRTRAN1)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(PIRTRAN)

             RNMOBJ     OBJ(N.PIRTRAN) OBJTYPE(*FILE) NEWOBJ(PIRTRAN)
             RNMOBJ     OBJ(N.PIRTRAN1) OBJTYPE(*FILE) NEWOBJ(PIRTRAN1)
             RNMOBJ     OBJ(N.PIRTRAN2) OBJTYPE(*FILE) NEWOBJ(PIRTRAN2)

/*  Recompile the label logical files to work with new file. */

             CRTLF      FILE(PIRF/LABEL5) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)
             CRTLF      FILE(PIRF/LABEL7) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)
             CRTLF      FILE(PIRF/LABEL8) SRCFILE(PIR/QDDSFILES) +
                          WAITRCD(30)

             GOTO       CMDLBL(NOMSG)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
