/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SETREUSE    Change physical files to reuse deleted records       */
/*  27 April 1993                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SETREUSE:   PGM        PARM(&LIB &JOBQ)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&JOBQ)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&LIB)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)     TYPE(*CHAR) LEN(1)

             DCLF       FILE(QAFDMBRL)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* See if we should put this on the JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF         COND(&TYPE = '1' *AND &JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(SETREUSE) PARM(&LIB &JOBQ)) +
                          JOB(SETREUSE)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/* Get a list of all the files in the library. */

             DSPFD      FILE(&LIB/*ALL) TYPE(*MBRLIST) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/FILELIST)

             OVRDBF     FILE(QAFDMBRL) TOFILE(QTEMP/FILELIST)
             OPNDBF     FILE(QTEMP/FILELIST) OPTION(*INP)
             RMVMSG     CLEAR(*ALL)

/* Whip through files changing them to reuse deleted records. */

 READ:       RCVF       RCDFMT(QWHFDML)
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(EOF))

             CHGPF      FILE(&LIB/&MLFILE) REUSEDLT(*YES)

             GOTO READ
 EOF:        CLOF       OPNID(FILELIST)

/*  Receive any messages and pass them on before leaving. */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
          /* IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:
             ENDPGM
