/*-------------------------------------------------------------------*/
/*                                                                   */
/*  BFCBACKUP   BFC Daily Backup                                     */
/*  11 November 2004                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/11/04  DAS  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC                                     */
/*                                                                   */
/*    04/24/07  MLB  TPC                                             */
/*      - Revised program to send sign off msg 10 minutes before     */
/*        backup begins.                                             */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Notes                                                            */
/*                                                                   */
/*   - The library containing data area PIRCLIENT must be on the     */
/*     library list. This is usually library PIR.                    */
/*                                                                   */
/*   - If the voice selection severs must be ended, then library     */
/*     SOCKETWS must be on the library list.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 BFCBACKUP:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&PGM) TYPE(*CHAR) LEN(10) +
                          VALUE(BFCBACKUP)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get client code  */

             RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)

/*  Set message queue to use  */

             CHGVAR     VAR(&MSGQ) VALUE('QSYSOPR')

             IF         COND(&CLIENT = 'DAVE') THEN(DO)
             CHGVAR     VAR(&MSGQ) VALUE('DAVE')
             ENDDO

             IF         COND(&CLIENT = 'TPC') THEN(DO)
               SNDBRKMSG  MSG('The system will go down for daily +
                            backup in 10 minutes.  Please sign off +
                            now.') TOMSGQ(*ALLWS)
               DLYJOB     DLY(600) /* Delay backup 10 minutes. */
             ENDDO

/*  Backup libraries */

             CHGVAR     VAR(&MSGDTA) VALUE(&PGM *TCAT ': Saving +
                          libraries')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) TOMSGQ(&MSGQ) MSGTYPE(*INFO)

             CALL       PGM(BFCSAVLIB) PARM(&CLIENT &MSGQ &RETURN)
             MONMSG     MSGID(CPF0000) EXEC(CHGVAR VAR(&RETURN) +
                          VALUE('*ERROR'))

/*  Backup finished successfully  */

             IF COND(&RETURN *NE '*ERROR') THEN(DO)

             CHGVAR     VAR(&MSGDTA) VALUE(&PGM *TCAT ': Finished +
                          successfully')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) TOMSGQ(&MSGQ) MSGTYPE(*INFO)

             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOUSR(&MSGQ) MSGTYPE(*COMP)

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

/*  Send '*Escape' message to caller */

             IF COND(&RETURN = '*ERROR') THEN(DO)

             CHGVAR     VAR(&MSGDTA) VALUE(&PGM *TCAT ': Error +
                          occured, see previous mesages:')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) TOMSGQ(&MSGQ) +
                          MSGTYPE(*ESCAPE)

             CHGVAR     VAR(&MSGDTA) VALUE(&PGM *TCAT ': Error +
                          occured')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MSGDTA) MSGTYPE(*ESCAPE)

             ENDDO

             ENDPGM
