/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER370CL   Print Task report for an employee                      */
/*  24 March, 2000                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*  11/07/00  HNK  4.15                                              */
/*    - Changed to join PIRTRAN and LABEL file.                      */
/*    - Query selection changed to include only PTGRP1='S' records.  */
/*    - &ENDT parameter added.                                       */
/*                                                                   */
/*  05/12/03  MLB  4.17                                              */
/*    - Enh:  Revised program to add unique member support. Revised  */
/*      program to remove member added to ER371A on exit.            */
/*                                                                   */
/*  03/26/03  HNK  5.00                                              */
/*    - Changed to include &CREW and &DMIN.                          */
/*                                                                   */
/*  10/06/06  MLB  5.10a                                             */
/*    - Fix:  Revised program to RETURN instead of GOTO when job     */
/*      is submitted to batch for processing.                        */
/*                                                                   */
/*  09/05/07  RBD  5.10B                                             */
/*    - ENH:  ADD OPTION TO INCLUDE OR EXCLUDE MERGE PIECES.         */
/*                                                                   */
/*  06/29/09  RBD  5.20a                                             */
/*    - Fix:  Rev 5.10 was referencing &EMP, should be &EMP#.        */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Note: This program replaces ER240CL   4.13                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

/* 4.15 Change - &ENDT added and &TODT moved to end. */

 ER370CL:    PGM        PARM(&FMDT &ENDT &WHSE &EMP# &PDETL &JOBQ +
                          &RETURN &DEV &FORM &TODT &CREW &DMIN &MRG +
                          &FMTM &TOTM &VYN &ZNDP &TBD)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (510 A)  */

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER370CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER370)

  /* Report program and printer file name. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(PIRTRAN)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER371PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Task report for an employee')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Task report for an employee')

/*750aA*/    DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('   Use Web Dakota EPM Task Deta+
                           il Report.  ')
/*750aA*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*750aA*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*750 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*750 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*750 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CREW)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&DMIN)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&ENDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&MRG)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&TOTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&FMTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&VYN)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&ZNDP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TBD)        TYPE(*CHAR) LEN(1)
             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*750aA*/    CHGVAR     VAR(&PGMID) VALUE(ER360CL)
/*750aA*/    RTVJOBA    USER(&PUSR)
/*750aA*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (750aA) */

/*750aA*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
/*750aA*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*750aA*/               SNDPGMMSG  MSG(&NOAUTHRZG)   +
/*750aA*/               MSGTYPE(*INFO)
/*750aA*/    RETURN
/*750aA*/    ENDDO

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

/* 4.15 Change - &ENDT added and &TODT moved to end. */

             CALL       PGM(&OPTPGM) PARM(&FMDT &ENDT &WHSE &EMP#  +
                          &PDETL &JOBQ &RETURN &DEV &FORM &TODT +
                          &CREW &DMIN &MRG &FMTM &TOTM &VYN &ZNDP &TBD)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

/* 4.15 Change - &ENDT added and &TODT moved to end. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&FMDT &ENDT &WHSE +
                          &EMP# &PDETL &JOBQ &RETURN &DEV &FORM +
                          &TODT &CREW &DMIN &MRG &FMTM &TOTM &VYN +
                          &ZNDP &TBD)) JOB(*JOBD)
/*           GOTO       CMDLBL(GETOUT)                               (510aD) */
             RETURN                                               /* (510aM) */
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/*    - Get unique member to use.                                       (417) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE ER371 &MEMBER)
             OVRDBF     FILE(ER371) MBR(&MEMBER)

             CALL       PGM(ER370A) PARM(&FMDT &ENDT &WHSE &EMP#  +
                          &CREW &DMIN &MRG &FMTM &TOTM &VYN)



  /* 4.15 Change End   */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* 4.15 Change - START                               */

       /* POPULATE FILE */

/*           CLRPFM     FILE(ER371A)                                    (417) */
/*    - Get unique member to use.                                       (417) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE ER371A &MEMBER)   /* (417) */
             OVRDBF     FILE(ER371A) MBR(&MEMBER)                    /* (417) */


             CALL       PGM(ER371A) PARM(&FMDT &ENDT &WHSE &CREW +
                                &DMIN &FMTM &TOTM &VYN &ZNDP &TBD)
/* 4.15 Change - END                                 */

       /* Detail Report */

/*           IF (&PDETL = 'Y') THEN(DO)            */
             OVRPRTF    FILE(ER371PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             CALL       PGM(ER371) PARM(&FMDT &TODT &WHSE &EMP# +
                          &CREW &DMIN &MRG &FMTM &TOTM)
/*           ENDDO       */

       /* Summary Report */

/*           IF (&PDETL = 'N') THEN(DO)                             */
/*           OVRPRTF    FILE(ER372PR) DEV(&DEV) CPI(15) OUTQ(*DEV) +*/
/*                        FORMTYPE(&FORM)                           */
/*           CALL       PGM(ER372) PARM(&FMDT &TODT &WHSE &EMP# +   */
/*                        &CREW &DMIN &MRG)                         */
/*           ENDDO                                                  */


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

             CLOF       OPNID(ER371A)                                /* (417) */
             MONMSG     MSGID(CPF4519 CPF4520)                       /* (417) */
             CLOF       OPNID(ER370)                                /*  (417) */
             MONMSG     MSGID(CPF4519 CPF4520)                       /* (417) */
             DLTOVR     FILE(ER371A) LVL(*JOB)                       /* (417) */
             MONMSG     MSGID(CPF9841)                               /* (417) */
             DLTOVR     FILE(ER370) LVL(*JOB)                       /*  (417) */
             MONMSG     MSGID(CPF9841)                               /* (417) */
             RMVM       FILE(ER371A) MBR(&MEMBER)                    /* (417) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                           /* (417) */
             RMVM       FILE(ER371) MBR(&MEMBER)                    /*  (417) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                           /* (417) */

             ENDPGM
