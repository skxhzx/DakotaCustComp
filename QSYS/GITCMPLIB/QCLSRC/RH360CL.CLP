/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH360CL   Route transaction close exceptions report              */
/*  05 June, 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   06/05/01  DAS  4.15                                             */
/*     - Created                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH360CL:    PGM        PARM(&WHSEA &RTID)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RH360CL)


  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ITEMADJ1)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) VALUE(RH360PR)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Route Transaction Close Exceptions +
                          Report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing route transaction close +
                          exceptions report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMORTID)   TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&Q)          TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */


   /* Select warehouse  */
             CHGVAR     VAR(&QRYSLT) VALUE('IAWHSE *EQ ' *CAT &WHSEA)


   /* Select route ID   */
             CHGVAR     VAR(&MEMORTID) VALUE('R:' *CAT &RTID)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'IARTID +
                          *EQ ' *CAT &Q *CAT &MEMORTID *CAT &Q)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(RH360) PARM(&WHSEA &RTID)

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
