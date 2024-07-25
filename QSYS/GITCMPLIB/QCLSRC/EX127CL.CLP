/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EX127CL   PO Quantity exception report                           */
/*  13 December 2006                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    12/13/06  RH   5.10                                            */
/*      - Created using EX125CL                                      */
/*    03/18/09  RH   5.20a                                           */
/*      - Enh: Add &CMD to run option screen when called from menu.  */
/*    04/16/09  RH   5.20B                                           */
/*      - Enh: Pass &DEV and &FORM to EX128                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

/* 520a EX127CL:    PGM        PARM(&WHSE &PO &EXDT &EXTI &RETURN) */
 EX127CL:    PGM        PARM(&CMD &WHSE &PO &EXDT &EXTI +
                             &EXTDT &RETURN) /* 520a */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EX127CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(EX127)                     /* 520a */

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(POHEXCP)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(EX128PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('PO Quantity exception report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing PO quantity exception report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)  /* 520a */
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10) VALUE('*DFT')
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10) VALUE('*STD')
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PO)         TYPE(*CHAR) LEN(9)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&EXDT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXTI)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&EXTDT)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXTTI)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&STAT)       TYPE(*CHAR) LEN(1) /* (4.14a) */

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)
/* Don't get options if being run from program.    520a */
             IF (&CMD = '*VIEWPO') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &PO &EXDT &EXTDT)     /* 520*/
/*           CALL       PGM(&OPTPGM) PARM(&WHSE &PO &RETURN +  */
/*                        &JOBQ &DEV &FORM)                    */

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &PO +
                          &RETURN &DEV &FORM)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */
   /* Override executed in EX128  */


   /* Create selection criteria string. */

   /* If called from progam to print one PO */
             IF (&CMD = '*VIEWPO') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE('PHEWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'PHEPO *EQ +
                          ' *BCAT &QUOTE *CAT &PO *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PHEEDT  +
                          *EQ ' *CAT &EXDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PHEETI  +
                          *EQ ' *CAT &EXTI))
             ENDDO

   /* If called from progam to print one PO  520a */
             IF (&CMD = '*PRNTPO') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE('PHEWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PHEEDT  +
                          *GE ' *CAT &EXDT))
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('PHEEDT  +
                          *LE ' *CAT &EXTDT))

             ENDDO

 PRINT:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                          KEYFLD((POHEXCP/PHEWHS) (POHEXCP/PHEPO) +
                          (POHEXCP/PHESEQ) (POHEXCP/PHEITM) +
                          (POHEXCP/PHEEDT) (POHEXCP/PHEETI) +
                          (POHEXCP/PHECOD)) SEQONLY(*NO) +
                          OPTIMIZE(*FIRSTIO)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

 /* 520a     CALL       PGM(EX128)  PARM(&WHSE &PO &EXDT &EXTI)  */
             CALL       PGM(EX128)  PARM(&WHSE &PO &EXDT &EXTI &EXTDT +
                        &DEV &FORM)

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
