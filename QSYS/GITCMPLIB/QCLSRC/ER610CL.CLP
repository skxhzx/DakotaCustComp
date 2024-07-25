/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER610CL   Task Summary by Employee                               */
/*  18 September, 2001                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    10/09/09  GJA  5.30                                            */
/*      - Enh:  Cleaned up and revamped for suspended transactions   */
/*                                                                   */
/*    07/08/10  MLB  5.30b                                           */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*    05/06/11  GJA  6.40a                                           */
/*      - Fix:  $PVYN was not being passed to ER611                  */
/*                                                                   */
/*    03/07/22  RH   7.50a                                           */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line Distributors                  */
/*    07/08/10  MLB  CLD                                             */
/*      - Revised program to only allow authorized users to run      */
/*        run this program.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Renzi                                   */
/*    02/06/14  JCJ  RNZa                                            */
/*      - Revised program to only allow authorized users to run      */
/*        run this program.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cheney Brothers.                        */
/*    01/04/17  JGD 7.00                                             */
/*      - Revised program to add Cheney as allowed user to access    */
/*        this program - Menu: EPM/Opt# 14.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC Foodservice                         */
/*    10/11/19  MLB  TPC                                             */
/*      - Revised program to only allow authorized users to run      */
/*        run this program. Per Steve W. email dated 10.11.2019.     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER610CL:    PGM        PARM(&PFMDT &PTODT &PWHSE &PEMP# &PCREW +
                          &PENDT &PBTIM &PETIM &PDETL &JOBQ &RETURN +
/*6.40a*/                 &DEV &FORM &MEMBER &MRG &PVYN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (530bA) */

             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE  ')                     /* (CLD A) */

             DCL        VAR(&RENZI) TYPE(*CHAR) LEN(10) +
                          VALUE('RENZI     ')                     /* (RNZ A) */
             DCL        VAR(&TPC)      TYPE(*CHAR) LEN(10) +
                          VALUE('TPC       ')                     /* (TPC A) */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER610CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ER610)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(ER611A)
             DCL        VAR(&FILE2) TYPE(*CHAR) LEN(10) VALUE(WORKOPT)
             DCL        VAR(&FILE3) TYPE(*CHAR) LEN(10) VALUE(ER611)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Task Summary Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating task summary')
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (CLD A) */
             DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('  Use Web Dakota EPM Task Summary +
                          Report.    ')                          /* (C LD A) */


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (530bA) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (530bA) */
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)      /* (CLD A) */
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)      /* (CLD A) */
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)       /* (CLD A) */
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)      /* (CLD A) */
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER2) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER3)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PEMP#)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PENDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PBTIM)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PETIM)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PVYN)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
                                                                  /* (530bA) */
/* Retrieve client id.                                               (530bA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (530bA) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Check if user is authorized to use this option                   (CLD A) */

/*           IF         COND(&CLIENT *EQ &CITYLINE)  THEN(DO)     /* (CLD A) */

               CHGVAR     VAR(&PGMID) VALUE(ER610CL)              /* (CLD A) */
               RTVJOBA    USER(&PUSR)                             /* (CLD A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR +
                            &PRTN)                                /* (CLD A) */
             IF         COND((&CLIENT *EQ &CITYLINE) +
                         *OR (&CLIENT *EQ &RENZI) +
                         *OR (&CLIENT *EQ &TPC) +
                         *OR (&CLIENT *EQ 'CHENEYBROS')) THEN(DO) /* (TPC M) */
 /*            CHGVAR     VAR(&PGMID) VALUE(ER610CL)                 (CLD A) */
 /*            RTVJOBA    USER(&PUSR)                                (CLD A) */
 /*            CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR +
 /*                         &PRTN)                                   (CLD A) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (CLD A) */
                          SNDPGMMSG  MSG(&NOAUTHRZE)   +
                          MSGTYPE(*INFO)                          /* (CLD A) */
               RETURN                                             /* (CLD A) */
               ENDDO                                              /* (CLD A) */
             ENDDO                                              /* (C  LD A) */
             ELSE CMD(DO)                                         /* (750aA) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (750aA) */
                          SNDPGMMSG  MSG(&NOAUTHRZG)   +
                          MSGTYPE(*INFO)                          /* (750aA) */
               RETURN                                             /* (750aA) */
               ENDDO                                              /* (750aA) */
             ENDDO                                                /* (CLD A) */

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
                ENDDO

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER2 = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE2 &MEMBER2)
                ENDDO

             OVRDBF     FILE(&FILE2) MBR(&MEMBER2) SHARE(*YES)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER3 = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE3 &MEMBER3)
                ENDDO

             OVRDBF     FILE(&FILE3) MBR(&MEMBER3) SHARE(*YES)

 AGAIN:

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &PEMP# &PFMDT +
                          &PTODT &RETURN &PCREW &PBTIM &PETIM +
                          &PENDT &PVYN &MRG)

/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PFMDT &PTODT +
                          &PWHSE &PEMP# &PCREW &PENDT &PBTIM &PETIM +
                          &PDETL &JOBQ &RETURN &DEV &FORM &MEMBER +
/*6.40a*/                 &MRG &PVYN)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REFRESH:
             RCLRSC     LVL(*CALLER)
             RMVMSG     CLEAR(*ALL)

/*  Clear Work file. */

             CLRPFM     FILE(ER611A) MBR(&MEMBER)
             CLRPFM     FILE(ER611) MBR(&MEMBER)


 REPORT:

       /* If run from jobq, do the override again.  */

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
             ENDDO



             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(ER610A) PARM(&PFMDT &PTODT &PBTIM &PETIM +
                          &PVYN &PEMP# &PWHSE &PCREW &MRG)

             CALL       PGM(ER611A) PARM(&PFMDT &PTODT &PBTIM &PETIM +
                          &MRG)

             CALL       PGM(ER611B) PARM(&PWHSE &PEMP# &PCREW &PFMDT +
                          &PTODT &PBTIM &PETIM)

             CALL       PGM(ER611) PARM(&PWHSE &PEMP# &PCREW &PFMDT &PTODT +
/*6.40a*/                 &PCMD &PBTIM &PETIM &PENDT &MRG &PVYN)

             IF COND(&PCMD = '*REFRESH') THEN(DO)
             GOTO REFRESH
             ENDDO

             IF COND(&PCMD = '*CANCEL ') THEN(DO)
             RCLRSC     LVL(*CALLER)
             GOTO AGAIN
             ENDDO

/*  Clean up before leaving */

             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)
             DLTOVR     FILE(&FILE2)
             MONMSG     MSGID(CPF9841)
             DLTOVR     FILE(&FILE3)
             MONMSG     MSGID(CPF9841)

             RMVM       FILE(&FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF7301 CPF7310)

             RMVM       FILE(&FILE2) MBR(&MEMBER2)
             MONMSG     MSGID(CPF320A CPF7301 CPF7310)

             RMVM       FILE(&FILE3) MBR(&MEMBER3)
             MONMSG     MSGID(CPF320A CPF7301 CPF7310)

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

             ENDPGM
