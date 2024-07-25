/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV300CL   Inventory Unentered Slot Sheet                         */
/*  04 January 2017                                                  */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    01/04/17  GJA  7.00                                            */
/*      - Created  copied from IV170CL                               */
/*-------------------------------------------------------------------*/

 IV300CL:    PGM        PARM(&PWHSE &PITM &PVAR &PASL &JOBQ &RETURN +
                          &DEV &FORM &MEMBER &MEMBERA &MEMBERB)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IV300CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV300)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IV301)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(IV301)
             DCL        VAR(&FILEA) TYPE(*CHAR) LEN(10) VALUE(IV302)
             DCL        VAR(&FILEB) TYPE(*CHAR) LEN(10) VALUE(IV303)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(IV302PR)
             DCL        VAR(&PRTBF) TYPE(*CHAR) LEN(10) VALUE(IV303PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Inventory unentered slots sheet')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing inventory unentered slots +
                          sheet')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBERA)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBERB)    TYPE(*CHAR) LEN(10)
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


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               DLTOVR     FILE(*ALL)
               MONMSG     MSGID(CPF9841)
               RMVM       FILE(&FILE) MBR(&MEMBER)
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)
               RMVM       FILE(&FILEA) MBR(&MEMBERA)
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)
               RMVM       FILE(&FILEB) MBR(&MEMBERB)
               MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                            CPF7301 CPF7310 CPF0001)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PWHSE &PITM &PVAR +
                        &PASL &JOBQ &RETURN &DEV &FORM &MEMBER &MEMBERA)) +
                        JOB(AAIV300CL)
               RETURN
             ENDDO

/*  Otherwise, run program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:


             CALL       PGM(IV301) PARM(&PWHSE &PITM &PVAR &PASL)

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

             IF (&TYPE = '0') THEN(DO)
             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(&FILEA) MBR(&MEMBERA) SHARE(*YES)
             OVRDBF     FILE(&FILEB) MBR(&MEMBERB) SHARE(*YES)
             ENDDO

/*  If item or *all selected */
             IF (&PASL = ' ') THEN(DO)
             CALL       PGM(IV302) PARM(&PWHSE &PITM &PVAR)
             ENDDO

/*  If Aisle or *all selected */
             IF (&PITM = ' ') THEN(DO)
             CALL       PGM(IV303) PARM(&PWHSE &PASL &PVAR)
             ENDDO

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)
             DLTOVR     FILE(&FILEA)
             MONMSG     MSGID(CPF9841)
             DLTOVR     FILE(&FILEB)
             MONMSG     MSGID(CPF9841)
             RMVM       FILE(&FILEB) MBR(&MEMBERB)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
             RMVM       FILE(&FILEA) MBR(&MEMBERA)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)
             RMVM       FILE(&FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310 CPF0001)

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
