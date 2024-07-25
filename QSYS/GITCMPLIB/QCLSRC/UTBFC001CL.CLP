/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UTBFC001CL   Correct Max File/Max Rcd Wait Times for PF/LF.      */
/*  16 January 2014                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UTBFC001CL: PGM        PARM(&LIB &JOBQ)

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

             DCLF       FILE(QAFDBASI)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* See if we should put this on the JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF         COND(&TYPE = '1' *AND &JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(UTBFC001CL) PARM(&LIB &JOBQ)) +
                          JOB(UTBFC001CL)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/* Get a list of all the files in the library. */

             DSPFD      FILE(&LIB/*ALL) TYPE(*BASATR) +
                          OUTPUT(*OUTFILE) FILEATR(*PF *LF) +
                          OUTFILE(QTEMP/FILELIST)

             OVRDBF     FILE(QAFDBASI) TOFILE(QTEMP/FILELIST)
             OPNDBF     FILE(QTEMP/FILELIST) OPTION(*INP)
             RMVMSG     CLEAR(*ALL)

/* Whip through files reorganizing files with deleted records. */

 READ:       RCVF       RCDFMT(QWHFDBAS)
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(EOF))

             SELECT
             WHEN       COND(&ATFTYP = 'P' *AND &ATFILA = '*PHY') +
                          THEN(DO)
               IF (&atwait *NE 30) THEN(DO)
                 CHGPF      FILE(&ATLIB/&ATFILE) WAITFILE(30)
                 MONMSG     MSGID(CPF326A CPF327F CPF7304 CPF0001) EXEC(DO)
                 SNDPGMMSG  MSG('Max File Wait Time for file' *Bcat +
                              &atfile *bcat 'in Library' *bcat &atlib +
                              *bcat 'not updated.') TOMSGQ(*SYSOPR)
                 ENDDO
               ENDDO
               IF (&atwatr *NE 30) THEN(DO)
                 CHGPF      FILE(&ATLIB/&ATFILE) WAITRCD(30)
                 MONMSG     MSGID(CPF326A CPF327F CPF7304 CPF0001) EXEC(DO)
                 SNDPGMMSG  MSG('Max Rcd Wait Time for file' *Bcat +
                              &atfile *bcat 'in Library' *bcat &atlib +
                              *bcat 'not updated.') TOMSGQ(*SYSOPR)
                 ENDDO
               ENDDO
             ENDDO

             WHEN       COND(&ATFTYP = 'P' *AND &ATFILA = '*LGL') +
                          THEN(DO)
               IF (&atwait *NE 30) THEN(DO)
                 CHGLF      FILE(&ATLIB/&ATFILE) WAITFILE(30)
                 MONMSG     MSGID(CPF326A CPF327F CPF7304 CPF0001) EXEC(DO)
                 SNDPGMMSG  MSG('Max File Wait Time for file' *Bcat +
                              &atfile *bcat 'in Library' *bcat &atlib +
                              *bcat 'not updated.') TOMSGQ(*SYSOPR)
                 ENDDO
               ENDDO
               IF (&atwatr *NE 30) THEN(DO)
                 CHGLF      FILE(&ATLIB/&ATFILE) WAITRCD(30)
                 MONMSG     MSGID(CPF326A CPF327F CPF7304 CPF0001) EXEC(DO)
                 SNDPGMMSG  MSG('Max Rcd Wait Time for file' *Bcat +
                              &atfile *bcat 'in Library' *bcat &atlib +
                              *bcat 'not updated.') TOMSGQ(*SYSOPR)
                 ENDDO
               ENDDO
             ENDDO

             ENDSELECT

             GOTO READ
 EOF:        CLOF       OPNID(FILELIST)

/*  Receive any messages and pass them on before leaving. */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:
             ENDPGM
