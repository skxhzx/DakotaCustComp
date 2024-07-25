/*-------------------------------------------------------------------*/
/*  CLEANMISCF This program cleans miscellaneous files.              */
/*             It is executed every day at 5:30 a.m. thru            */
/*             IBM jobs cheduler under the job name 'CLEANMISC'.     */
/*                                                                   */
/*  September 16, 2008                                               */
/*  Jose G. Duque                                                    */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CLEANMISCF: PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                        VALUE('Remove Miscellaneous Files old rec +
                               ords')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                        VALUE('Removing old Miscellaneous records')


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MONTHS)     TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


             MSGBFC     MESSAGE(&WORKINGMSG)

             /*---------------------------------------------*/
             /* Cleans Item Locs Change Log File (Locslog). */
             /*---------------------------------------------*/
             CHGVAR VAR(&MONTHS) VALUE(1)
             CALL       PGM(CLNSLOTNG) PARM(&MONTHS) /* One Month Kept */
             RGZPFM     FILE(LOCSLOG)


             /*--------------------------------------------------*/
             /* Cleans PO/Lumping Srvc check Log File (Lumplog). */
             /*--------------------------------------------------*/
             CHGVAR VAR(&MONTHS) VALUE(6)
             CALL       PGM(CLNLUMPLG) PARM(&MONTHS) /* Six Months Kept */
             RGZPFM     FILE(LUMPLOG)


             /*--------------------------------------------------*/
             /* Cleans PO/Lumping Srvc "Driver Lump" check Log   */
             /* File (Lumplogx).                                 */
             /*--------------------------------------------------*/
             CHGVAR VAR(&MONTHS) VALUE(6)
             CALL       PGM(CLNLUMPGX) PARM(&MONTHS) /* Six Months Kept */
             RGZPFM     FILE(LUMPLOGX)


             /*--------------------------------------------------*/
             /* Cleans PO/Lumping Srvc "Driver Lump" info only   */
             /* File (Lumperx).                                  */
             /*--------------------------------------------------*/
             CHGVAR VAR(&MONTHS) VALUE(12)
             CALL       PGM(CLNLUMPX) PARM(&MONTHS) /* Twelve Months Kept */
             RGZPFM     FILE(LUMPERX)


             /*-----------------------------------------------*/
             /* Cleans Check Digit Change Log File (Chkdlog). */
             /*-----------------------------------------------*/
             CHGVAR VAR(&MONTHS) VALUE(12)
             CALL       PGM(CLNSLOTDG) PARM(&MONTHS) /* Twelve Months Kept */
             RGZPFM     FILE(CHKDLOG)


             /*--------------------------------------------------*/
             /* Clears files "Fordh" and "Fordd", these files    */
             /* are used by Security Dept. thru Menu: GMR/Opt 5  */
             /* this option creates a "Salt Label" info report.  */
             /* NOTE: The "Salt Label" process is done in test.  */
             /*--------------------------------------------------*/
             CLRPFM     FILE(PIRTESTF/FORDH)
             CLRPFM     FILE(PIRTESTF/FORDD)


/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
