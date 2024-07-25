/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DD210CL   Create item tie/highs                                  */
/*  26 April, 1996                                                   */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Note: &WHSE and &HANG are defined as 15 long with 5 decimal      */
/*        numbers, because otherwise decimal data error occurs       */
/*        when the job is submitted on JOBQ. In RPG programs that    */
/*        send and receive the parameters, will also define the      */
/*        numbers as 15 long with 5 decimals.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*                                                                   */
/*    07/23/97  DAS  4.04                                            */
/*      - Added section.                                             */
/*    01/20/98  RH   4.08                                            */
/*      - Added New definitions only option and create from          */
/*        slot type def. or slot types item occupies options.        */
/*                                                                   */
/*    08/31/04  MLB  5.00                                            */
/*      - Enh: Added support to program to allow user to select      */
/*        slots to create tie/highs by aisle.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DD210CL:    PGM        PARM(&WHSE &WHDP &STYP &AISL &ITEM &HANG &NEWD +
                            &TDEF &CLRF)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(DD210CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(DD210)

  /* Report program and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRITEM)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create item tie/highs')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating item tie/highs')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&AISL)       TYPE(*CHAR) LEN(4)       /* (500 A) */
             DCL        VAR(&CLRF)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&NEWD)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TDEF)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&HANG)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&STYP)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE3)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(15)
             DCL        VAR(&WHSE3A)     TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &STYP &AISL &ITEM  +
                            &HANG &NEWD &TDEF &CLRF &RETURN &JOBQ)


/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP +
                          &STYP &AISL &ITEM &HANG &CLRF)) JOB(&SBMPGM)
               GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             MSGBFC     MESSAGE('Selecting records')

 REPORT:

/*  See if user wants to clear work file (TIEHIGH).    */

             IF (&CLRF = 'Y') THEN(DO)
             CLRPFM     FILE(TIEHIGH)
             ENDDO

             CHGVAR     VAR(&WHSEA) VALUE(&WHSE)
             CHGVAR     VAR(&WHSE3) VALUE(&WHSE)
             CHGVAR     VAR(&WHSE3A) VALUE(&WHSE3)

   /* Create selection criteria string. */

   /* Select warehouse.                 */

             CHGVAR     VAR(&QRYSLT) VALUE('ITWHSE *EQ ' *CAT &WHSE3A)

   /* Select department.                */

             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

   /* Select section.                */

             IF (&STYP *NE 'B') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITSTYP *EQ +
                          ' *BCAT &QUOTE *CAT &STYP *CAT &QUOTE)
             ENDDO

   /* Select items.                     */

             IF (&ITEM *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITITEM *EQ +
                          ' *BCAT &QUOTE *CAT &ITEM *CAT &QUOTE)
             ENDDO


             OVRDBF     FILE(PIRITEM) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                          KEYFLD((ITWHSE) (ITITEM))

             IF (&TDEF *EQ 'Y') THEN(DO)
             CALL       PGM(DD212) PARM(&WHSE &WHDP &STYP &AISL &ITEM +
                          &HANG &CLRF &NEWD)
             ENDDO
             IF (&TDEF *EQ 'N') THEN(DO)
             CALL       PGM(DD213) PARM(&WHSE &WHDP &STYP &AISL &ITEM +
                          &HANG &CLRF &NEWD)
             ENDDO

             GOTO NOMSG

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
