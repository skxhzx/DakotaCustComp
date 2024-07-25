/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UC410CL   Delete Multiple UPC codes                              */
/*  04 March 2004                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  NOTE:                                                            */
/*                                                                   */
/*  Revisions                                                        */
/*    03/03/04  RH   417a                                            */
/*      - Add &PMCNT for selecting multiples > #                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UC410CL:    PGM        PARM(&PWHSE &JOBQ &RETURN +
                          &DEV &FORM &MEMBER &PMCNT)
  /*                      &DEV &FORM &MEMBER)            */
  /*                      &DEV &FORM &MEMBER &MEMBERA)   */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UC410CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(UC410)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(UC412)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(UC410)
 /*          DCL        VAR(&FILEA) TYPE(*CHAR) LEN(10) VALUE(IV172) */
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(UC212PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Multiple UPC code list')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Multiple UPC code list')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBERA)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PITM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&PVAR)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PMCNT)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER)
                ENDDO

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)


/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &JOBQ +
                          &RETURN &DEV &FORM &PMCNT)
 /* 417                   &RETURN &DEV &FORM)         */


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PWHSE &JOBQ +
                        &RETURN &DEV &FORM &MEMBER &PMCNT)) +
                        JOB(AAUC410CL)
/* 4.11                   &RETURN &DEV &FORM &MEMBER)) JOB(&SBMPGM)  */
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:


   /* 4.17   CALL       PGM(UC211) PARM(&PWHSE)     */
             CALL       PGM(UC411) PARM(&PWHSE &PMCNT)

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM) LPI(4) CPI(5) OVRFLW(45)

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
 /*          OVRDBF     FILE(&FILEA) MBR(&MEMBERA) SHARE(*YES)  */
             ENDDO

             CALL       PGM(UC412) PARM(&PWHSE &PMCNT)
/* 4.17      CALL       PGM(UC212) PARM(&PWHSE)   */

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(&FILE) MBR(&MEMBER)
/*           CLRPFM     FILE(&FILEA) MBR(&MEMBERA)            */
             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             DLTOVR     FILE(&FILE)

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
