/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL710CL   Export slot quantities                                 */
/*  03 February 2004                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL710CL:    PGM        PARM(&WHSE &WHDP)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SL710CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SL710)

  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SL715)

  /* Main FTP program. */

             DCL        VAR(&FTPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SL716CL)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Export slot quantities')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Exporting slot quantities')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FTP)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&INCL)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RFLAG)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SECTN)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO MAIN)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &WHDP &RETURN &JOBQ +
                          &FTP)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

     /* 411 A  Use FTP option to call appropriate program */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
               IF (&FTP = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&FTPPGM) PARM(&WHSE &WHDP)) +
                          JOB(&FTPPGM)
               ENDDO
               IF (&FTP *NE 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &WHDP)) +
                          JOB(&SBMPGM)
               ENDDO
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

             IF (&FTP = 'Y') THEN(DO)
               CALL PGM(&FTPPGM) PARM(&WHSE &WHDP)
               GOTO GETOUT
             ENDDO
 MAIN:

   /* Export records */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(&MAINPGM) PARM(&WHSE &WHDP)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
