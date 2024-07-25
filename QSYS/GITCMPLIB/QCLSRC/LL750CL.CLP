/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LL750CL   Cleanup LICLOG/LICINFO Files                           */
/*  20 January, 2012                                                 */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    01/20/12  LMC  6.40                                            */
/*      - Created                                                    */
/*      - This job should not be run interactive - if it is          */
/*        called interactively without a default warehouse.          */
/*        &whse will be initialized to 900 as a precaution.          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LL750CL:    PGM        PARM(&CMD &WHSE &DATE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LL750CL)


  /* Main program. */

             DCL        VAR(&MAINPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(LL755)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Cleanup LICLOG/LICINFO files')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Cleaning LICLOG/LICINFO files')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CKRUN) TYPE(*CHAR) LEN(5) VALUE('10000')
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RUNALL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)

/* Don't get options if being run in *BATCH mode. */

             IF (&CMD = '*BATCH') THEN(GOTO MAIN)


/* if no warehouse load 900 as a default */
             IF         COND(&WHSE = ' ') THEN(CHGVAR VAR(&WHSE) +
                          VALUE('900'))
/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ *EQ 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM('*BATCH' &WHSE +
                          &DATE)) JOB(&SBMPGM)
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 MAIN:



             CALL       PGM(&MAINPGM) PARM(&WHSE &CKRUN &RUNALL)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
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
