/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT750CL   Remove exported item adjustments                       */
/*  10 November, 1994                                                */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*    04/17/00  MLB  4.14a                                           */
/*      - Added OPNQRYF for file LABEL.                              */
/*      - Added call to program PT760 to remove old adjustment       */
/*        records from LABEL file.                                   */
/*    04/26/00  MLB  4.14b                                           */
/*      - Added call to pgm CMPDTE - Compute cutoff date.            */
/*    04/14/16  RTR  7.00a                                           */
/*      - Added call to pgm IT756 for removing LICADJ records.       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT750CL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT750CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT750)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT755)
             DCL        VAR(&MAINPGM2) TYPE(*CHAR) LEN(8) +
                          VALUE(PT760) /* 4.14a */
             DCL        VAR(&MAINPGM3) TYPE(*CHAR) LEN(8) +
                          VALUE(IT756) /* 7.00a */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Remove Exported item adjustments')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Removing exported item adjustments')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)

/* Don't get options if being run in *BATCH mode. */

             IF (&CMD = '*BATCH') THEN(GOTO MAIN)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &DATE &JOBQ &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ *EQ 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM('*BATCH' &WHSE +
                          &DATE)) JOB(&SBMPGM)
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 MAIN:

/* Compute cutoff date. 4.14b */

             CALL       PGM(CMPDTE) PARM('*INVADJ ' &SBMPGM &WHSE &DATE)

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'IAWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND IAUDTE *LT ' *CAT &DATE *BCAT +
                  '*AND IAUDTE *NE ' *CAT '0')

             OVRDBF     FILE(ITEMADJ) SHARE(*YES)

             OPNQRYF    FILE((ITEMADJ)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((IAWHSE) (IAITEM) (IADATE) (IATIME))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)
             CALL       PGM(&MAINPGM3) PARM(&SBMPGM &WHSE &DATE)  /* 700aA */

/*  Start 4.14a change. */

             CLOF       OPNID(ITEMADJ)
             MONMSG     MSGID(CPF4519 CPF4520)

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "A"')

             OVRDBF     FILE(LABEL10) SHARE(*YES)

             OPNQRYF    FILE((LABEL10)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((LBWHSE) (LBITEM) (LBRDTE))

             CALL       PGM(&MAINPGM2) PARM(&SBMPGM &WHSE &DATE)

/*  End of 4.14a change. */

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
