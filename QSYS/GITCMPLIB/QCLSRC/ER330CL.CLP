/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ER330CL   Print Put-away/Returns transaction by employee         */
/*  01 July, 1999                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    05/01/97  HNK  4.11                                            */
/*      - Created                                                    */
/*                                                                   */
/*    09/18/09  GJA  5.30                                            */
/*      - Cleaned up and revamped for suspended transactions.        */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ER330CL:    PGM        PARM(&FMDT &TODT &WHSE &EMP# &JOBQ &RETURN +
                            &DEV &FORM &FMTM &TOTM)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                              (750aA)  */

  /* Name of this program. */
             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER330CL)

  /* Option program. */
             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(ER330)

  /* Report program and printer file name. */
             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(PIRTRAN)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(ER331PR)

  /* Informational message. */
             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Put-away/Returns transactions')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Put-away/Returns transactions'   )

/*750aA*/    DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('   Use Web Dakota EPM PutAway +
                           Crew Report.  ')
/*750aA*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*750aA*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*750 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*750 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*750 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&FMTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TOTM)       TYPE(*CHAR) LEN(6)

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
             CALL       PGM(&OPTPGM) PARM(&FMDT &TODT &WHSE &EMP#  +
                          &JOBQ &RETURN &DEV &FORM &FMTM &TOTM)

/*  See if user wants to proceed. */
             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/* See if user wants to put report on jobq. */
             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&FMDT &TODT &WHSE +
                          &EMP# &JOBQ &RETURN &DEV &FORM &FMTM +
                          &TOTM)) JOB(*JOBD)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('PTWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                          '%SST(PTGRP1 1 1) = %VALUES("P" "R")')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTSDTE  +
                          *GE ' *CAT &FMDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTSDTE  +
                          *LE ' *CAT &TODT))

             IF         COND(&EMP# *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PTEMP#  +
                          *EQ ' *CAT &EMP#))
             ENDDO

   /* Use OPNQRYF to select and order the records we need */
             OVRDBF     FILE(ER331)  TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (LICENSE) (LABEL)) +
                          FORMAT(ER331) QRYSLT(&QRYSLT) +
                          KEYFLD((PIRTRAN/PTEMP#) (PIRTRAN/PTSDTE) +
                          (PIRTRAN/PTSTIM)) JFLD((PIRTRAN/PTTRN# +
                          LICENSE/LITRN#) (PIRTRAN/PTTRN# +
                          LABEL/LBTRN#)) JDFTVAL(*YES)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(ER331) PARM(&WHSE &EMP# &FMDT &TODT +
                                        &FMTM &TOTM)
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

             ENDPGM
