/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDCALL     PIR update - Call                                  */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*   F*  02/14/03  RH   4.16                                       */
/*   F*    - Add parameters &RLIB and &RLIBF                       */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &RLIB   Program library to be updated.                   */
/*        &RLIBF  File library to be updated                       */
/*        &PROGRAM  File name                                      */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDCALL:    PGM        PARM(&RLIB &RLIBF &PROGRAM &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&RLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&PROGRAM)  TYPE(*CHAR) LEN(10)
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

/* Call update program. */

             CHGVAR     VAR(&MSGDTA) VALUE('Executing update +
                          program' *BCAT &PROGRAM)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             IF (&PROGRAM = 'UT416LCL') THEN(DO)                     /* 416 */
             CALL       PGM(&PROGRAM) PARM(&RLIB &RLIBF)             /* 416 */
                        ENDDO                                        /* 416 */
                 ELSE   CMD(DO)                                      /* 416 */
             CALL       PGM(&PROGRAM)
                        ENDDO                                        /* 416 */

             CHGVAR     VAR(&MSGDTA) VALUE('Update program successful')
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
