/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDPIR      Update PIR from update libraries                   */
/*  01 March 1996                                                  */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*    06/18/96  DAS  2.13                                          */
/*      - Writing messages to PIRUPD and PIRUPDDET message queues. */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    05/14/97  DAS  2.21                                            */
/*      - Add Monmsg for CPF2105.                                    */
/*    07/17/97  RH   4.02                                          */
/*      - Add parameters &ULIB Program library to update and       */
/*        &ULIBF File library to update.                           */
/*    04/17/00  RH/DAS 4.13                                        */
/*      - Change to PIRUP2SAVF for files, error deleteing          */
/*        PIRUPDSAVF and reusing.                                  */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &ULIB     Program library to update                      */
/*        &ULIBF    File library to update                         */
/*        &SOURCE   Update source (*YES, *NO)                      */
/*        &OBJECT   Update objects (*YES, *NO)                     */
/*        &FILES    Update files (*YES, *NO)                       */
/*        &JOBQ     Jobq option (*YES, *NO)                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDPIR:     PGM        PARM(&ULIB &ULIBF &SOURCE &OBJECT &FILES &JOBQ)

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

/* See if user wants to put job on jobq. */

             RTVJOBA    TYPE(&JOBTYPE)
             IF (&JOBTYPE = '1') THEN(DO)
             IF (&JOBQ = '*YES') THEN(DO)
             SBMJOB     CMD(CALL PGM(UPDPIR) PARM(&SOURCE &OBJECT +
                          &FILES &JOBQ)) JOB(UPDPIR)
             SNDPGMMSG  MSG('Program has been submitted to jobq') +
                          MSGTYPE(*COMP)
             RETURN
             ENDDO
             ENDDO

/* Clear message queues. */

             RMVMSG     MSGQ(PIRUPD) CLEAR(*OLD)
             RMVMSG     MSGQ(PIRUPDDET) CLEAR(*OLD)

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
/*  Update source from library PIRUPDSRC                           */
/*-----------------------------------------------------------------*/

SOURCE:      IF         COND(&SOURCE *NE '*YES') THEN(GOTO +
                          CMDLBL(OBJECT))

             CHGVAR     VAR(&MSGDTA) VALUE('Copying source code to +
                          program library  (' *CAT &ULIB *TCAT ').')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&MSGDTA) VALUE('Copying CL source to +
                          (' *CAT &ULIB *TCAT ').')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QCLSRC) +
                          TOFILE(&ULIB/QCLSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying CMD source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QCMDSRC) +
                          TOFILE(&ULIB/QCMDSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying DDSFILES source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QDDSFILES) +
                          TOFILE(&ULIB/QDDSFILES) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying DDS source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QDDSSRC) +
                          TOFILE(&ULIB/QDDSSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying MENU source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QMENUSRC) +
                          TOFILE(&ULIB/QMENUSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying MSGD source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QMSGDSRC) +
                          TOFILE(&ULIB/QMSGDSRC) FROMMBR(*ALL)
      /*     MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying RPG source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QRPGSRC) +
                          TOFILE(&ULIB/QRPGSRC) FROMMBR(*ALL)
      /*     MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('All source copied +
                          successfully.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/*-----------------------------------------------------------------*/
/*  Update objects from library PIRUPDOBJ                          */
/*-----------------------------------------------------------------*/

OBJECT:      IF         COND(&OBJECT *NE '*YES') THEN(GOTO +
                          CMDLBL(FILES))

             CHGVAR     VAR(&MSGDTA) VALUE('Copying objects to +
                          (' *CAT &ULIB *TCAT ') .')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHKOBJ     OBJ(QTEMP/PIRUPDSAVF) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             CRTSAVF    FILE(QTEMP/PIRUPDSAVF)
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE('Saving objects from +
                          PIRUPDOBJ to PIRUPDSAVF')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             SAVOBJ     OBJ(*ALL) LIB(PIRUPDOBJ) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUPDSAVF)
             MONMSG     MSGID(CPF3770) EXEC(GOTO CMDLBL(SKPRST1))

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring objects from +
                          PIRUPDSAVF to (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             RSTOBJ     OBJ(*ALL) SAVLIB(PIRUPDOBJ) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(&ULIB)
             MONMSG     MSGID(CPF3773)

SKPRST1:     DLTF       FILE(QTEMP/PIRUPDSAVF)
             MONMSG     MSGID(CPF2105)

             CHGVAR     VAR(&MSGDTA) VALUE('Objects have been successfully +
                          copied to library (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/*-----------------------------------------------------------------*/
/*  Update files from library PIRUPDFILE                          */
/*-----------------------------------------------------------------*/

FILES:       IF         COND(&FILES *NE '*YES') THEN(GOTO +
                          CMDLBL(FINISHED))

             CHGVAR     VAR(&MSGDTA) VALUE('Copying files to +
                          (' *CAT &ULIBF *TCAT ') .')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHKOBJ     OBJ(QTEMP/PIRUP2SAVF) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             CRTSAVF    FILE(QTEMP/PIRUP2SAVF)
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE('Saving objects from +
                          PIRUPDFILE to PIRUP2SAVF')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             SAVOBJ     OBJ(*ALL) LIB(PIRUPDFILE) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUP2SAVF)
             MONMSG     MSGID(CPF3770) EXEC(GOTO CMDLBL(SKPRST2))

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring objects from +
                          PIRUP2SAVF to (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             RSTOBJ     OBJ(*ALL) SAVLIB(PIRUPDFILE) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUP2SAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(&ULIBF)
             MONMSG     MSGID(CPF3773)

SKPRST2:     DLTF       FILE(QTEMP/PIRUP2SAVF)

             CHGVAR     VAR(&MSGDTA) VALUE('Files have been successfully +
                          copied to library (' *CAT &ULIBF *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&MSGDTA) VALUE('Updating data files.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

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
