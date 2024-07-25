/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PR330CL   Print Priority Replenishment report                    */
/*  19 JANUARY 2005                                                  */
/*  Bob Perry                                                        */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    01/19/05  RLP  5.00                                            */
/*      - Created using RL340                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PR330CL:    PGM        PARM(&WHSE &WHDP &JOBQ &RETURN &DEV +
                          &FORM)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR330CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR330)

  /* Report program and printer file name. */

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(PRPLFIL)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(PR331PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Priority Replenishment report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Priority Replenishment report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&DISP)       TYPE(*CHAR) LEN(12)
             DCL        VAR(&DPT#)       TYPE(*CHAR) LEN(5)
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
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP  +
                          &JOBQ &RETURN &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE +
                          &WHDP &JOBQ &RETURN &DEV &FORM)) JOB(*JOBD)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 /* REPORT:    */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF1) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('PRWHSE *EQ ' *CAT &WHSE)

             IF         COND(&WHDP *NE *ALL) THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PRWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE))
             ENDDO


   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(PR331)  TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (PIRITEM)) FORMAT(PR331) +
                          QRYSLT(&QRYSLT) KEYFLD((PRPLFIL/PRWHSE) +
                          (PRPLFIL/PRWHDP) (PRPLFIL/PRFDIS) +
                          (PIRITEM/ITITEM)) JFLD((PRPLFIL/PRITEM +
                          PIRITEM/ITITEM *EQ)) JDFTVAL(*YES)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 /* Reset pointer for QUERY file.        */
             OPNDBF     FILE(PR331) OPTION(*INP)
             POSDBF     OPNID(PR331) POSITION(*START)
             CALL       PGM(PR331) PARM(&WHSE &WHDP)

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
