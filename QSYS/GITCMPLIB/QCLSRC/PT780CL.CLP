/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT780CL   Remove Misc. labels/ transactions.                     */
/*  26 April 2000                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    09/06/00  MLB  4.14a                                           */
/*      - Added call it IT760CL to removed closed item exception     */
/*        records.                                                   */
/*                                                                   */
/*    04/08/02  MLB  4.16                                            */
/*      - Added code for OPNQRYF to select all transfer labels &     */
/*        call program to remove them.                               */
/*                                                                   */
/*    04/08/03  MLB  4.17                                            */
/*      - Added code for OPNQRYF to select all qty re-calc label     */
/*        records with type Q and remove them.                       */
/*    04/22/03  MLB  4.17a                                           */
/*      - Added code for OPNQRYF to select all Inventory label       */
/*        records with type I and remove them.                       */
/*    05/20/03  MLB  4.17b                                           */
/*      - Added code to call new pgm IT770CL to remove old           */
/*        Item Zero Quantity records.                                */
/*                                                                   */
/*    04/25/05  MLB  5.00                                            */
/*      - Enh: Revised program to call PT786CL to remove entries     */
/*        from FLGTRAN file.                                         */
/*                                                                   */
/*    11/11/10  MLB  5.30                                            */
/*      - Enh: Revised program to call HQ750CL to remove entries     */
/*        from PCKQADJ file.                                         */
/*                                                                   */
/*    03/08/13  LMC  6.50a                                           */
/*      - Enh: Added additional call to PT785 for removing old       */
/*        pirtran records PTCAT = MISC, all status. This was         */
/*        added to deal with old idle records left in status 2       */
/*        found on clients box.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT780CL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PT780CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT780)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PT755)
             DCL        VAR(&MAINPGM2) TYPE(*CHAR) LEN(8) +
                          VALUE(PT785)

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

/* Compute cutoff date. */

             CALL       PGM(CMPDTE) PARM('*MISC   ' &SBMPGM &WHSE &DATE)

/* Use OPNQRYF to select and order the records we need */
/*   Select Slot replenishment Records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "R"')

             OVRDBF     FILE(LABEL) SHARE(*YES)

             OPNQRYF    FILE((LABEL)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABEL)
             MONMSG     MSGID(CPF4519 CPF4520)

/* Begin 4.16 code added. --------------------------------------------------- */

/* Use OPNQRYF to select Slot Transfer Records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "T"')

             OVRDBF     FILE(LABEL) SHARE(*YES)

             OPNQRYF    FILE((LABEL)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABEL)
             MONMSG     MSGID(CPF4519 CPF4520)
/* End of 4.16 code added. -------------------------------------------------- */

/* Begin 4.17 code added. --------------------------------------------------- */

/* Use OPNQRYF to select Qty Re-Calc Label records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "Q"')

             OVRDBF     FILE(LABEL) SHARE(*YES)

             OPNQRYF    FILE((LABEL)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABEL)
             MONMSG     MSGID(CPF4519 CPF4520)

/* End of 4.17 code added. -------------------------------------------------- */

/* Begin 4.17a code added. -------------------------------------------------- */

/* Use OPNQRYF to select Inventory Label records we need. */

             MSGBFC     MESSAGE('Selecting records to remove')

             CHGVAR     VAR(&QRYSLT) VALUE( +
                       'LBWHSE *EQ ' *CAT &WHSE *BCAT +
                  '*AND LBRDTE *LT ' *CAT &DATE *BCAT +
                  '*AND LBRDTE *NE ' *CAT '0' *CAT ' *and LBTYPE *EQ "I"')

             OVRDBF     FILE(LABEL) SHARE(*YES)

             OPNQRYF    FILE((LABEL)) OPTION(*ALL) +
                          QRYSLT(&QRYSLT) KEYFLD((LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(LABEL)
             MONMSG     MSGID(CPF4519 CPF4520)

/* End of 4.17 code added. -------------------------------------------------- */

             CHGVAR     VAR(&QRYSLT) VALUE('PTGDTE *LT ' *CAT &DATE +
                          *BCAT '*AND PTGDTE *NE ' *CAT '0' +
                          *BCAT '*AND PTSTAT *EQ "4"')

             OVRDBF     FILE(PIRTRAN) SHARE(*YES)

             OPNQRYF    FILE((PIRTRAN)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((PTTASK))

             CALL       PGM(&MAINPGM2) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(PIRTRAN) /* 650aA */

/* 650aA - added to cleanup MISC transactions left at any status */
             CHGVAR     VAR(&QRYSLT) VALUE('PTGDTE *LT ' *CAT &DATE +
                          *BCAT '*AND PTGDTE *NE ' *CAT '0' +
                          *BCAT '*AND PTCAT  *EQ "MISC"')

             OVRDBF     FILE(PIRTRAN) SHARE(*YES)

             OPNQRYF    FILE((PIRTRAN)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD((PTTASK))

             CALL       PGM(&MAINPGM2) PARM(&SBMPGM &WHSE &DATE)

             CLOF       OPNID(PIRTRAN)

/* 650aA - End of mod */
             MSGBFC     MESSAGE('Removing closed item exception +
                          records') /* (4.14a) */
             CALL       PGM(IT760CL) PARM('*BATCH' &WHSE &DATE) /* +
                          (4.14a) */

/* Begin 4.17b code added. -------------------------------------------------- */

             MSGBFC     MESSAGE('Removing Item Zero Quantity records')
             CALL       PGM(IT770CL) PARM('*BATCH' &WHSE &DATE)

/* End of 4.17b code added. ------------------------------------------------- */


/* Begin 5.00 code added. --------------------------------------------------- */

             MSGBFC     MESSAGE('Removing FLGTRAN records')
             CALL       PGM(PT786CL) PARM('*BATCH' &WHSE &DATE)

/* End of 5.00 code added. -------------------------------------------------- */

/* Begin 5.30 code added. --------------------------------------------------- */

             MSGBFC     MESSAGE('Removing PCKQADJ records')
             CALL       PGM(HQ750CL) PARM('*BATCH' &WHSE &DATE)

/* End of 5.30 code added. -------------------------------------------------- */

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
