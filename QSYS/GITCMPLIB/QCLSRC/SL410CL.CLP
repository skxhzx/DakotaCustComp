/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL410CL   Pick slots only with overflow                          */
/*  21 August, 2001                                                  */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    08/21/01  RH   4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL410CL:    PGM        PARM(&WHSE &WHDP &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL410CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL410)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SL412PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Pick slots only with overflow')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Pick slots only with overflow')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
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
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&AISLE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SECTN &AISLE +
                          &RETURN &VP &JOBQ &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP +
                          &RETURN &DEV &FORM)) JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK +
                          *EQ' *BCAT &QUOTE *CAT 'Y' *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLITEM +
                          *NE' *BCAT &QUOTE *CAT ' ' *CAT &QUOTE)

   /* If viewing the report, select all records for this warehouse */
   /* Skip all other selection. */

   /*        IF         COND(&VP *EQ 'V') THEN(GOTO CMDLBL(VIEW))  */


             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

             IF (&RETURN = '*PIR') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'P' *CAT &QUOTE)
             ENDDO

             IF (&RETURN = '*FIXED') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'F' *CAT &QUOTE)
             ENDDO


             IF (&RETURN = '*XDOCK') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTYP +
                          *EQ' *BCAT &QUOTE *CAT 'X' *CAT &QUOTE)
             ENDDO

             IF (&AISLE > ' ') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL +
                          *EQ' *BCAT &QUOTE *CAT &AISLE *CAT &QUOTE)
             ENDDO


 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SL411) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(SL411) QRYSLT(&QRYSLT) +
                          KEYFLD((*MAPFLD/OQWHSE) +
                                 (*MAPFLD/OQWHDP) +
                                 (*MAPFLD/OQITEM) +
                                 (*MAPFLD/OQDISP)) +
                          MAPFLD((OQWHSE SLWHSE) +
                                 (OQWHDP SLWHDP) +
                                 (OQAISL  SLAISL) +
                                 (OQLOC   SLLOC)  +
                                 (OQRLVL  SLRLVL) +
                                 (OQHAND  SLHAND) +
                                 (OQSIDE  SLSIDE) +
                                 (OQSTYP  SLSTYP) +
                                 (OQDISP  SLDISP) +
                                 (OQSTAT  SLSTAT) +
                                 (OQSDTE  SLSDTE) +
                                 (OQSTIM  SLSTIM) +
                                 (OQSDEF  SLSDEF) +
                                 (OQDESG  SLDESG) +
                                 (OQACTV  SLACTV) +
                                 (OQBLD   SLBLD) +
                                 (OQPICK  SLPICK) +
                                 (OQPSEQ  SLPSEQ) +
                                 (OQPRTY  SLPRTY) +
                                 (OQENTD  SLENTD) +
                                 (OQEXPD  SLEXPD) +
                                 (OQSLFD  SLSLFD) +
                                 (OQRSRV  SLRSRV) +
                                 (OQITEM  SLITEM) +
                                 (OQSTK1  SLSTK1) +
                                 (OQSTK2  SLSTK2) +
                                 (OQSTK3  SLSTK3) +
                                 (OQALC1  SLALC1) +
                                 (OQALC2  SLALC2) +
                                 (OQALC3  SLALC3) +
                                 (OQTFR1  SLTFR1) +
                                 (OQTFR2  SLTFR2) +
                                 (OQTFR3  SLTFR3) +
                                 (OQPCK1  SLPCK1) +
                                 (OQPCK2  SLPCK2) +
                                 (OQPCK3  SLPCK3) +
                                 (OQRCV1  SLRCV1) +
                                 (OQRCV2  SLRCV2) +
                                 (OQRCV3  SLRCV3))+
                          /*     MAPFLD((OQWHSE +
                          SLWHSE)) SEQONLY(*NO) + */

 PROCESS:
/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE SL411A &MEMBER)
             OVRDBF     FILE(SL411A) MBR(&MEMBER) SHARE(*YES)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             CALL       PGM(SL411) PARM(&RETURN)


/*  If user viewed the data then we are done so exit. */

             IF (&VP = 'V') THEN(DO)
             CALL       PGM(SL413) PARM(&WHSE &WHDP &SECTN)
               GOTO       CMDLBL(OUT)
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(SL412)

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

             DLTOVR     FILE(SL411A)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(SL411A) MBR(&MEMBER)

             ENDPGM
