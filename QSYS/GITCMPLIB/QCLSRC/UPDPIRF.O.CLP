/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDPIRF   Retry update PIR files from update libraries         */
/*  11 September, 1997                                             */
/*  Roxanne Harrison                                               */
/*                                                                 */
/*  Notes:                                                         */
/*                                                                 */
/*      - Writing messages to PIRUPD and PIRUPDDET message queues. */
/*      - Change MSG command to MSGBFC.                              */
/*      - Add Monmsg for CPF2105.                                    */
/*      - Add parameters &ULIB Program library to update and       */
/*        &ULIBF File library to update.                           */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &FILES    Retry update files (*YES, *NO)                 */
/*        &ULIB     Program library to update                      */
/*        &ULIBF    File library to update                         */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDPIRF:    PGM        PARM(&FILES &ULIB &ULIBF)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&FILES)    TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&OBJECT)   TYPE(*CHAR) LEN(4)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&SOURCE)   TYPE(*CHAR) LEN(4)
             DCL        VAR(&ULIB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&ULIBF)    TYPE(*CHAR) LEN(10)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))


/* Clear message queues. */

/* ***       RMVMSG     MSGQ(PIRUPD) CLEAR(*OLD)       *** */
/* ***       RMVMSG     MSGQ(PIRUPDDET) CLEAR(*OLD)    *** */

/* Verify libraries to be updated exist.  */

             CHKOBJ     OBJ(&ULIB) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)

             CHGVAR     VAR(&MSGDTA) VALUE('UPDPIR failed because +
                          of an invalid program library to update +
                          (' *CAT &ULIB *TCAT ').')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)

             SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                          MSGTYPE(*ESCAPE)

             ENDDO

             CHKOBJ     OBJ(&ULIBF) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)

             CHGVAR     VAR(&MSGDTA) VALUE('UPDPIR failed because +
                          of an invalid file library to update +
                          (' *CAT &ULIBF *TCAT ').')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)

             SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                          MSGTYPE(*ESCAPE)

             ENDDO

/*-----------------------------------------------------------------*/
/*  Update files from library PIRUPDFILE                          */
/*-----------------------------------------------------------------*/

             CHGVAR     VAR(&MSGDTA) VALUE('Updating data files.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)

             CALL       PGM(UPDATECL) PARM(&ULIB &ULIBF &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             updating data files +
                             ***  See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             updating data files +
                             ***  Display messages in PIRUPD message +
                             queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE('Files have been successfully +
                          updated in library (' *CAT &ULIBF *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/*-----------------------------------------------------------------*/
/*  Finished                                                      */
/*-----------------------------------------------------------------*/

 FINISHED:
             CHGVAR     VAR(&MSGDTA) VALUE('Update completed +
                          successfully.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)
             RETURN

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')

             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          update process.  See previous messages +
                          and messages in PIRUPDDET message queue.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          loading process.  See following messages +
                          and messages in PIRUPD message queue.')
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)

 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDUSRMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
