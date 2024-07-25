/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR665CL   Catch weight summary report.                           */
/*  14 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR665CL:    PGM        PARM(&CMD &RTYPE &WHSEA &RTID &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR665CL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL7)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(OR665PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Catch weight Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing catch weight report'         )

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&BATCH)      TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&BATCHA)     TYPE(*CHAR) LEN(7)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&Q)          TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */


   /* Select warehouse  */
             CHGVAR     VAR(&QRYSLT) VALUE('LBWHSE *EQ ' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select route ID   */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LBRTE +
                          *EQ ' *CAT &Q *CAT &RTID *CAT &Q)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select type  */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '((LBTYPE +
                          *EQ ' *CAT &Q *CAT 'O' *CAT &Q *CAT ')'  +
                          *BCAT '*OR' *BCAT '(LBTYPE *EQ ' *CAT &Q +
                          *CAT 'B' *CAT &Q *CAT '))')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select catch weight items only */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'ITCWGT +
                          *EQ ' *CAT &Q *CAT 'Y' *CAT &Q)


   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(OR665) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(OR665) QRYSLT(&QRYSLT) +
                          KEYFLD((LBWHSE) (LBTRN#))

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(OR665) PARM(&CMD &RTYPE)

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

             RCLRSC     LVL(*CALLER)

             ENDPGM
