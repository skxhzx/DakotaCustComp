/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL400CL   Used and Available Slots                               */
/*  13 Aug, 2001                                                     */
/*  Hemant Kapadia                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/13/01  HNK  4.16                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL400CL:    PGM        PARM(&WHSE &RETURN &DEV &FORM &STYP)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL400CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL400)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SL401PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Used and Available Slots')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Used and Available Slots Report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&STYP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &STYP)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN  +
                          &DEV &FORM &STYP)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)

             IF (&RETURN = '*PIR') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'P' *CAT &QUOTE)
             ENDDO

             IF (&RETURN = '*FIXED') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'F' *CAT &QUOTE)
             ENDDO


   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SL401) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((SLOT) (SLOTDEF)) FORMAT(SL401) +
                          QRYSLT(&QRYSLT) KEYFLD((1/SLSTYP) +
                          (1/SLWHDP) (SLSDEF)) JFLD((SLOT/SLSDEF +
                          SLOTDEF/SDCODE *EQ))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(SL401) PARM(&STYP)

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
 NOMSG:

   /* Clean up before leaving */

   /*        DLTOVR     FILE(&PRTF)   */
             RCLRSC     LVL(*CALLER)

             ENDPGM
