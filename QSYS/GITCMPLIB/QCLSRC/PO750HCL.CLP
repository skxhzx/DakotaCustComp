/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO750HCL  Remove exported Po's - History Files                   */
/*  10 January, 2012                                                 */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/10/12  LMC  6.40                                            */
/*      - Copied from PO750CL.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO750HCL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PO750HCL)

             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(8) +
                          VALUE('PO750H  ')
  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(HS750)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PO755H)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Remove Exported purchase orders +
                          history')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Removing exported purchase orders +
                          history')

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

/* Compute cutoff date. 4.14b */

             CALL       PGM(CMPDTE) PARM('*POH    ' &SBMPGM &WHSE &DATE)

/* Use OPNQRYF to select and order the records we need */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'PHHWHS *EQ ' *CAT &WHSE *BCAT +
                  '*AND PHHEDT *LT ' *CAT &DATE *BCAT +
                  '*AND PHHEDT *NE ' *CAT '0' *BCAT +
                  '*AND %SST(PHHPO 8 2) *NE ' *CAT +
                        &QUOTE *CAT 'TF' *CAT &QUOTE)
/*           CHGVAR     VAR(&QRYSLT) VALUE( +               */
/*                     'PHWHSE *EQ ' *CAT &WHSE *BCAT +     */
/*                '*AND PHUDTE *LT ' *CAT &DATE *BCAT +     */
/*                '*AND PHUDTE *NE ' *CAT '0' *BCAT +       */
/*                '*AND %SST(PHPO 8 2) *NE ' *CAT +         */
/*                      &QUOTE *CAT 'TF' *CAT &QUOTE)       */

             OVRDBF     FILE(POHHDRH) SHARE(*YES)
/* 218       OVRDBF     FILE(POH) SHARE(*YES)     */

             OPNQRYF    FILE((POHHDRH)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((PHHWHS) (PHHPO))

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
