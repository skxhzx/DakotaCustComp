/*-----------------------------------------------------------------*/
/*                                                                 */
/*  CRTDEVLIB   Create development library                         */
/*  29 June 1999                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*  09/15/06  DAS  5.10                                            */
/*    - Changed record size of RPG files to 112                    */
/*                                                                 */
/*  06/21/07  DAS  5.10a                                           */
/*    - Added qcopysrc.                                            */
/*                                                                 */
/*  03/26/15  DAS  6.50a                                           */
/*    - Removed E/L/R files                                        */
/*    - Added SQL                                                  */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*  &LIBNAME     Library name                                      */
/*  &LIBTYPE     Library type                                      */
/*  &LIBDESC     Library description                               */
/*  &QCLSRC      Create QCLSRC (Y,N)                               */
/*  &QCMDSRC     Create QCMDSRC (Y,N)                              */
/*  &QCOPYSRC    Create QCOPYSRC (Y,N)                             */
/*  &QDDSFILES   Create QDDSFILES (Y,N)                            */
/*  &QDDSSRC     Create QDDSSRC (Y,N)                              */
/*  &QMENUSRC    Create QMENUSRC (Y,N)                             */
/*  &QMSGSRC     Create QMSGSRC (Y,N)                              */
/*  &QRPGSRC     Create QRPGSRC (Y,N)                              */
/*  &QRPGLESRC   Create QRPGLESRC (Y,N)                            */
/*  &QSQLSRC     Create QRPGSRC (Y,N)                              */
/*  &QTESTSRC    Create QTESTSRC (Y,N)                             */
/*  &JOBQ        Jobq option (*YES, *NO     )                      */
/*                                                                 */
/*-----------------------------------------------------------------*/

 CRTDEVLIB:  PGM        PARM(&LIBNAME &LIBTYPE &LIBDESC +
                          &QCLSRC +
                          &QCMDSRC  +
                          &QCOPYSRC +
                          &QDDSFILES +
                          &QDDSSRC +
                          &QMENUSRC +
                          &QMSGSRC +
                          &QRPGSRC +
                          &QRPGLESRC +
                          &QSQLSRC +
                          &QTESTSRC +
                          &JOBQ)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&LIBDESC)    TYPE(*CHAR) LEN(50)
             DCL        VAR(&LIBNAME)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIBTYPE)    TYPE(*CHAR) LEN(5)
             DCL        VAR(&JOBTYPE)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QCLSRC)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&QCMDSRC)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&QCOPYSRC)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&QDDSFILES)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&QDDSSRC)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&QMENUSRC)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&QMSGSRC)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRPGSRC)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRPGLESRC)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&QSQLSRC)    TYPE(*CHAR) LEN(1)
             DCL        VAR(&QTESTSRC)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

   /* Standard message handling variables */


             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* See if user wants to put report on jobq. */

             RTVJOBA    TYPE(&JOBTYPE)
             IF (&JOBTYPE = '1') THEN(DO)
             IF (&JOBQ = '*YES') THEN(DO)
             SBMJOB     CMD(CALL PGM(CRTDEVLIB) +
                        PARM(&LIBNAME &LIBTYPE &LIBDESC +
                          &QCLSRC +
                          &QCMDSRC +
                          &QCOPYSRC +
                          &QDDSFILES +
                          &QDDSSRC +
                          &QMENUSRC +
                          &QMSGSRC +
                          &QRPGSRC +
                          &QRPGLESRC +
                          &QSQLSRC +
                          &QTESTSRC +
                          &JOBQ)) +
                          JOB(CRTDEVLIB)
             SNDPGMMSG  MSG('Program has been submitted to jobq') +
                          MSGTYPE(*COMP)
             RETURN
             ENDDO
             ENDDO

/* Create library */

             CHGVAR     VAR(&MSG) VALUE('Creating Library' *BCAT +
                          &LIBNAME)
             MSGBFC     MESSAGE(&MSG)
             CRTLIB     LIB(&LIBNAME) TYPE(&LIBTYPE) TEXT(&LIBDESC)

/* Create source physical files  */

   /* CL */

             IF         COND(&QCLSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QCLSRC')
               CRTSRCPF   FILE(&LIBNAME/QCLSRC) TEXT('CL Source')
             ENDDO

   /* CMD */

             IF         COND(&QCMDSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QCMDSRC')
               CRTSRCPF   FILE(&LIBNAME/QCMDSRC) TEXT('CMD Source')
             ENDDO

   /* COPY */

             IF         COND(&QCOPYSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QCOPYSRC')
               CRTSRCPF   FILE(&LIBNAME/QCOPYSRC) TEXT('/COPY Source')
             ENDDO

   /* DDSFILES */

             IF         COND(&QDDSFILES = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QDDSFILES')
             CRTSRCPF   FILE(&LIBNAME/QDDSFILES) TEXT('DDS Source +
                          for files')
             ENDDO

   /* DDS */

             IF         COND(&QDDSSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QDDSSRC')
               CRTSRCPF   FILE(&LIBNAME/QDDSSRC) TEXT('DDS Source')
             ENDDO

   /* MENU */

             IF         COND(&QMENUSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QMENUSRC')
               CRTSRCPF   FILE(&LIBNAME/QMENUSRC) TEXT('Menu Source')
             ENDDO

   /* MSG */

             IF         COND(&QMSGSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QMSGSRC')
               CRTSRCPF   FILE(&LIBNAME/QMSGSRC) TEXT('Message Source')
             ENDDO

   /* RPG */

             IF         COND(&QRPGSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QRPGSRC')
             CRTSRCPF   FILE(&LIBNAME/QRPGSRC) RCDLEN(112) TEXT('RPG +
                          Source')
             ENDDO

   /* RPGLE */

             IF         COND(&QRPGLESRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QRPGLESRC')
             CRTSRCPF   FILE(&LIBNAME/QRPGLESRC) RCDLEN(112) +
                          TEXT('RPG ILE Source')
             ENDDO

   /* SQL */

             IF         COND(&QSQLSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QSQLSRC')
             CRTSRCPF   FILE(&LIBNAME/QSQLSRC) RCDLEN(112) +
                          TEXT('SQL Source')
             ENDDO

   /* TEST */

             IF         COND(&QTESTSRC = 'Y') THEN(DO)
               MSGBFC     MESSAGE('Creating QTESTSRC')
               CRTSRCPF   FILE(&LIBNAME/QTESTSRC) TEXT('900 Test Source')
             ENDDO



/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/
 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
