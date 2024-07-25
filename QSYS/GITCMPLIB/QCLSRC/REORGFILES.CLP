/*-------------------------------------------------------------------*/
/*                                                                   */
/*  REORGPIRF   Reorganize physical files in one library             */
/*  23 April 1993                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*  09/27/19  MLB  7.30                                              */
/*    - Enh: Revised RGZPFM cmd to add keyfile(*FILE) parm. Added    */
/*      to improve application performance.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 REORGFILES: PGM        PARM(&LIB &JOBQ)

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
             SBMJOB     CMD(CALL PGM(REORGFILES) PARM(&LIB &JOBQ)) +
                          JOB(REORGFILES)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/* Get a list of all the files in the library. */

             DSPFD      FILE(&LIB/*ALL) TYPE(*MBRLIST) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/FILELIST)

             OVRDBF     FILE(QAFDMBRL) TOFILE(QTEMP/FILELIST)
             OPNDBF     FILE(QTEMP/FILELIST) OPTION(*INP)
             RMVMSG     CLEAR(*ALL)

/* Whip through files reorganizing files with deleted records. */

 READ:       RCVF       RCDFMT(QWHFDML)
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(EOF))

             IF (&MLNDTR *GT 0 *and &MLFILA = '*PHY') THEN(DO)    /* (730 M) */
             RGZPFM     FILE(&LIB/&MLFILE) MBR(&MLNAME) KEYFILE(*FILE) +
                                                                  /* (730 M) */
               MONMSG     MSGID(CPF2980 CPF2981) EXEC(DO)         /* (730 A) */
/*               Not a keyed file, reorg with *FILE option.          (730 A) */
                RGZPFM     FILE(&LIB/&MLFILE) MBR(&MLNAME)
               ENDDO                                              /* (730 A) */
             ENDDO

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
