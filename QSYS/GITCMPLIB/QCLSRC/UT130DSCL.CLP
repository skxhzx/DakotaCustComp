/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT130DSCL  Zero quantities in all Fixed pick slots.              */
/*  11 December 2001                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   12/11/01  DAS  4.16                                             */
/*     - Created                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT130DSCL:  PGM        PARM(&WHSE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Run the program. */

             CALL       PGM(UT130DS) PARM(&WHSE &RETURN)

             IF         COND(&RETURN *EQ '*JOBQ') THEN(DO)
               SNDUSRMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS can only be run from the +
                          job queue') MSGTYPE(*INFO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS can only be run from the +
                          job queue') MSGTYPE(*ESCAPE)
             ENDDO

             IF         COND(&RETURN *EQ '*LOCATOR') THEN(DO)
               SNDUSRMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS can only be run on a +
                          Locator system') MSGTYPE(*INFO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS can only be run on a +
                          Locator system') MSGTYPE(*ESCAPE)
             ENDDO

             IF         COND(&RETURN *EQ '*NORECS') THEN(DO)
               SNDUSRMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS: No records found +
                          matching criteria') MSGTYPE(*INFO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS: No records found +
                          matching criteria') MSGTYPE(*ESCAPE)
             ENDDO

             IF         COND(&RETURN *EQ '*OK') THEN(DO)
               SNDUSRMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS completed successfully') +
                          MSGTYPE(*INFO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('UT130DS completed successfully') +
                          MSGTYPE(*COMP)
             ENDDO

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
