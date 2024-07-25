/*-------------------------------------------------------------------*/
/*   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RU350CL   Print Runner Pick Labels on Belt Printer               */
/*  01 December 2005                                                 */
/*  Max Blacknik                                                     */
/*  Note: This program is called from RU120 so the option program    */
/*        is disabled.                                               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    12/01/05  MLB  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    12/27/05  JCJ  5.00A                                           */
/*      - Enh: added parms &dev & &form to call of RU355             */
/*      - Enh: Commented out OVRPRTF command                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RU350CL:    PGM        PARM(&CMD &WHSEA &TRN#A &DEV &FORM &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU350CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU350)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RUNNER)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(NONE)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Print Runner Pick Labels')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Runner Pick Labels')

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

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  Get report options. */

/*           CALL      PGM(&OPTPGM) PARM(&CMD &WHSEA &TRN#A &DEV &FORM + */
/*                        &RETURN)                                   */

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
                          FORMTYPE(&FORM)          500a   */

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('RUWHSE *EQ ' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RUTRN# +
                          *EQ ' *CAT &TRN#A)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'RUSTAT="P"')



   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(RU355A) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE) (LABEL)) FORMAT(RU355A) +
                          QRYSLT(&QRYSLT) KEYFLD((RUNNER/RUWHSE) +
                          (RUNNER/RUWHDP) (LABEL/LBDISP)) +
                          JFLD((RUNNER/RULBL# LABEL/LBLBL# *EQ)) +
                          JDFTVAL(*YES) SEQONLY(*YES) OPTIMIZE(*FIRSTIO)

      /*     CPYFRMQRYF FROMOPNID(RUNNER) TOFILE(QTEMP/RU355A) +
                          MBROPT(*REPLACE) CRTFILE(*YES)  */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CHGVAR     VAR(&WHSE) VALUE(&WHSEA)
             CHGVAR     VAR(&TRN#) VALUE(&TRN#A)

 /* 500a     CALL       PGM(RU355) PARM(&CMD &WHSE &TRN# &RETURN) */
             CALL       PGM(RU355) PARM(&CMD &WHSE &TRN# &DEV &FORM +
                          &RETURN) /* 500a  */

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
