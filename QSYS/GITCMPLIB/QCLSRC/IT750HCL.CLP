/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT750HCL  Remove old adustment records from the LABELH File.     */
/*  12 January, 2012                                                 */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/12/12  LMC  6.40                                            */
/*      - created - copied from IT750CL-removed call to IT755        */
/*        becauSE it does not process any history files              */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT750HCL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(IT750HCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(HS750)

  /* Main program. */

  /*         DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(IT755)  */ /* not needed for history*/
             DCL        VAR(&MAINPGM2) TYPE(*CHAR) LEN(8) +
                          VALUE(PT760H)

             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(8) +
                          VALUE('IT750H  ')

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                         VALUE('Remove label history item adjustments')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                       VALUE('Removing label history item adjustments')

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

/* Compute cutoff date. 4.14b */

             CALL       PGM(CMPDTE) PARM('*INVADJH' &SBMPGM &WHSE &DATE)


             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "A"')

             OVRDBF     FILE(LABELH10) SHARE(*YES)

             OPNQRYF    FILE((LABELH10)) OPTION(*ALL) QRYSLT(&QRYSLT) +
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
