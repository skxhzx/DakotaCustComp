/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SFC100CL  Route detail by stop                                   */
/*  14 September 2000                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SFC100CL:   PGM        PARM(&WHSEA &RTID &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SFC100CL)


  /* Report program and printer file name. */

             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(SFC100PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Route detail by stop report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing route detail by stop report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

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
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */


   /* Select warehouse  */
             CHGVAR     VAR(&QRYSLT) VALUE('OHWHSE *EQ ' *CAT &WHSEA)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

   /* Select route ID   */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'OHRTE +
                          *EQ ' *CAT &Q *CAT &RTID *CAT &Q)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(SFC100) TOFILE(ORDH) SHARE(*YES)
             OPNQRYF    FILE((ORDH) (ORDD) (RTEHED) (WAREHS)) +
                          FORMAT(SFC100) QRYSLT(&QRYSLT) +
                          KEYFLD((ORDH/OHSTOP) (ORDH/OHCUST) +
                          (ORDH/OHCORD) (ORDD/ODSEQ)) +
                          JFLD((ORDH/OHWHSE +
                          ORDD/ODWHSE) (ORDH/OHORD +
                          ORDD/ODORD) (ORDH/OHWHSE +
                          RTEHED/RHWHSE) (ORDH/OHRTE +
                          RTEHED/RHRTID) (ORDH/OHWHSE +
                          WAREHS/WHCODE)) JDFTVAL(*YES) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(SFC100)

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
