/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDRPTCL    PIR update - Reports                               */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*    07/17/97  RH   4.02                                          */
/*      - Add parameter &RSTLIBF File library to update.           */
/*     02/14/03  RH   4.16                                         */
/*      - Add parameters &RLIB and &RLIBF                          */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &RSTLIBF  File library to update                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

/* UPDCALL:    PGM        PARM(&RSTLIBF &RETURN)       4.16*/
 UPDCALL:    PGM        PARM(&RLIB &RLIBF &RSTLIBF &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&RLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Work with NREPORTS file. */

             CHGVAR     VAR(&MSGDTA) VALUE('Adding new reports to +
                          REPORTS file.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

   /* If NREPORTS file doesn't exist then there is nothing to do. */

             CHKOBJ     OBJ(&RSTLIBF/NREPORTS) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             CHGVAR     VAR(&MSGDTA) VALUE('No new reports')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                GOTO REPORTE
             ENDDO

   /* Call update program. */

             CALL       PGM(UPDRPT)

   /* Delete the work file when finished. */

             DLTF       FILE(&RSTLIBF/NREPORTS)

             CHGVAR     VAR(&MSGDTA) VALUE('Report update successful')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/* Work with NREPORTE file. */

 REPORTE:    CHGVAR     VAR(&MSGDTA) VALUE('Adding new reports to +
                          REPORTE file.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

   /* If NREPORTE file doesn't exist then there is nothing to do. */

             CHKOBJ     OBJ(&RSTLIBF/NREPORTE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             CHGVAR     VAR(&MSGDTA) VALUE('No new EPM reports')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                GOTO SKIP
             ENDDO

   /* Call update program. */

             CALL       PGM(UPDRPTE)

/* Delete the work file when finished. */

             DLTF       FILE(&RSTLIBF/NREPORTE)

             CHGVAR     VAR(&MSGDTA) VALUE('Report update successful')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

SKIP:        CHGVAR     VAR(&RETURN) VALUE('*OK')
             RETURN

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')

             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          report update process.  See following messages +
                          and messages in PIRUPDDET message queue.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          report update process.  See following messages +
                          and messages in PIRUPD message queue.')
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)

 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDUSRMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPDDET)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
