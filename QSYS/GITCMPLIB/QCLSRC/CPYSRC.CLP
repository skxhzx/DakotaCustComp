/*-----------------------------------------------------------------*/
/*                                                                 */
/*  CPYSRC      Copy source to PIR library                         */
/*  08 July 1997                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &FROMLIB  From library                                   */
/*        &JOBQ     Jobq option (*YES, *NO)                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

 CPYSRC:     PGM        PARM(&FROMLIB &JOBQ)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&JOBTYPE)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)     TYPE(*CHAR) LEN(4)
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

/* See if user wants to put job on jobq. */

             RTVJOBA    TYPE(&JOBTYPE)
             IF (&JOBTYPE = '1') THEN(DO)
             IF (&JOBQ = '*YES') THEN(DO)
             SBMJOB     CMD(CALL PGM(CPYSRC) PARM(&FROMLIB +
                          &JOBQ)) JOB(UPDPIR)
             SNDPGMMSG  MSG('Program has been submitted to jobq') +
                          MSGTYPE(*COMP)
             RETURN
             ENDDO
             ENDDO

/* Clear message queues. */

             RMVMSG     CLEAR(*ALL)

/*-----------------------------------------------------------------*/
/*  Update source from library PIRUPDSRC                           */
/*-----------------------------------------------------------------*/

             CHGVAR     VAR(&MSGDTA) VALUE('Copying source code to +
                          PIR')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)

             CHGVAR     VAR(&MSGDTA) VALUE('Copying CL source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QCLSRC) +
                          TOFILE(PIR/QCLSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying CMD source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QCMDSRC) +
                          TOFILE(PIR/QCMDSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying DDSFILES source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QDDSFILES) +
                          TOFILE(PIR/QDDSFILES) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying DDS source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QDDSSRC) +
                          TOFILE(PIR/QDDSSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying MENU source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QMENUSRC) +
                          TOFILE(PIR/QMENUSRC) FROMMBR(*ALL)
     /*      MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying MSGD source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QMSGDSRC) +
                          TOFILE(PIR/QMSGDSRC) FROMMBR(*ALL)
      /*     MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying RPG source to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)
             CPYSRCF    FROMFILE(PIRUPDSRC/QRPGSRC) +
                          TOFILE(PIR/QRPGSRC) FROMMBR(*ALL)
      /*     MONMSG     MSGID(CPF2817)     */

             CHGVAR     VAR(&MSGDTA) VALUE('All source copied +
                          successfully.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO)

/*-----------------------------------------------------------------*/
/*  Update objects from library PIRUPDOBJ                          */
/*-----------------------------------------------------------------*/

OBJECT:      IF         COND(&OBJECT *NE '*YES') THEN(GOTO +
                          CMDLBL(FILES))

             CHGVAR     VAR(&MSGDTA) VALUE('Copying objects to +
                          PIR')
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
                          PIRUPDSAVF to PIR')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             RSTOBJ     OBJ(*ALL) SAVLIB(PIRUPDOBJ) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIR)
             MONMSG     MSGID(CPF3773)

SKPRST1:     DLTF       FILE(QTEMP/PIRUPDSAVF)
             MONMSG     MSGID(CPF2105)

             CHGVAR     VAR(&MSGDTA) VALUE('Objects have been successfully +
                          copied to library PIR.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/*-----------------------------------------------------------------*/
/*  Update files from library PIRUPDFILE                          */
/*-----------------------------------------------------------------*/

FILES:       IF         COND(&FILES *NE '*YES') THEN(GOTO +
                          CMDLBL(FINISHED))

             CHGVAR     VAR(&MSGDTA) VALUE('Copying files to +
                          PIRF')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHKOBJ     OBJ(QTEMP/PIRUPDSAVF) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
             CRTSAVF    FILE(QTEMP/PIRUPDSAVF)
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE('Saving objects from +
                          PIRUPDFILE to PIRUPDSAVF')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             SAVOBJ     OBJ(*ALL) LIB(PIRUPDFILE) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUPDSAVF)
             MONMSG     MSGID(CPF3770) EXEC(GOTO CMDLBL(SKPRST2))

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring objects from +
                          PIRUPDSAVF to PIRF')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             RSTOBJ     OBJ(*ALL) SAVLIB(PIRUPDFILE) DEV(*SAVF) +
                          SAVF(QTEMP/PIRUPDSAVF) MBROPT(*ALL) +
                          ALWOBJDIF(*ALL) RSTLIB(PIRF)
             MONMSG     MSGID(CPF3773)

SKPRST2:     DLTF       FILE(QTEMP/PIRUPDSAVF)

             CHGVAR     VAR(&MSGDTA) VALUE('Files have been successfully +
                          copied to library PIRF.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&MSGDTA) VALUE('Updating data files.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CALL       PGM(UPDATECL) PARM(&RETURN)
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
                          updated in library PIRF.')
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
