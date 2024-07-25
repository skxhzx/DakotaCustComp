/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV170CL   Inventory variance re-count sheet                      */
/*  30 April, 2002                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    09/24/06  RH   5.10a                                           */
/*      - Add &PASL parameter, &FILEB and MEMBERB                    */
/*                                                                   */
/*    01/29/11  GJA  6.40a                                           */
/*      - Fix: Revised pgm to remove member on exit.                 */
/*    12/20/12  MLB  6.40b                                           */
/*      - Fix: Revised pgm to correct errors that 6.40a mod caused   */
/*        when pgm submitted to batch.                               */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV170CL:    PGM        PARM(&PWHSE &PITM &PVAR &PASL &JOBQ &RETURN +
                          &DEV &FORM &MEMBER &MEMBERA &MEMBERB)
/*  5.10                  &DEV &FORM &MEMBER &MEMBERA) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV170CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV170)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV171)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(IV171)
             DCL        VAR(&FILEA) TYPE(*CHAR) LEN(10) VALUE(IV172)
             DCL        VAR(&FILEB) TYPE(*CHAR) LEN(10) VALUE(IV173)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IV172PR)
             DCL        VAR(&PRTBF) TYPE(*CHAR) LEN(10) VALUE(IV173PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Inventory variance re-count sheet')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing inventory variance recount +
                          sheet')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBERA)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBERB)    TYPE(*CHAR) LEN(10)   /* 5.10 */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PITM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&PASL)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&PVAR)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

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

             IF (&MEMBERA = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILEA &MEMBERA)
                ENDDO
             IF (&MEMBERB = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE &FILEB &MEMBERB)
                ENDDO

             OVRDBF     FILE(&FILEA) MBR(&MEMBERA) SHARE(*YES)
             OVRDBF     FILE(&FILEB) MBR(&MEMBERB) SHARE(*YES)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &PITM &PVAR +
                          &PASL &JOBQ &RETURN &DEV &FORM)
    /*  5.10              &JOBQ &RETURN &DEV &FORM)   */


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               DLTOVR     FILE(*ALL)                              /* (640bA) */
               MONMSG     MSGID(CPF9841)                          /* (640bA) */
               RMVM       FILE(&FILE) MBR(&MEMBER)                /* (640bA) */
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)              /* (640bA) */
               RMVM       FILE(&FILEA) MBR(&MEMBERA)              /* (640bA) */
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)              /* (640bA) */
               RMVM       FILE(&FILEB) MBR(&MEMBERB)              /* (640bA) */
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)              /* (640bA) */
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PWHSE &PITM &PVAR +
                        &PASL &JOBQ &RETURN &DEV &FORM &MEMBER &MEMBERA)) +
                        JOB(AAIV170CL)
/* 4.11                   &RETURN &DEV &FORM &MEMBER)) JOB(&SBMPGM)  */
   /*  5.10             &JOBQ &RETURN &DEV &FORM &MEMBER &MEMBERA)) +  */
/*             GOTO       CMDLBL(GETOUT)                             (640bD) */
               RETURN                                             /* (640bM) */
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:


             CALL       PGM(IV171) PARM(&PWHSE &PITM &PVAR &PASL)
  /*  5.10   CALL       PGM(IV171) PARM(&PWHSE &PITM &PVAR)  */

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(&FILEA) MBR(&MEMBERA) SHARE(*YES)
             OVRDBF     FILE(&FILEB) MBR(&MEMBERB) SHARE(*YES) /*  5.10 */
             ENDDO

/*  If item or *all selected */
             IF (&PASL = ' ') THEN(DO)
             CALL       PGM(IV172) PARM(&PWHSE &PITM &PVAR)
             ENDDO

/*  If Aisle or *all selected */
             IF (&PITM = ' ') THEN(DO)
             CALL       PGM(IV173) PARM(&PWHSE &PASL &PVAR)
             ENDDO

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
/*6.40a      CLRPFM     FILE(&FILE) MBR(&MEMBER)           */
/*6.40a      CLRPFM     FILE(&FILEA) MBR(&MEMBERA)         */
/*6.40a      CLRPFM     FILE(&FILEB) MBR(&MEMBERB)         */
             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             DLTOVR     FILE(&FILE)
/*6.40a */   MONMSG     MSGID(CPF9841)
/*6.40a */   DLTOVR     FILE(&FILEA)
/*6.40a */   MONMSG     MSGID(CPF9841)
/*6.40a */   DLTOVR     FILE(&FILEB)
/*6.40a */   MONMSG     MSGID(CPF9841)
/*6.40a */   RMVM       FILE(&FILEB) MBR(&MEMBERB)
/*6.40a */   MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
/*6.40a */                CPF7301 CPF7310 CPF0001)
/*6.40a */   RMVM       FILE(&FILEA) MBR(&MEMBERA)
/*6.40a */   MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
/*6.40a */                CPF7301 CPF7310 CPF0001)
/*6.40a */   RMVM       FILE(&FILE) MBR(&MEMBER)
/*6.40a */   MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
/*6.40a */                CPF7301 CPF7310 CPF0001)

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
