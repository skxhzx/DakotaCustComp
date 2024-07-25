/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ZBR120CL  Create zebra belt printer outq and printer device      */
/*  12 October 2005                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    - 10/12/05  MLB  5.00                                          */
/*        - Added DESTOPT keyword with XAIX, XAUTOQ to the CRTOUTQ   */
/*          keyword. XAIX adds multi-copy spoolfile support and      */
/*          XAUTOQ adds re-queue, retry support to remote outqs.     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ZBR120CL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ZBR120)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create zebra belt printer outq and +
                          printer device')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating zebra belt printer outq and +
                          printer device')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DESC)       TYPE(*CHAR) LEN(30)
             DCL        VAR(&IPADR)      TYPE(*CHAR) LEN(15)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&NAME)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&RMTQ)       TYPE(*CHAR) LEN(30)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get options. */

             CALL       PGM(&OPTPGM) PARM(&NAME &DESC &RMTQ &IPADR +
                          &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/*  Otherwise, run program. */

 SKIP1:

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

             CRTOUTQ    OUTQ(QUSRSYS/&NAME) RMTSYS(*INTNETADR) +
                          RMTPRTQ(&RMTQ) AUTOSTRWTR(1) CNNTYPE(*IP) +
                          DESTTYPE(*OTHER) MFRTYPMDL(*WSCST) +
                          WSCST(QWPDEFAULT) INTNETADR(&IPADR) +
                          DESTOPT('XAIX XAUTOQ') SEPPAGE(*NO) +
                          TEXT(&DESC)

             CRTDEVPRT  DEVD(&NAME) DEVCLS(*VRT) TYPE(3812) MODEL(1) +
                          ONLINE(*NO) FONT(011) TEXT(&DESC)

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
