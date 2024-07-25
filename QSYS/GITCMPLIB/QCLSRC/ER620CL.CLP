/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER620CL   Task Summary by user detail                            */
/*  18 March, 2009                                                   */
/*  Ginger Andrews                                                   */
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

 ER620CL:    PGM        PARM(&FMDT &TODT &WHSE &EMP# &CREW &FMTM +
                          &TOTM &JOBQ &RETURN &DEV &FORM &MEMBER +
                          &MRG &ZORD &VYN &TBD)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


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
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */
             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)


/*  Otherwise, run program. */

 REPORT:

       /* POPULATE FILE */
/*    - Get unique member to use.                                       (417) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE ER620A &MEMBER)
             OVRDBF     FILE(ER620A) MBR(&MEMBER)

             CALL       PGM(ER620A) PARM(&FMDT &TODT &WHSE &EMP# +
                        &CREW &MRG &FMTM &TOTM &VYN)

             CALL       PGM(GETUNQMEM) PARM(*REUSE ER620 &MEMBER)
             OVRDBF     FILE(ER620) MBR(&MEMBER)

             CALL       PGM(ER620B) PARM(&FMDT &TODT &FMTM +
                          &TOTM)

             RMVMSG     CLEAR(*ALL)

       /* Detail Display */
             CALL       PGM(ER622) PARM(&FMDT &TODT &WHDP  +
                          &FMTM &TOTM &EMP#)

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

             CLOF       OPNID(ER620A)                                /* (417) */
             MONMSG     MSGID(CPF4519 CPF4520)                       /* (417) */
             CLOF       OPNID(ER620)                                /*  (417) */
             MONMSG     MSGID(CPF4519 CPF4520)                       /* (417) */
             DLTOVR     FILE(ER620A) LVL(*JOB)                       /* (417) */
             MONMSG     MSGID(CPF9841)                               /* (417) */
             DLTOVR     FILE(ER620) LVL(*JOB)                       /*  (417) */
             MONMSG     MSGID(CPF9841)                               /* (417) */
             RMVM       FILE(ER620A) MBR(&MEMBER)                    /* (417) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                           /* (417) */
             RMVM       FILE(ER620) MBR(&MEMBER)                    /*  (417) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)                           /* (417) */

             ENDPGM
