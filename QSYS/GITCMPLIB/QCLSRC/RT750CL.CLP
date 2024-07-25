/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RT750CL   Remove route records.                                  */
/*  24 September, 1997                                               */
/*  Dave Sommerville                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    04/26/00  MLB  4.14a                                           */
/*      - Added call to pgm CMPDTE - Compute cutoff date.            */
/*                                                                   */
/*    04/08/03  MLB  4.17                                            */
/*      - Revised OPNQRYF to include routes with status '8' or '9'.  */
/*        Routes at these statuses have been deleted from open,      */
/*        built/picked status.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RT750CL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Program type. */

             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(8) +
                          VALUE('*ALL    ')
             DCL        VAR(&ORDTYPE) TYPE(*CHAR) LEN(1) +
                          VALUE(' ')

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RT750CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(RT750)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(RT755)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Remove route records')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Removing route records')

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

/* Don't get options if being run from JOBQ. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)

/* Don't get options if being run in *BATCH mode. */

             IF (&CMD = '*BATCH') THEN(GOTO MAIN)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PGMTYPE &WHSE &DATE &JOBQ +
                          &RETURN)

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

/* Compute cutoff date. 4.14a */

             CALL       PGM(CMPDTE) PARM('*ROUTE  ' &SBMPGM &WHSE &DATE)

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE('RHWHSE *EQ ' *CAT &WHSE *BCAT +
                          '*AND RHSTAT *EQ ' *BCAT &QUOTE *CAT '6' *CAT &QUOTE +
                          *BCAT '*AND RHEXPD *LT ' *CAT &DATE *BCAT '*AND +
                          RHEXPD *NE ' *CAT '0')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR (' +
                          *CAT 'RHWHSE *EQ ' *CAT &WHSE *BCAT +
                          '*AND RHSTAT *GE ' *BCAT &QUOTE *CAT +
                          '8' *CAT &QUOTE *BCAT '*AND RHIMPD *LT +
                          ' *CAT &DATE *BCAT '*AND RHIMPD *NE ' +
                          *CAT '0' *CAT ')') /* 4.17 */

             OVRDBF     FILE(RTEHED) SHARE(*YES)

             OPNQRYF    FILE((RTEHED)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((RHWHSE) (RHRTID))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

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
