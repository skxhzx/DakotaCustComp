/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RC300CL   RF Staged Put-Away                                     */
/*  08 June, 2000                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Notes:                                                           */
/*      - Uses logic to get uniuqe member for WORKOPT.               */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/22/00  DAS  4.14                                            */
/*      - Removed logic for WORKOPT.                                 */
/*      - Added logic to get unique members for WRKSTGP,             */
/*        WRKSTGP1 and WRKSTGP2.                                     */
/*                                                                   */
/*    09/27/00  DAS  4.14a                                           */
/*      - Added check in/out logic.                                  */
/*      - Added messaging logic.                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RC300CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(RC300)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

 /* Variables for sending messages to calling screen */  /* 414aA */

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

 /* 414D     IF (&MEMBER = ' ') DO            */
 /* 414D        CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER) */
 /* 414D        ENDDO                         */

 /* 414D     OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)  */

 /* 414M */  CALL       PGM(GETUNQMEM) PARM(*REUSE WRKSTGP &MEMBER)
 /* 414M */  CALL       PGM(GETWRKMEML) PARM(*REUSE WRKSTGP1 WRKSTGP +
 /* 414M */               &MEMBER)
 /* 414M */  CALL       PGM(GETWRKMEML) PARM(*REUSE WRKSTGP2 WRKSTGP +
 /* 414M */               &MEMBER)

 /* 414M */  OVRDBF     FILE(WRKSTGP) MBR(&MEMBER) SHARE(*YES)
 /* 414M */  OVRDBF     FILE(WRKSTGP1) MBR(&MEMBER) SHARE(*YES)
 /* 414M */  OVRDBF     FILE(WRKSTGP2) MBR(&MEMBER) SHARE(*YES)


/*  Check user in */                                       /* 414 A */

             RMVMSG     CLEAR(*ALL)                        /* 414 A */
             CHKUSR     TYPE(*IN)                          /* 414 A */
             MONMSG     MSGID(CPF9898) EXEC(GOTO GETOUT)   /* 414 A */

/*  On with the show ... */

             CALL       PGM(&PGM)

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

             DLTOVR     FILE(WRKSTGP1)
             DLTOVR     FILE(WRKSTGP2)
             DLTOVR     FILE(WRKSTGP )
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WRKSTGP) MBR(&MEMBER)

             CHKUSR     TYPE(*OUT)                 /* 414 A */

             ENDPGM
