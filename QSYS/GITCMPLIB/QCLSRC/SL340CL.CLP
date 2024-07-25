/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL340CL   Virtual Slot report.                                   */
/*  08 July, 1998                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Client Custom Revisions:  I Supply                               */
/*    12/22/10  GJA  6.10a                                           */
/*      - Enh. Add CLIENT code                                       */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:  I Supply                               */
/*    06/13/07  RH   ISYa                                            */
/*      - Enh. Change to not select 'SPD' aisle slots                */
/*    07/05/07  RH   ISYb                                            */
/*      - Enh. Change to not select 'SPC' and 'SPF' aisle slots      */
/*    11/18/09  GJA  ISYc                                            */
/*      - Enh. Change to not select 'BF' slot designation            */
/*    12/02/09  GJA  ISYD                                            */
/*      - Enh. Change to not select 'TRL' Aisle & rack higher than 5 */
/*-------------------------------------------------------------------*/

 SL340CL:    PGM        PARM(&WHSE &WHDP &RETURN &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL340CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL340)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SL341PR)
             DCL        VAR(&PRTFA) TYPE(*CHAR) LEN(10) VALUE(SL341APR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Virtual slot report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Virtual slot report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&ISUPPLY)    TYPE(*CHAR) LEN(10) +
                                         VALUE('ISUPPLY ')
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
/*ISYd*/     DCL        VAR(&RCKLVL)     TYPE(*CHAR) LEN(1) value('5')
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

/*  Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT *CLIENTLOC)

             RTVJOBA    TYPE(&TYPE)
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
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLRSRV +
                          *EQ' *BCAT &QUOTE *CAT 'V' *CAT &QUOTE)

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

             IF         COND(&CLIENT *EQ &ISUPPLY) THEN(DO)
   /* ISYa Skip 'SPD' aisle special order slots.          */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL +
                          *NE' *BCAT &QUOTE *CAT 'SPD' *CAT &QUOTE)
   /* ISYb Skip 'SPC'and 'SPF' aisle special order slots.          */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL +
                          *NE' *BCAT &QUOTE *CAT 'SPC' *CAT &QUOTE)
   /* ISYc Skip 'BF'  slot designation slots.             */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLSDEF +
                          *NE' *BCAT &QUOTE *CAT 'BF' *CAT &QUOTE)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL +
                          *NE' *BCAT &QUOTE *CAT 'SPF' *CAT &QUOTE)
   /* ISYd Skip rack level 6 and 7                                 */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLRLVL +
                          *LE ' *CAT &RCKLVL)
   /* ISYd Skip 'TRL' aisle                               */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'SLAISL +
                          *NE' *BCAT &QUOTE *CAT 'TRL' *CAT &QUOTE)
             ENDDO
 VIEW:

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SL341) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(SL341) QRYSLT(&QRYSLT) +
                          KEYFLD((SLOT/SLWHSE) (SLOT/SLWHDP) +
                          (SLOT/SLSTYP) (SLOT/SLDESG) +
                          (SLOT/SLSDEF)) OPTIMIZE(*FIRSTIO) +
                          SEQONLY(*NO)

/*  If user viewed the data then we are done so exit. */

             IF (&VP = 'V') THEN(DO)
             CALL       PGM(SL342) PARM(&WHSE &WHDP &SECTN)
               GOTO       CMDLBL(OUT)
             ENDDO


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(SL341)
   /* Override printer file. */

             OVRPRTF    FILE(&PRTFA) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SL341A) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(SL341A) QRYSLT(&QRYSLT) +
                          KEYFLD((SLOT/SLWHSE) (SLOT/SLWHDP) +
                          (SLOT/SLSTYP) (SLOT/SLDESG) +
                          (SLOT/SLSDEF)) OPTIMIZE(*FIRSTIO) +
                          SEQONLY(*NO)

             CALL       PGM(SL341A)

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
