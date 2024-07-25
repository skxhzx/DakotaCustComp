/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RU360CL   Print Runner Pick List                                 */
/*  17 May 2004                                                      */
/*  Max Blacknik                                                     */
/*  Note: This program is called from RU120 and RU210 so the option  */
/*        program is disabled.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/17/04  MLB  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    06/24/09  CWM  5.20                                            */
/*      - ADDED PRINT OVERRIDE CHANGES                               */
/*                                                                   */
/*    04/21/11  GJA  6.40a                                           */
/*      - Add client code                                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/* Custom Client Revision:  Coastal                                  */
/*    04/22/11  GJA  CSPa                                            */
/*      - If printer is override in RU120 window, do not use print   */
/*        override process                                           */
/*-------------------------------------------------------------------*/

 RU360CL:    PGM        PARM(&CMD &WHSEA &TRN#A &DEV &FORM &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU360CL)

  /* Option program. */

  /*         DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU360)                       */
             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR100)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RUNNER)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(RU365PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Print Runner Pick List')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Runner Pick List')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
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
             DCL        VAR(&TRN#)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&TRN#A)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

/* 520 A */  DCL        VAR(&CMD2)   TYPE(*CHAR) LEN(1024)
/* 520AA */  DCL        VAR(&CANCEL) TYPE(*CHAR) LEN(8)
/* 520 A */  DCL        VAR(&LEN)    TYPE(*DEC)  LEN(15 5) VALUE(1024)
/* 520 A */  DCL        VAR(&PARMS)  TYPE(*CHAR) LEN(80)
/* 520 A */  DCL        VAR(&POVR)   TYPE(*CHAR) LEN(1)
/* 520 A */  DCL        VAR(&PRTCTR) TYPE(*DEC)  LEN(15 5) VALUE(1)
/* 520 A */  DCL        VAR(&ONETIM) TYPE(*CHAR) LEN(1)
/* 640aA */  DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)


             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 START:
/*  Get client code  */

/* 6.40a */  RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/* 6.40A */  IF         COND(&DEV *NE '*JOB      ') THEN(DO)
             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             GOTO       NOOVR
             ENDDO

/* CSPa  */  IF         COND(&CLIENT = 'COASTALSUN' *AND   +
                             &DEV *NE '*JOB      ') THEN(DO)
             OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)
             GOTO       NOOVR
             ENDDO
/*  Get report options. */

/*           CALL      PGM(&OPTPGM) PARM(&CMD &WHSEA &TRN#A &DEV &FORM + */
/*                        &RETURN)                                   */

             CALL      PGM(&OPTPGM) PARM(&POVR &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO

/*  Otherwise, run program. */

 REPORT:

   /* Override printer file. */

   /*        OVRPRTF    FILE(&PRTF) DEV(&DEV) OUTQ(*DEV) +
                          FORMTYPE(&FORM)     */

/*       Process Override Print File Flag     */
/*  If 'Y' Display Screen For 1 Time Override Entry */

 /*520AA*/   IF (&POVR = 'Y') THEN(DO)

 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 1 8)) VALUE('*ADD    ')
 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 9 10)) VALUE(&SBMPGM)
 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 19 10)) VALUE('RU365PR   ')
 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 29 3)) VALUE('000')
 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 32 3)) VALUE(&WHSEA)
 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 35 45)) VALUE(' ')
 /*520AA*/   CHGVAR VAR(%SUBSTRING(&PARMS 68 1)) VALUE('Y')

 /*520AA*/   CALL       PGM(RP152) PARM(&PARMS)
 /*520AA*/   CHGVAR VAR(&CANCEL)  VALUE(%SST(&PARMS 69 8))
 /*520AA*/   IF         COND(&CANCEL *EQ '*CANCEL ') THEN(DO)
 /*520AA*/   CHGVAR VAR(&CANCEL)  VALUE(' ')
 /*520AA*/   GOTO       CMDLBL(START)
 /*520AA*/   ENDDO
 /*520AA*/   ENDDO

/*520AA*/    DOUNTIL    COND(&PRTCTR *EQ 0)
/*520AA*/    CALL       PGM(RPT120) PARM(&PRTF &PRTCTR &CMD2 &ONETIM)
/*520AA*/    IF         COND(&PRTCTR *NE 0) THEN(DO)

 NOOVR:
   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('RUWHSE *EQ ' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RUTRN# +
                          *EQ ' *CAT &TRN#A)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RUSTAT="P"')



   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(RU365A) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (LABEL)) FORMAT(RU365A) +
                          QRYSLT(&QRYSLT) KEYFLD((RUNNER/RUWHSE) +
                          (RUNNER/RUWHDP) (LABEL/LBDISP)) +
                          JFLD((RUNNER/RULBL# LABEL/LBLBL# *EQ)) +
                          JDFTVAL(*YES) SEQONLY(*YES) OPTIMIZE(*FIRSTIO)

      /*     CPYFRMQRYF FROMOPNID(RUNNER) TOFILE(QTEMP/RU365A) +
                          MBROPT(*REPLACE) CRTFILE(*YES)  */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CHGVAR     VAR(&WHSE) VALUE(&WHSEA)
             CHGVAR     VAR(&TRN#) VALUE(&TRN#A)

 /*520AA*/   CHGVAR     VAR(&PRTCTR) VALUE(&PRTCTR + 1)
 /*520AA*/   CALL       PGM(QCMDEXC) PARM(&CMD2 &LEN)
             CALL       PGM(RU365) PARM(&CMD &WHSE &TRN#)
 /*520AA*/   IF         COND(&ONETIM *EQ 'Y') THEN(DO)
 /*520AA*/   CHGVAR     VAR(&PRTCTR) VALUE(0)
 /*520AA*/   ENDDO
 /*520AA*/   CLOF       OPNID(&FILE)
 /*520AA*/   DLTOVR     FILE(&PRTF)
 /*520AA*/   MONMSG     MSGID(CPF9841)
 /*520AA*/   ENDDO
 /*520AA*/   ENDDO

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
 NOMSG:

   /* Clean up before leaving */

   /*        DLTOVR     FILE(&PRTF)   */
             RCLRSC     LVL(*CALLER)

             ENDPGM
