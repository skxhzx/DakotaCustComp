/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PCK830CL  Create ITEMSLS and ITEMAVG test records.               */
/*  21 June 2001                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    06/21/01  DAS  4.15                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PCK830CL:   PGM        PARM(&PTYPE &PMIN &PMAX &PWKS)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PCK830CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PCK830)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create ITEMSLS and ITEMAVG test +
                          records')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating ITEMSLS and ITEMAVG test +
                          records')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&PMAX)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&PMIN)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&PTYPE)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PWKS)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNMSG)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO SKIP1)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&PTYPE &PMIN &PMAX &PWKS +
                          &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&PTYPE &PMIN +
                          &PMAX &PWKS)) JOB(&SBMPGM)
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 SKIP1:

             RMVMSG     CLEAR(*ALL)

             MSGBFC     MESSAGE('Removing ''900'' records from +
                          ITEMSLS and ITEMAVG')
             CALL       PGM(PCK835D)

             MSGBFC     MESSAGE(&WORKINGMSG)
             CALL       PGM(PCK835) PARM(&TYPE &PTYPE &PMIN &PMAX +
                          &PWKS)

             MSGBFC     MESSAGE('Calculating averages')
             CALL       PGM(IT502) PARM('*FORCE' 'PCK830CL' '900' +
                          &RETURN &RTNMSG)

/*  Receive any messages and pass them on  */

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

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
