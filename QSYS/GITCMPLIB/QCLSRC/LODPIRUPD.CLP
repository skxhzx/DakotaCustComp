/*-----------------------------------------------------------------*/
/*                                                                 */
/*  LODPIRUPD   Load PIR updates                                   */
/*  01 March 1996                                                  */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*    06/18/96  DAS  2.13                                          */
/*      - Writing messages to PIRUPD and PIRUPDDET message queues. */
/*    05/01/97  RH   2.20                                          */
/*      - Change MSG command to MSGBFC.                            */
/*    07/17/97  RH   4.02                                          */
/*      - Add parameters &ULIB Program library to update and       */
/*        &ULIBF File library to update.                           */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &LODTYPE  Load type (*DIRECT, *INDIRECT)                 */
/*        &ULIB     Program library to update                      */
/*        &ULIBF    File library to update                         */
/*        &DEV      Device name                                    */
/*        &JOBQ     Jobq option (*YES, *NO)                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

 LODPIRUPD:  PGM        PARM(&LODTYPE &ULIB &ULIBF &DEV &JOBQ)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&DEV)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&LODTYPE)  TYPE(*CHAR) LEN(9)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&RSTLIB)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&SAVLIB)   TYPE(*CHAR) LEN(10)
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

/* See if user wants to put report on jobq. */

             RTVJOBA    TYPE(&JOBTYPE)
             IF (&JOBTYPE = '1') THEN(DO)
             IF (&JOBQ = '*YES') THEN(DO)
             SBMJOB     CMD(CALL PGM(LODPIRUPD) PARM(&LODTYPE &DEV +
                          &JOBQ)) JOB(LODPIRUPD)
             SNDPGMMSG  MSG('Program has been submitted to jobq') +
                          MSGTYPE(*COMP)
             RETURN
             ENDDO
             ENDDO

/* Clear message queues. */

             RMVMSG     MSGQ(PIRUPD) CLEAR(*OLD)
             RMVMSG     MSGQ(PIRUPDDET) CLEAR(*OLD)

/* Verify libraries to be updated exist.  */

             IF         COND(&LODTYPE = '*DIRECT') THEN(DO)
             CHKOBJ     OBJ(&ULIB) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)

             CHGVAR     VAR(&MSGDTA) VALUE('LODPIRUPD failed because +
                          of an invalid program library to update +
                          (' *CAT &ULIB *TCAT ').')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)

             SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                          MSGTYPE(*ESCAPE)

             ENDDO

             CHKOBJ     OBJ(&ULIBF) OBJTYPE(*LIB)
             MONMSG     MSGID(CPF9801) EXEC(DO)

             CHGVAR     VAR(&MSGDTA) VALUE('LODPIRUPD failed because +
                          of an invalid file library to update +
                          (' *CAT &ULIBF *TCAT ').')

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)

             SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                          MSGTYPE(*ESCAPE)

             ENDDO
             ENDDO

/* Go to the proper section for the load type wanted. */

             IF         COND(&LODTYPE = '*DIRECT') THEN(GOTO +
                          CMDLBL(DIRECT))
             IF         COND(&LODTYPE = '*INDIRECT') THEN(GOTO +
                          CMDLBL(INDIRECT))

             CHGVAR     VAR(&MSGDTA) VALUE('LODPIRUPD failed because +
                          of an invalid load type (' *CAT &LODTYPE +
                          *TCAT ').')

             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)

             SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                          MSGTYPE(*ESCAPE)

/*-----------------------------------------------------------------*/
/*  DIRECT - Load updates directly into PIR and PIRF               */
/*-----------------------------------------------------------------*/

DIRECT:

             CHGVAR     VAR(&MSGDTA) VALUE('Loading updates using +
                          *DIRECT method.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

   /* Restore executable objects to Program library. */

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring executable objects +
                          to program library  (' *CAT &ULIB *TCAT ').')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&SAVLIB) VALUE('PIRUPD')
             CHGVAR     VAR(&RSTLIB) VALUE(&ULIB)
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(LODPIRLIB) PARM(&SAVLIB &RSTLIB &DEV &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring executable objects to (' *CAT &ULIB +
                             *TCAT ') See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring executable objects to (' *CAT &ULIB +
                             *TCAT ') Display messages in PIRUPD +
                             message queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO

   /* Restore new/revised files to File library. */

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring new and revised +
                          files to library  (' *CAT &ULIBF *TCAT ').')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&SAVLIB) VALUE('PIRUPDF')
             CHGVAR     VAR(&RSTLIB) VALUE(&ULIBF)
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(LODPIRLIB) PARM(&SAVLIB &RSTLIB &DEV &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring new and revised files to (' *CAT &ULIBF +
                             *TCAT ') *** See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring new and revised file to (' *CAT &ULIBF +
                             *TCAT ') ***  Display messages in PIRUPD message +
                             queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO

   /* Restore source code to PIRUPDSRC then copy to Program library. */

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring source code to +
                          (' *CAT &ULIB *TCAT ') .')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&SAVLIB) VALUE('PIRUPDS')
             CHGVAR     VAR(&RSTLIB) VALUE('PIRUPDSRC')
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(LODPIRLIB) PARM(&SAVLIB &RSTLIB &DEV &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring source code to (' *CAT &ULIB *TCAT ') +
                             ***  See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring source code to (' *CAT &ULIB *TCAT ') +
                             ***  Display messages in PIRUPD message +
                             queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO


             CHGVAR     VAR(&MSGDTA) VALUE('Copying CL source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QCLSRC) +
                          TOFILE(&ULIB/QCLSRC) FROMMBR(*ALL)
        /*   MONMSG     MSGID(CPF2817)  */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying CMD source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QCMDSRC) +
                          TOFILE(&ULIB/QCMDSRC) FROMMBR(*ALL)
        /*   MONMSG     MSGID(CPF2817)  */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying DDSFILES source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QDDSFILES) +
                          TOFILE(&ULIB/QDDSFILES) FROMMBR(*ALL)
        /*   MONMSG     MSGID(CPF2817)  */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying DDS source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QDDSSRC) +
                          TOFILE(&ULIB/QDDSSRC) FROMMBR(*ALL)
        /*   MONMSG     MSGID(CPF2817)  */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying MENU source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QMENUSRC) +
                          TOFILE(&ULIB/QMENUSRC) FROMMBR(*ALL)
        /*   MONMSG     MSGID(CPF2817)  */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying MSGD source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QMSGDSRC) +
                          TOFILE(&ULIB/QMSGDSRC) FROMMBR(*ALL)
         /*  MONMSG     MSGID(CPF2817)  */

             CHGVAR     VAR(&MSGDTA) VALUE('Copying RPG source to +
                          (' *CAT &ULIB *TCAT ') .')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CPYSRCF    FROMFILE(PIRUPDSRC/QRPGSRC) +
                          TOFILE(&ULIB/QRPGSRC) FROMMBR(*ALL)
        /*   MONMSG     MSGID(CPF2817)   */

             CHGVAR     VAR(&MSGDTA) VALUE('All source copied +
                          successfully.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             RMVMSG     CLEAR(*ALL)

   /* Call special program used for updating files. */

             CHGVAR     VAR(&MSGDTA) VALUE('Updating data files.')
             CHGVAR     VAR(&RSTLIB) VALUE(&ULIB)
             CHGVAR     VAR(&RSTLIBF) VALUE(&ULIBF)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CALL       PGM(UPDATECL) PARM(&RSTLIB &RSTLIBF &RETURN)
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

             DLTLIB     LIB(PIRUPDSRC)

   /* Let user know everything went ok and get out of here. */

             RMVMSG     CLEAR(*ALL)
             CHGVAR     VAR(&MSGDTA) VALUE('All updates restored +
                          successfully to libraries (' *CAT &ULIB *CAT +
                          &ULIBF *TCAT ') for *DIRECT load.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)
             RETURN

/*-----------------------------------------------------------------*/
/*  INDIRECT - Only restore update librarys. Do not update program */
/*             and file libraries.                                 */
/*-----------------------------------------------------------------*/

INDIRECT:

             CHGVAR     VAR(&MSGDTA) VALUE('Loading update libraries +
                          for *INDIRECT method.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

   /* Restore executable objects to PIRUPDOBJ. */

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring executable +
                          objects to PIRUPDOBJ')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&SAVLIB) VALUE('PIRUPD')
             CHGVAR     VAR(&RSTLIB) VALUE('PIRUPDOBJ')
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(LODPIRLIB) PARM(&SAVLIB &RSTLIB &DEV &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring executable objects to PIRUPDOBJ +
                             ***  See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring executable objects to PIRUPDOBJ +
                             ***  Display messages in PIRUPD message queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO

   /* Restore new/revised files to PIRUPDFILE. */

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring new and revised +
                          files to PIRUPDFILE')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&SAVLIB) VALUE('PIRUPDF')
             CHGVAR     VAR(&RSTLIB) VALUE('PIRUPDFILE')
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(LODPIRLIB) PARM(&SAVLIB &RSTLIB &DEV &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring new and revised files to +
                             PIRUPDFILE ***  See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring new and revised file to +
                             PIRUPDFILE ***  Display messages in +
                             PIRUPD message queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO

   /* Restore source code to PIRUPDSRC . */

             CHGVAR     VAR(&MSGDTA) VALUE('Restoring source code to +
                          PIRUPDSRC')
             MSGBFC     MESSAGE(&MSGDTA)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CHGVAR     VAR(&SAVLIB) VALUE('PIRUPDS')
             CHGVAR     VAR(&RSTLIB) VALUE('PIRUPDSRC')
             CHGVAR     VAR(&RETURN) VALUE(' ')
             CALL       PGM(LODPIRLIB) PARM(&SAVLIB &RSTLIB &DEV &RETURN)
             IF         COND(&RETURN *EQ '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring source code to PIRUPDSRC +
                             ***  See previous messages.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&MSGDTA) VALUE('*** ERROR occured while +
                             restoring source code to PIRUPDSRC +
                             ***  Display messages in PIRUPD message +
                             queue.')
                SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                             MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
                SNDPGMMSG  MSGID(CPF9899) MSGF(QSYS/QCPFMSG) +
                             MSGTYPE(*ESCAPE)
             ENDDO

   /* Let user know everything went ok and get out of here. */

             RMVMSG     CLEAR(*ALL)
             CHGVAR     VAR(&MSGDTA) VALUE('Update libraries +
                          PIRUPDSRC, PIRUPDOBJ and PIRUPDFILE +
                          restored successfully.')
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
                          loading process.  See previous messages +
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
                          MSGDTA(&MSGDTA) MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPDDET)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
