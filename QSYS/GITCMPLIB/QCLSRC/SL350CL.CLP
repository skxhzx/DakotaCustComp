/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL350CL   Unverified zero slot with virtual slots info.          */
/*  01 September, 1999                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    09/01/99  HNK  4.12                                            */
/*      - Created.                                                   */
/*    12/01/04  RH   5.00                                            */
/*      - Change to not join SL351 to VSLOT file.  Programs changed  */
/*        to list zero slot and any related slots not just virtual.  */
/*                                                                   */
/*    03/10/08  MLB  5.20                                            */
/*      - Fix: Revised program to correct looping problem when       */
/*        trying to delete file override that doesn't exist.         */
/*    04/21/09  MLB  5.20a                                           */
/*      - Fix: Revised program to pass *NEW to GETUNQMEM instead     */
/*        of *REUSE to solve problem with conflicting mbrs when      */
/*        multiple occurances of SL350CL run from the jobq at the    */
/*        same time.                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL350CL:    PGM        PARM(&WHSE &WHDP &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL350CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL350)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SL351PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Unverified zero slot report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Unverified zero slot report')

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
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &SECTN &RETURN +
                          &VP &JOBQ &DEV &FORM)

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
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSTAT +
                          *EQ' *BCAT &QUOTE *CAT 'Z' *CAT &QUOTE)

   /* If viewing the report, select all records for this warehouse */
   /* Skip all other selection. */

       IF         COND(&VP *EQ 'V') THEN(GOTO CMDLBL(VIEW))


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


 VIEW:

   /* Use OPNQRYF to select and order the records we need */
             OVRDBF     FILE(SL351) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(SL351) +
                          QRYSLT(&QRYSLT) KEYFLD((SLOT/SLWHSE) +
                          (SLOT/SLWHDP) (SLOT/SLSTYP) +
                          (SLOT/SLDISP)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

/*           CALL       PGM(GETUNQMEM) PARM(*REUSE SL351A &MEMBER)   (520aD) */
             CALL       PGM(GETUNQMEM) PARM(*NEW SL351A &MEMBER)  /* (520aM) */
             OVRDBF     FILE(SL351A) MBR(&MEMBER) SHARE(*YES)
             CALL       PGM(SL350A) PARM(&RETURN)    /* 5.00 */

   /* 5.00  Change following code to not join to VSLOT    */
   /*        OVRDBF     FILE(SL351) TOFILE(&FILE) SHARE(*YES)    */
   /*        OPNQRYF    FILE((&FILE) (VSLOT)) FORMAT(SL351) +    */
   /*                     QRYSLT(&QRYSLT) KEYFLD((SLOT/SLWHSE) + */
   /*                     (SLOT/SLWHDP) (SLOT/SLSTYP) +          */
   /*                     (SLOT/SLDISP)) JFLD((SLOT/SLDISP +     */
   /*                     VSLOT/VSPDIS *EQ)) JDFTVAL(*YES) +     */
   /*                     SEQONLY(*NO) OPTIMIZE(*FIRSTIO)        */

/*  If user viewed the data then we are done so exit. */

             IF (&VP = 'V') THEN(DO)
             CALL       PGM(SL352) PARM(&WHSE &WHDP &SECTN)
               GOTO       CMDLBL(OUT)
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(SL351)

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

             DLTOVR     FILE(SL351A)
             MONMSG     MSGID(CPF9841)                            /* (520 A) */
             RCLRSC     LVL(*CALLER)
/*           CLRPFM     FILE(SL351A) MBR(&MEMBER)                    (520 D) */
             RMVM       FILE(SL351A) MBR(&MEMBER)                 /* (520 M) */
             MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7310 CPF0001) +
                                                                  /* (520 A) */

             ENDPGM
