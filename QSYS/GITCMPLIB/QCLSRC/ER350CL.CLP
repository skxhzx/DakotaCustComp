/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER350CL   Print Task report for an employee                      */
/*  24 March, 2000                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*  09/18/09  GJA  5.30                                              */
/*    - Cleaned up and revamped for suspended transactions           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER350CL:    PGM        PARM(&FMDT &TODT &WHSE &EMP# &CREW &FMTM +
                          &TOTM &JOBQ &RETURN &DEV &FORM &MEMBER +
                          &MRG &ZORD &VYN &TBD)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */
             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER350CL)

  /* Option program. */
             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER350)

  /* Report program and printer file name. */
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER352PR)

  /* Informational message. */
             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Task report for an employee')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Task report for an employee')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CREW)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PRTF1)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&TOTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&FMTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&VYN)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&ZORD)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TBD)        TYPE(*CHAR) LEN(1)
             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */
             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */
             CALL       PGM(&OPTPGM) PARM(&FMDT &TODT &WHSE +
                          &EMP# &CREW &FMTM &TOTM &JOBQ &RETURN +
                          &DEV &FORM &MRG &ZORD &VYN &TBD)

/*  See if user wants to proceed. */
             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* See if user wants to put report on jobq. */
             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&FMDT &TODT +
                          &WHSE &EMP# &CREW &FMTM &TOTM &JOBQ +
                          &RETURN &DEV &FORM &MEMBER &MRG &ZORD +
                          &VYN &TBD)) JOB(&SBMPGM)
             RETURN                                               /* (510aM) */
             ENDDO

/*  Otherwise, run program. */

 REPORT:

       /* POPULATE FILE */
/*    - Get unique member to use.                                       (417) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE ER350A &MEMBER)
             OVRDBF     FILE(ER350A) MBR(&MEMBER)

             CALL       PGM(ER350A) PARM(&FMDT &TODT &WHSE &EMP# +
                        &CREW &MRG &FMTM &TOTM &VYN)

             CALL       PGM(GETUNQMEM) PARM(*REUSE ER350 &MEMBER)   /*  (417) */
             OVRDBF     FILE(ER350) MBR(&MEMBER)                    /*  (417) */

             CALL       PGM(ER350B) PARM(&FMDT &TODT &FMTM +
                          &TOTM)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

       /* Detail Report */
             OVRPRTF    FILE(&PRTF1) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             IF (&CREW > ' ') THEN(DO)
             CALL       PGM(ER353) PARM(&FMDT &TODT &WHSE &CREW +
                          &FMTM &TOTM &MRG)
             ENDDO
             IF (&EMP# > '00000') THEN(DO)
             CALL       PGM(ER352) PARM(&FMDT &TODT &WHSE &EMP# +
                          &FMTM &TOTM &MRG)
             ENDDO

 /* REPORT:    */

 /* Receive any messages and pass them on */

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

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             CLOF       OPNID(ER350A)                                /* (417) */
             MONMSG     MSGID(CPF4519 CPF4520)                       /* (417) */
             CLOF       OPNID(ER350)                                /*  (417) */
             MONMSG     MSGID(CPF4519 CPF4520)                       /* (417) */
             DLTOVR     FILE(ER350A) LVL(*JOB)                       /* (417) */
             MONMSG     MSGID(CPF9841)                               /* (417) */
             DLTOVR     FILE(ER350) LVL(*JOB)                       /*  (417) */
             MONMSG     MSGID(CPF9841)                               /* (417) */
             RMVM       FILE(ER350A) MBR(&MEMBER)                    /* (417) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                           /* (417) */
             RMVM       FILE(ER350) MBR(&MEMBER)                    /*  (417) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                           /* (417) */

             ENDPGM
