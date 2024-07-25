/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LVLCHKFILE   Compare rec level id between programs and files     */
/*  06 May 2003                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/05/03  DAS  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LVLCHKFILE: PGM        PARM(&PGMLIB &FILELIB &OUTPUT &OUTFILE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&FILELIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&OUTF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&OUTFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&OUTFILE)    TYPE(*CHAR) LEN(20)
             DCL        VAR(&OUTPUT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMLIB)     TYPE(*CHAR) LEN(10)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLG)     TYPE(*LGL)  VALUE('0')
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Extract file name and library */

             CHGVAR     VAR(&OUTF) VALUE(%SST(&OUTFILE 1 10))
             CHGVAR     VAR(&OUTFLIB) VALUE(%SST(&OUTFILE 11 10))

/*  Get program information */

             IF         COND(&PGMLIB *NE '*NONE') THEN(DO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Getting program information') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             DLTF       FILE(QTEMP/PGMREF)
             MONMSG     MSGID(CPF2105)

             DSPPGMREF  PGM(&PGMLIB/*ALL) OUTPUT(*OUTFILE) +
                          OUTFILE(QTEMP/PGMREF)

             ENDDO

/*  Get file information */

             IF         COND(&FILELIB *NE '*NONE') THEN(DO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Getting file information') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             DLTF       FILE(QTEMP/FFD)
             MONMSG     MSGID(CPF2105)

             DSPFFD     FILE(&FILELIB/*ALL) OUTPUT(*OUTFILE) +
                          OUTFILE(QTEMP/FFD)

             ENDDO

/*  Display Results */

             IF         COND(&OUTPUT *EQ '*DISPLAY') THEN(DO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Displaying Results') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             RUNQRY     QRY(LVLCHKFILE) QRYFILE((QTEMP/PGMREF) +
                          (QTEMP/FFD)) OUTTYPE(*DISPLAY)

             ENDDO

/*  Print Results */

             IF         COND(&OUTPUT *EQ '*PRINTER') THEN(DO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Printing Results') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             RUNQRY     QRY(LVLCHKFILE) QRYFILE((QTEMP/PGMREF) +
                          (QTEMP/FFD)) OUTTYPE(*PRINTER)

             ENDDO

/*  File Results */

             IF         COND(&OUTPUT *EQ '*OUTFILE') THEN(DO)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Creating file of results') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RUNQRY     QRY(LVLCHKFILE) QRYFILE((QTEMP/PGMREF) +
                          (QTEMP/FFD)) OUTTYPE(*OUTFILE) +
                          OUTFILE(&OUTFLIB/&OUTF *FIRST *RPLFILE)

             ENDDO


     /*      GOTO       CMDLBL(NOMSG)     */

/*  Receive any messages and pass them on  */

 GETOUT:
             IF         COND(&MSGFLG) THEN(GOTO CMDLBL(ENDPGM))
             CHGVAR     VAR(&MSGFLG) VALUE('1')
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 ENDPGM:     ENDPGM
