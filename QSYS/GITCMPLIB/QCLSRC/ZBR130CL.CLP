/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ZBR130CL  Create zebra output queue and printer device           */
/*  22 February 2006                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    - 02/22/06  DAS  5.00                                          */
/*        - Created                                                  */
/*                                                                   */
/*    - 08/12/15  MLB  7.00                                          */
/*        - Enh: Revised pgm to set SEPPAGE to *NO from *YES.        */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/* Notes:                                                            */
/*                                                                   */
/*  This differs from ZBR110CL by using WSCSTCONT132 for the printer */
/*  model along with QWPDEFAULT.                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ZBR130CL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(ZBR110)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Create zebra output queue and +
                          printer device')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Creating zebra output queue and +
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
                          DESTTYPE(*OTHER) MFRTYPMDL(*WSCSTCONT132) +
                          WSCST(*LIBL/QWPDEFAULT) INTNETADR(&IPADR) +
                          DESTOPT('XAIX XAUTOQ') TEXT(&DESC) +
                          seppage(*NO)                            /* (700 M) */

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
