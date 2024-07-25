/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PR320CL   Print Breakdown priority replenishments                */
/*  27 October 2004                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    10/27/04  DAS  5.00                                            */
/*      - Created.                                                   */
/*    03/09/05  MLB  5.00a                                           */
/*      - Enh: Added Client custom code support to program.          */
/*    10/30/13  JCJ  6.50A                                           */
/*      - Enh: Added OVRDBF to PRPLFIL7 to solve duplicate           */
/*        breakdown replenishment labels.  The force ratio           */
/*        parm will ensure the replenishment record gets             */
/*        updated immediately to prevent a second read of the        */
/*        same record because of the files casching process.         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Donson's                                */
/*                                                                   */
/*    03/09/05  MLB  DON                                             */
/*      - Revised program to add prtf override to PLST40PW.          */
/*-------------------------------------------------------------------*/

 PR320CL:    PGM        PARM(&WHSE &WHDP &RPLT &NRPL &AISL &LPGM +
                          &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR320CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR320)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Breakdown Replenishment labels')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Breakdown replenishment +
                          labels')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&AISL)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (500aA) */
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&LPGM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LPRT)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&NRPL)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RPLT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF         COND(&CLIENT *EQ ' ') THEN(DO)            /* (500aA) */
               RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)       /* (500aA) */
             ENDDO                                                /* (500aA0 */

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &RPLT &NRPL +
                          &AISL &RETURN &JOBQ &LPGM &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &RPLT +
                          &NRPL &AISL &LPGM &DEV &FORM)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             MSGBFC     MESSAGE(&WORKINGMSG)

 REPORT:
             IF         COND(CLIENT = 'DONSONS') THEN(DO)         /* (DON A) */
               OVRPRTF    FILE(PLST40PW) TOFILE(PLST40PW) OUTQ(&DEV) +
                            FORMTYPE(&FORM)                       /* (DON A) */
             enddo                                                /* (DON A) */

             OVRDBF     FILE(PRPLFIL7) FRCRATIO(1)                /* 650A    */

             CALL       PGM(PR321) PARM(&WHSE &WHDP &RPLT &NRPL &AISL +
                          &LPGM &DEV &FORM &LPRT &RETURN)

             RMVMSG     CLEAR(*ALL)

             IF         COND(&RETURN *EQ '*NONE') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('No +
                          Priority Replenishments Found') +
                          MSGTYPE(*INFO)
             GOTO GETOUT
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE(&LPRT *BCAT 'Priority +
                          Replenishment Labels Printed')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA(&MSGDTA) +
                          MSGTYPE(*INFO)

/*  Receive any messages and pass them on  */

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

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
