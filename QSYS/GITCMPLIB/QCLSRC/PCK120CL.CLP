/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PCK120CL  Initialize slots for whse 900 pick test.               */
/*  14 July 1997                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    03/10/00  DAS  4.13                                            */
/*      - Added new fill quantity options.                           */
/*                                                                   */
/*    11/14/19  DAS  7.30                                            */
/*      - Made warehouse an option field                             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PCK120CL:   PGM        PARM(&OPT1 &OPT2 &OPT3 &WHSEA) /* 730aM */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(PCK120CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(PCK120)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Initialize slot for whse 900 pick test')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Initialize slot for whse 900 pick test')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ITEM)       TYPE(*CHAR) LEN(15)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&OPT1)       TYPE(*CHAR) LEN(1) /* 413 A */
             DCL        VAR(&OPT2)       TYPE(*CHAR) LEN(1) /* 413 A */
             DCL        VAR(&OPT3)       TYPE(*CHAR) LEN(1) /* 413 A */
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTNMSG)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3) /* 730aA */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO SKIP1)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&OPT1 &OPT2 &OPT3 &WHSEA +
                          &RETURN) /* 730aM */

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
                SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&OPT1 &OPT2 &OPT3 +
                             &WHSEA)) JOB(&SBMPGM) /* 730aM */
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 SKIP1:

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CALL       PGM(PCK125) PARM(&TYPE &OPT1 &OPT2 &OPT3 &WHSEA) +
                          /* 730aM */

             CHGVAR     VAR(&WHSE) VALUE(&WHSEA) /* 730aM */
             CHGVAR     VAR(&ITEM) VALUE('*ALL')
             CALL       PGM(UT812) PARM(&WHSE &ITEM &TYPE &SBMPGM +
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
