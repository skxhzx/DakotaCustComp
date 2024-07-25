/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LU110CL   Transactions lookup by empl#/start date                */
/*  05 January, 1996                                                 */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/24/97  RH  2.19                                             */
/*      - Correct BFCMSGF to PIRMSGF.                                */
/*    05/01/97  RH   2.20                                            */
/*      - Change MSG command to MSGBFC.                              */
/*    12/14/98  HNK  4.10                                            */
/*      - Openqry statement changed to sort records by time in       */
/*        addition to Emp# and date.                                 */
/*    11/21/00  HNK  4.15                                            */
/*      - Query selection changed from PTEDTE to PTSDTE.             */
/*    04/30/01  HNK  4.15a                                           */
/*      - Loop until Canceled in LU110 program.                      */
/*    08/07/01  HNK  4.15b                                           */
/*      - &PCREW selection added.  LU110A prog called.               */
/*    08/20/01  HNK  4.16                                            */
/*      - Initialize &FILEKY field.                                  */
/*    02/24/02  HNK  4.16a                                           */
/*      - Send from date and To date to LU111.                       */
/*    06/28/02  HNK  4.16b                                           */
/*      - Fix - Add SEQONLY=*NO to open query statement.             */
/*    09/24/08  GJA  5.20a                                           */
/*      - Add parameters to include task, category, sub category     */
/*    03/07/22  RH   7.50a                                           */
/*      - Added client custom code support to program.               */
/*      - Add User Auth and error msg to use Web Dakota program      */
/*-------------------------------------------------------------------*/

 LU110CL:    PGM        PARM(&PEMP# &PFMDT &PTODT &RETURN &PCREW)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/
/* Client ID's                                              (510 A)  */

/*CLD A*/    DCL        VAR(&CITYLINX) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINX  ')

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LU110CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LU110)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LU111)

  /* Report FILE and printer file names. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PIRTRAN2)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Transactions lookup')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Selecting records for display')

/*750aA*/    DCL        VAR(&NOAUTHRZG) TYPE(*CHAR) LEN(60) +
                          VALUE('   Use Web Dakota Task Detail EPM +
                           Report.   ')

/*750aA*/    DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
/*750aA*/    DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
/*750 A*/    DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
/*750 A*/    DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
/*750 A*/    DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILEKY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PEMP#)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PFMDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTODT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
/* Begin 5.20a  */
             DCL        VAR(&PTASK)      TYPE(*CHAR) LEN(6) VALUE('*ALL  ')
             DCL        VAR(&PWHDP)      TYPE(*CHAR) LEN(5) VALUE('*ALL ')
             DCL        VAR(&PCAT)       TYPE(*CHAR) LEN(6) VALUE('*ALL  ')
             DCL        VAR(&PSCAT)      TYPE(*CHAR) LEN(6) VALUE('*ALL  ')
             DCL        VAR(&PPRT)       TYPE(*CHAR) LEN(1) VALUE('N')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10) VALUE('*JOBD     ')
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10) VALUE('*STD      ')
             DCL        VAR(&FMTM)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TOTM)       TYPE(*CHAR) LEN(6)
/* End 5.20a  */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Begin 4.15a  */

 BEGIN:

/* End 4.15a  */

/*750aA*/    CHGVAR     VAR(&PGMID) VALUE(LU110CL)
/*750aA*/    RTVJOBA    USER(&PUSR)
/*750aA*/    RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Check if user is authorized to use this option              (750aA) */

/*750aA*/    CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
/*750aA*/    IF         COND(&PRTN *EQ '*NO')  THEN(DO)
/*750aA*/               SNDPGMMSG  MSG(&NOAUTHRZG)   +
/*750aA*/               MSGTYPE(*INFO)
/*750aA*/    RETURN
/*750aA*/    ENDDO

/*  Get options. */

/*5.20a      CALL       PGM(&OPTPGM) PARM(&PEMP# &PFMDT &PTODT +
                      &RETURN &PCREW)     */
             CALL       PGM(&OPTPGM) PARM(&PEMP# &PFMDT &PTODT +
                          &RETURN &PCREW &PTASK &PWHDP &PCAT &PSCAT +
                          &PPRT &DEV &FORM &FMTM &TOTM)


/*  See if user wants to proceed. */

             IF (&RETURN *EQ '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/* Begin 4.15b  */

 BEGIN2:


             IF (&PCREW *NE ' ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'USCREW *EQ +
                          ' *BCAT &QUOTE *CAT &PCREW *CAT &QUOTE)
             OVRDBF     FILE(PIRUSER) SHARE(*YES)
             OPNQRYF    FILE((PIRUSER)) QRYSLT(&QRYSLT) +
                          KEYFLD((USCODE)) SEQONLY(*NO)
             CALL       PGM(LU110A) PARM(&PEMP# &RETURN)
             DLTOVR     FILE(PIRUSER)
             RCLRSC     LVL(*CALLER)
             ENDDO

/* End 4.15b  */



/* Begin 4.15a  */
             IF (&RETURN *EQ '*EXIT') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO
/* End 4.15a  */

/*  Run program. */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE(' ')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTEMP# *EQ +
                          ' *CAT &PEMP#)

             IF (&PFMDT *NE ' ') THEN(DO)
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSDTE *GE +
                             ' *CAT &PFMDT)
             ENDDO

             IF (&PTODT *NE ' ') THEN(DO)
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
    /* 4.15 BEGIN CHANGE  */
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSDTE *LE +
                             ' *CAT &PTODT)
    /* 4.15 END CHANGE    */
    /* 4.15     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTEDTE *LE + */
    /* 4.15                  ' *CAT &PTODT)                               */
             ENDDO
/* Begin 5.20a  */
             IF (&PTASK *NE ' ' *AND &PTASK *NE '*ALL  ') THEN(DO)
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTTASK *EQ +
                             ' *BCAT &QUOTE *CAT &PTASK *CAT &QUOTE)
             ENDDO

             IF (&PCAT *NE ' ' *AND &PCAT *NE '*ALL  ') THEN(DO)
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTCAT *EQ  +
                             ' *BCAT &QUOTE *CAT &PCAT *CAT &QUOTE)
             ENDDO

             IF (&PSCAT *NE ' ' *AND &PSCAT *NE '*ALL  ') THEN(DO)
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
                CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PTSCAT *EQ +
                             ' *BCAT &QUOTE *CAT &PSCAT *CAT &QUOTE)
             ENDDO
/* End 5.20a  */

/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                          KEYFLD((&FILE/PTEMP#) (&FILE/PTSDTE +
                          *ASCEND) (&FILE/PTSTIM *ASCEND)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
/* 416 */
             CHGVAR     VAR(&FILEKY) VALUE(' ')
/* 416 */
             CHGVAR     VAR(&FILEKY) VALUE(&FILEKY *TCAT &PEMP#)
             CHGVAR     VAR(&RETURN) VALUE(' ')
/* 416a */
             IF (&PPRT *EQ 'N') THEN(DO)
/*520a    CALL       PGM(LU111) PARM(&FILEKY &RETURN &PFMDT &PTODT)*/
             CALL       PGM(LU111) PARM(&FILEKY &RETURN &PFMDT &PTODT +
                              &PWHDP &FMTM &TOTM)
             ENDDO
             IF (&PPRT *EQ 'Y') THEN(DO)
             OVRPRTF FILE(LU111PR) OUTQ(*DEV) DEV(&dev) +
                         FORMTYPE(&form)
             CALL       PGM(LU111A) PARM(&RETURN &PFMDT &PTODT +
                              &PWHDP &PTASK &PCAT &PSCAT &FMTM &TOTM)
             ENDDO
/* Begin 4.15a  */

             CHGVAR     VAR(&QRYSLT) VALUE(' ')
             RCLRSC     LVL(*CALLER)

/* Begin 4.15B  */
             IF (&RETURN *EQ '*EXIT') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
                GOTO       CMDLBL(GETOUT)
             ENDDO
             IF (&RETURN *EQ '*CANCEL') THEN(DO)
                IF (&PCREW *EQ ' ') THEN(DO)
                GOTO       CMDLBL(BEGIN)
                ENDDO
             ENDDO
/* End 4.15B  */

             GOTO       CMDLBL(BEGIN2)

/* End 4.15a  */

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(&FILE)
             RCLRSC     LVL(*CALLER)

             ENDPGM
