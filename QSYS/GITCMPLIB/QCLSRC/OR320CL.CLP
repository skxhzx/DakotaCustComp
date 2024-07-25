/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR320CL   Print SOS Slot Tranfer Quantity                        */
/*  01 June 2011                                                     */
/*  Roxanne Harrison                                                 */
/*  Note: This program is called when SOS route is exported, option  */
/*        program is disabled.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    06/01/11  RH   6.40                                            */
/*      - Created using RU360CL                                      */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR320CL:    PGM        PARM(&CMD &WHSEA &RTID &DEV &FORM &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR320CL)

  /* Option program. */

  /*         DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RU360)                       */
             DCL        VAR(&PRTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PR100)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR325PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Print SOS Slot Tfr Qty')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing SOS Slot Tfr Qty')

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
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 START:

/*  Get report options. */

/*           CALL      PGM(&OPTPGM) PARM(&CMD &WHSEA &RTID &DEV &FORM + */
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
                          FORMTYPE(&FORM)     */

/*       Process Override Print File Flag     */
/*  If 'Y' Display Screen For 1 Time Override Entry */



   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBRTE +
                          *EQ ' *CAT &QUOTE *CAT &RTID *CAT &QUOTE)




   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR325A) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(OR325A) QRYSLT(&QRYSLT) +
                          KEYFLD((LBWHSE) (LBRTE) (LBORD) (LBSEQ)) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)


             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CHGVAR     VAR(&WHSE) VALUE(&WHSEA)

             CALL       PGM(OR325) PARM(&CMD &WHSE &RTID)

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
