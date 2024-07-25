/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDDLT      PIR update - Delete                                */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*    07/17/97  RH   4.02                                          */
/*        Add parameter &RSTLIBF File library to update.           */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &FILE     File name                                      */
/*        &RSTLIBF  File library to update                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDDLT:     PGM        PARM(&FILE &RSTLIBF &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&FILE)     TYPE(*CHAR) LEN(10)
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

/* If a current file doesn't exist then there is no reason to delete it. */

             CHKOBJ     OBJ(&RSTLIBF/&FILE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')
                RETURN
             ENDDO

/* Delete file. */

             CHGVAR     VAR(&MSGDTA) VALUE('Deleting existing file' +
                          *BCAT &FILE)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             DLTF       FILE(&RSTLIBF/&FILE)

             CHGVAR     VAR(&MSGDTA) VALUE('Delete successful')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&RETURN) VALUE('*OK')
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
                          file update process.  See following messages +
                          and messages in PIRUPDDET message queue.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          file update process.  See following messages +
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
