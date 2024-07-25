/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL380CL   Slots with negative quantity                           */
/*  16 July, 2001                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    07/16/01  RH   4.15                                            */
/*      - Created.                                                   */
/*    05/24/04  RH   4.17a                                           */
/*      - Add Sort by Item/Slot option                               */
/*                                                                   */
/*    06/22/05  MLB  5.00                                            */
/*      - Fix: Revised program to add MONMSG to DLTOVR commands.     */
/*        Added MONMSG to CLRPFM for SL381B.                         */
/*        Added CLRPFM and MONMSG for SL381A.                        */
/*        Added missing parms to SBMJOB command. Revised PGM cmd     */
/*        to add missing parms. Adding these parms will require a    */
/*        change to menu PIRRPT, too. Missing parms: &SECTN, &SORT,  */
/*        &VP.                                                       */
/*    12/27/05  RH   5.00a                                           */
/*      - ENH: Do not select slot with blank item#.                  */
/*    10/15/08  JCJ  5.20                                            */
/*      - FIX: Added code for second printer file.                   */
/*    04/25/14  RBD  6.50a                                           */
/*      - ENH: Allow selection of Pick slots, Overflow slots, or     */
/*        both.  This requires adding parm &PICK to menu PIRRPT too. */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL380CL:    PGM        PARM(&WHSE &WHDP &SECTN &PICK &SORT &VP &RETURN +
                          &DEV &FORM)                            /* (650aM) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL380CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL380)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SL382PR)
             DCL        VAR(&PRT2) TYPE(*CHAR) LEN(10) VALUE(SL384PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Negative quantity slots report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Negative quantity slot report')

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
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)   /*4.17a*/
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(1)   /*650aA*/

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SECTN &PICK &SORT +
                          &RETURN &VP &JOBQ &DEV &FORM)       /*650aM*/

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP &SECTN +
                          &PICK &SORT &VP &RETURN &DEV &FORM)) JOB(&SBMPGM) +
                                                                  /* (650aM) */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */
   /* 520 */
             IF (&SORT = 'I') THEN(DO)
             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             ENDDO

             IF (&SORT = 'S') THEN(DO)
             OVRPRTF    FILE(&PRT2) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             ENDDO
   /* 520 */
   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('SLWHSE *EQ ' *CAT &WHSE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')     /* 500a */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLITEM +
                          *NE' *BCAT &QUOTE *CAT ' ' *CAT &QUOTE)
   /*        CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')   */
   /*        CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT + */
   /*                     *EQ' *BCAT &QUOTE *CAT 'Z' *CAT &QUOTE)  */

   /* If viewing the report, select all records for this warehouse */
   /* Skip all other selection. */

             IF         COND(&VP *EQ 'V') THEN(GOTO CMDLBL(VIEW))


             IF (&WHDP *NE '*ALL') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLWHDP *EQ +
                          ' *BCAT &QUOTE *CAT &WHDP *CAT &QUOTE)
             ENDDO

  /* 6.50a Begin */
             IF (&PICK *EQ 'O') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK +
                          *EQ' *BCAT &QUOTE *CAT 'N' *CAT &QUOTE)
             ENDDO

             IF (&PICK *EQ 'P') THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLPICK +
                          *EQ' *BCAT &QUOTE *CAT 'Y' *CAT &QUOTE)
             ENDDO
  /* 6.50aA End */

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


 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SL381) TOFILE(&FILE) SHARE(*YES)
             IF (&SORT = 'I') THEN(DO)
             OPNQRYF    FILE((&FILE)) FORMAT(SL381) QRYSLT(&QRYSLT) +
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
             ENDDO

             IF (&SORT = 'S') THEN(DO)
             OPNQRYF    FILE((&FILE)) FORMAT(SL381) QRYSLT(&QRYSLT) +
                          KEYFLD((*MAPFLD/OQWHSE) +
                                 (*MAPFLD/OQWHDP) +
                                 (*MAPFLD/OQDISP) +
                                 (*MAPFLD/OQITEM)) +
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
                                 (OQRCV3  SLRCV3))
             ENDDO
             GOTO       CMDLBL(PROCESS)

 PROCESS:
/*    - Override file to use unique member.           */
                CALL       PGM(GETUNQMEM) PARM(*REUSE SL381A &MEMBER)
             OVRDBF     FILE(SL381A) MBR(&MEMBER) SHARE(*YES)
                CALL       PGM(GETUNQMEM) PARM(*REUSE SL381B &MEMBER)
             OVRDBF     FILE(SL381B) MBR(&MEMBER) SHARE(*YES)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
/*650aM*/    CALL       PGM(SL381) PARM(&SORT &PICK &RETURN)


/*  If user viewed the data then we are done so exit. */

             IF (&VP = 'V') THEN(DO)
             IF (&SORT = 'I') THEN(DO)
             CALL       PGM(SL383) PARM(&WHSE &WHDP &SECTN)
               GOTO       CMDLBL(OUT)
             ENDDO
             IF (&SORT = 'S') THEN(DO)
             CALL       PGM(SL385) PARM(&WHSE &WHDP &SECTN)
               GOTO       CMDLBL(OUT)
             ENDDO
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/*           CALL       PGM(SL382)      4.17a  */
             IF (&VP = 'P') THEN(DO)             /* 4.17a*/
             IF (&SORT = 'I') THEN(DO)
 /*650aM*/   CALL       PGM(SL382) PARM(&PICK)
               GOTO       CMDLBL(OUT)
             ENDDO
             IF (&SORT = 'S') THEN(DO)
             CALL       PGM(SL384) PARM(&PICK)
               GOTO       CMDLBL(OUT)
             ENDDO
             ENDDO

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

             DLTOVR     FILE(SL381A)
             MONMSG     MSGID(CPF9841) /* Ignore override not found. (500 A) */
             DLTOVR     FILE(SL381B)
             MONMSG     MSGID(CPF9841) /* Ignore override not found. (500 A) */
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(SL381A) MBR(&MEMBER)                 /* (500 A) */
             MONMSG     MSGID(CPF3130 CPF3133 CPF3137 CPF3141 +
                          CPF3142 CPF3144 CPF3156 CPF3203 CPF0001) +
                          /* Ignore mbr not cleared.                 (500 A) */
             CLRPFM     FILE(SL381B) MBR(&MEMBER)
             MONMSG     MSGID(CPF3130 CPF3133 CPF3137 CPF3141 +
                          CPF3142 CPF3144 CPF3156 CPF3203 CPF0001) +
                          /* Ignore mbr not cleared.                 (500 A) */

             ENDPGM
