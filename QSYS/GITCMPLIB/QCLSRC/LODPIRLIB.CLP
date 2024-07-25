/*-----------------------------------------------------------------*/
/*                                                                 */
/*  LODPIRLIB   Load PIR library                                   */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &SAVLIB   Saved library name                             */
/*        &RSTLIB   Restore library name                           */
/*        &DEV      Device                                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 LODPIRLIB:  PGM        PARM(&SAVLIB &RSTLIB &DEV &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&DEV)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIB)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&SAVLIB)   TYPE(*CHAR) LEN(10)
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

/*-----------------------------------------------------------------*/
/*  Main line                                                      */
/*-----------------------------------------------------------------*/

             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             RMVMSG     CLEAR(*ALL)

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring library' *BCAT +
                          &SAVLIB *BCAT 'to library' *BCAT &RSTLIB +
                          *CAT '.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)


             RSTLIB     SAVLIB(&SAVLIB) DEV(&DEV) OPTION(*ALL) +
                          MBROPT(*ALL) ALWOBJDIF(*ALL) RSTLIB(&RSTLIB)
             MONMSG     MSGID(CPF3848 CPF3773)


             CHGVAR     VAR(&RETURN) VALUE('*OK')
             CHGVAR     VAR(&MSGDTA) VALUE('Restore completed +
                          successfully.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/*-----------------------------------------------------------------*/
/*  Receive any messages and pass them on before leaving.          */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
             SNDUSRMSG  MSG('*** ERROR - Restore Failed ***') +
                          MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG('See detailed messages in job log or +
                          PIRUPDDET message queue.') MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG('*** ERROR - Restore Failed ***  See +
                          following messages.') MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPDDET)
             ENDDO

             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')
 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             IF         COND(&MSGID *EQ 'CPF3773') THEN(DO)
                SNDUSRMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                             MSGDTA(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             ENDDO
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
