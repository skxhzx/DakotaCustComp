/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT780HCL  Remove Misc. labels/ transactions - History            */
/*  13 January 2012                                                  */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/13/12  LMC  6.40                                            */
/*      - Create - copied from PT780CL to process history files      */
/*        in place of original files.                                */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT780HCL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PT780HCL)

             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(8) +
                          VALUE('PT780H  ')
  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(HS750)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT755H)
             DCL        VAR(&MAINPGM2) TYPE(*CHAR) LEN(8) +
                          VALUE(PT785H)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Remove misc. labels/transactions')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Removing misc. labels/transactions')

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

/* Compute cutoff date. */

             CALL       PGM(CMPDTE) PARM('*MISCH  ' &SBMPGM &WHSE &DATE)

/* Use OPNQRYF to select and order the records we need */
/*   Select Slot replenishment Records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "R"')

             OVRDBF     FILE(LABELH) SHARE(*YES)

             OPNQRYF    FILE((LABELH)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABELH)
             MONMSG     MSGID(CPF4519 CPF4520)

/* Begin 4.16 code added. --------------------------------------------------- */

/* Use OPNQRYF to select Slot Transfer Records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "T"')

             OVRDBF     FILE(LABELH) SHARE(*YES)

             OPNQRYF    FILE((LABELH)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABELH)
             MONMSG     MSGID(CPF4519 CPF4520)
/* End of 4.16 code added. -------------------------------------------------- */

/* Begin 4.17 code added. --------------------------------------------------- */

/* Use OPNQRYF to select Qty Re-Calc Label records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "Q"')

             OVRDBF     FILE(LABELH) SHARE(*YES)

             OPNQRYF    FILE((LABELH)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABELH)
             MONMSG     MSGID(CPF4519 CPF4520)

/* End of 4.17 code added. -------------------------------------------------- */

/* Begin 4.17a code added. -------------------------------------------------- */

/* Use OPNQRYF to select Inventory Label records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "I"')

             OVRDBF     FILE(LABELH) SHARE(*YES)

             OPNQRYF    FILE((LABELH)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABELH)
             MONMSG     MSGID(CPF4519 CPF4520)

/* End of 4.17 code added. -------------------------------------------------- */

             CHGVAR     VAR(&QRYSLT) VALUE('PTGDTE *LT ' *CAT &DATE +
                          *BCAT '*AND PTGDTE *NE ' *CAT '0' +
                          *BCAT '*AND PTSTAT *EQ "4"')

             OVRDBF     FILE(PIRTRANH) SHARE(*YES)

             OPNQRYF    FILE((PIRTRANH)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((PTTASK))

             CALL       PGM(&MAINPGM2) PARM(&SBMPGM &WHSE &DATE)


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
