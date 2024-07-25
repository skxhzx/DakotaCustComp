/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR299CL   RF SOS Utility                                         */
/*  21 December 2005                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    12/21/05  RH   5.00                                            */
/*      - Created using OR200                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR299CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OR299)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

 /* Variables for sending messages to calling screen */  /* 416 A */

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

/*  Check user in */                                       /* 416aA */

             RMVMSG     CLEAR(*ALL)                        /* 416aA */
             CHKUSR     TYPE(*IN)                          /* 416aA */
             MONMSG     MSGID(CPF9898) EXEC(GOTO GETOUT)   /* 416aA */


/*  On with the show ... */                                /* 416aA */

             CALL       PGM(&PGM)

             GOTO       CMDLBL(NOMSG)

/*  Send message on to user */

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
             RCLRSC     LVL(*CALLER)
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

/*  Check user out */                              /* 416aA */
             CHKUSR     TYPE(*OUT)                 /* 416aA */


             ENDPGM
