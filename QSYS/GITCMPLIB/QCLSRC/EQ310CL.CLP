/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EQ310CL   Equipment Excepiton report                             */
/*  25 February 2002                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EQ310CL:    PGM        PARM(&WHSE &RETURN &JOBQ &DEV &FORM &FMDT +
                            &TODT &VP &EQID &SORT)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EQ310CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(EQ312)

  /* Report program and printer file name. */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LABEL)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Equipment Exceptions')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Equipment Exception report'  )

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FMDT)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER1)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&EQID)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  4.15 Don't get options, if being called and sent parms. */
             IF (&JOBQ = 'Y') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RETURN &JOBQ &DEV +
                          &FORM &FMDT &TODT &VP &EQID &SORT)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN +
                          &JOBQ &DEV &FORM &FMDT &TODT &VP &EQID +
                          &SORT)) +
                          JOB(AAEQ310CL)
         /*               JOB(&SBMPGM)          */
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:  /* ( Chg 2.09 ) */


/*  IF View or Print        */
             IF (&VP = 'V') THEN(DO)
             CHGVAR     VAR(&CMD) VALUE('*DISPLAY')
             ENDDO
             IF (&VP = 'P') THEN(DO)
             CHGVAR     VAR(&CMD) VALUE('*PRINT  ')
             ENDDO

             CALL       PGM(EQ310) PARM(&CMD &WHSE &EQID &FMDT +
                        &TODT &SORT &DEV &FORM)




             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)



 GETOUT:
    /*       DLTOVR     FILE(&FILE)    */
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
