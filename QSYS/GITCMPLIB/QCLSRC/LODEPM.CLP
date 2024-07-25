/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LODEPM    Initial load of EPM libraries.                         */
/*  12 March 1996                                                    */
/*  Dave Sommerville                                                 */
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &DEV      Device name                                    */
/*        &JOBQ     Jobq option (*YES, *NO)                        */
/*                                                                 */
/*-----------------------------------------------------------------*/

 LODEPM:     PGM        PARM(&DEV &JOBQ)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&DEV)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&JOBTYPE)  TYPE(*CHAR) LEN(1)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* See if user wants to put report on jobq. */

             RTVJOBA    TYPE(&JOBTYPE)
             IF (&JOBTYPE = '1') THEN(DO)
             IF (&JOBQ = '*YES') THEN(DO)
             SBMJOB     CMD(CALL PGM(LODEPM) PARM(&DEV +
                          &JOBQ)) JOB(LODEPM)
             CHGVAR     VAR(&ERRFLAG) VALUE('0')
             GOTO       CMDLBL(GETOUT)
             ENDDO
             ENDDO

   /* Restore PIREPM library. */

             MSGBFC     MESSAGE('Restoring library PIREPM')

             RSTLIB     SAVLIB(PIREPM) DEV(&DEV) ENDOPT(*LEAVE) +
                          OPTION(*ALL) MBROPT(*ALL) ALWOBJDIF(*ALL)

             RMVMSG     CLEAR(*ALL)

   /* Restore PIREPMF library. */

             MSGBFC     MESSAGE('Restoring library PIREPMF')

             RSTLIB     SAVLIB(PIREPMF) DEV(&DEV) OPTION(*ALL) +
                          MBROPT(*ALL) ALWOBJDIF(*ALL)

             RMVMSG     CLEAR(*ALL)

   /* Setup library list. */

             RMVLIBLE   LIB(PIR)
             MONMSG     MSGID(CPF0000)
             RMVLIBLE   LIB(PIRF)
             MONMSG     MSGID(CPF0000)
             RMVLIBLE   LIB(PIREPM)
             MONMSG     MSGID(CPF0000)
             RMVLIBLE   LIB(PIREPMF)
             MONMSG     MSGID(CPF0000)

             ADDLIBLE   LIB(PIRF)
             ADDLIBLE   LIB(PIREPMF)
             ADDLIBLE   LIB(PIR)
             CHGCURLIB  CURLIB(PIREPM)

   /* Create TASKDET records. */

             MSGBFC     MESSAGE('Creating TASKDET records')

             CALL       PGM(CRTDETCL)

   /* Convert existing PIRTRAN records to new layout. */

             MSGBFC     MESSAGE('Converting PIRTRAN records to new +
                          EPM layout')

             CALL       PGM(CV112CL)

   /* Creating new LABEL5 logical file. */

             MSGBFC     MESSAGE('Creating LABEL5 logical file')

             CRTLF      FILE(PIREPMF/LABEL5) +
                          SRCFILE(PIREPM/QDDSFILES) WAITRCD(30)

   /* Creating new LABEL7 logical file. */

             MSGBFC     MESSAGE('Creating LABEL7 logical file')

             CRTLF      FILE(PIREPMF/LABEL7) +
                          SRCFILE(PIREPM/QDDSFILES) WAITRCD(30)

   /* Creating new LABEL8 logical file. */

             MSGBFC     MESSAGE('Creating LABEL8 logical file')

             CRTLF      FILE(PIREPMF/LABEL8) +
                          SRCFILE(PIREPM/QDDSFILES) WAITRCD(30)

   /* Let user know everything went ok and get out of here. */

             RMVMSG     CLEAR(*ALL)
             SNDPGMMSG  MSG('Loading of EPM libraries completed +
                          successfully.') MSGTYPE(*COMP)
             CHGVAR     VAR(&ERRFLAG) VALUE('0')

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')
 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

             IF         &ERRFLAG SNDPGMMSG MSGID(CPF9899) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

             ENDPGM
