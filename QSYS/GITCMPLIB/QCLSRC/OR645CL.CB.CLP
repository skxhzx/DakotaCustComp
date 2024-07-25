/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR645CL   Reprint route - Traffic cop                            */
/*  27 June,1997                                                     */
/*  Hemant Kapadia                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    08/21/03  RH  4.17                                             */
/*      -  FIX:Changed to call OR660CL with DEV & FORM               */
/*                                                                   */
/*    08/05/03  HNK  CBI                                             */
/*      - Change to print OR662 report for Produce items only.       */
/*      - Don't print OR660, if reprinting for zone 'PRD'            */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR645CL:    PGM        PARM(&CMD &RTYPE &WHSE &RTE &RTID &TRUK +
                             &RETURN)
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR645CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(OR645)


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Reprint route option')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&CODE)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&DS)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&LBLS)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRK)        TYPE(*CHAR) LEN(1)
             DCL        VAR(&TRUK)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&TRPL)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&WHSEA)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&ZONE)       TYPE(*CHAR) LEN(6)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/
/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &RTE &LBLS &ZONE +
                          &CODE &TRK &TRPL &DS &RETURN &DEV &FORM)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

/*           IF (&JOBQ = 'Y') THEN(DO)                             */
/*           SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &RETURN  +*/
/*                        &DEV &FORM)) JOB(&SBMPGM)                */
/*           GOTO       CMDLBL(GETOUT)                             */
/*           ENDDO                                                 */

/*  Otherwise, run program. */

 REPORT:

             IF (&DS = 'D') THEN(DO)
             CHGVAR VAR(&RTYPE) VALUE('*DETAIL')
             ENDDO

             IF (&DS = 'S') THEN(DO)
             CHGVAR VAR(&RTYPE) VALUE('*SUMMARY')
             ENDDO

/*  Print labels  */

             IF (&LBLS = 'Y') THEN(DO)
             CHGVAR VAR(&WORKINGMSG) VALUE('Printing labels.')
             MSGBFC     MESSAGE(&WORKINGMSG)
             CALL       PGM(OR640) PARM(&CMD &WHSE &RTID &RTE &TRUK +
                                     &ZONE)
             ENDDO

/*  Print truck summary */

             IF (&TRK = 'Y') THEN(DO)
             CALL       PGM(PS310CL) PARM(&WHSE &RTID &RETURN &DEV +
                                     &FORM)
             ENDDO

/*  Print truck pallet report  */

             IF (&TRPL = 'Y') THEN(DO)
             IF (&ZONE *NE 'PRD') THEN(DO)
             CALL       PGM(OR660CL) PARM(&CMD &RTYPE &WHSE &RTID +
                                     &RETURN &DEV &FORM)           /* 4.17 */
             ENDDO
/* CBI */
             CALL       PGM(OR662CL) PARM(&CMD &RTYPE &WHSE &RTID +
                                     &RETURN)
             ENDDO

             RMVMSG     CLEAR(*ALL)


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
