/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LT105CL   RF Let-Down - Automated                                */
/*  16 November 1999                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    09/20/00  DAS  4.14                                            */
/*      - Added check in/out logic.                                  */
/*      - Added messaging logic.                                     */
/*                                                                   */
/*    05/03/06  MLB  5.00                                            */
/*      - Enh: Added two new parms on call to LT105 to support       */
/*        putaway with interleaving replenishments.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LT105CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(LT105)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

 /* Variables for sending messages to calling screen */  /* 414 A */

             DCL        VAR(&LPARM) TYPE(*CHAR) LEN(136) +
                          VALUE('*STDRPL')               /* 500 A */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
             ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  Check user in */                                       /* 414 A */

             RMVMSG     CLEAR(*ALL)                        /* 414 A */
             CHKUSR     TYPE(*IN)                          /* 414 A */
             MONMSG     MSGID(CPF9898) EXEC(GOTO GETOUT)   /* 414 A */

/*  On with the show ... */

/*           CALL       PGM(&PGM)                             500 D */
             CALL       PGM(&PGM) PARM(&LPARM)             /* 500 M */

             GOTO       CMDLBL(NOMSG)          /* 414 A */

/*  Send message on to user */                 /* 414 A */

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

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             CHKUSR     TYPE(*OUT)                 /* 414 A */

             ENDPGM
