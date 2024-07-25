/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RU310CL   RF - Runner Clear Flags                                */
/*  26 May 2004                                                      */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/26/04  MLB  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    11/19/08  MLB  5.20                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    09/06/06  CBI-JGD                                              */
/*      Added new function to restrict unauthorized users            */
/*      from accessing 'Clear Flags Entries', option # 4             */
/*      in menu 'pirflg'.                                            */
/*                                                                   */
/*    09/26/06  CBI-JGD                                              */
/*      Added new parameter to 'CHKCREW' call to identify,           */
/*      for access restriction purpose, what employee/               */
/*      crew code is asking for access.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RU310CL:    PGM

  /* Client ID's.    */                                           /* (520 A) */

             DCL        VAR(&CBI)     TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI A) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(RU310)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

  /* Informational message. */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
             VALUE('   You are not authorized to use this option.') /* CBI A */

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)         /* CBI A */
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)        /* CBI A */
             DCL        VAR(&PROC)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (520 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (520 A) */

             IF         COND(&CLIENT = &CBI) THEN(DO)             /* (CBI A) */
             CHGVAR     VAR(&PROC)  VALUE(RU310CL)

             RTVJOBA    USER(&PUSR)                                 /* CBI A */

/*  Check if user is authorized to use this option */               /* CBI A */

             CALL       PGM(CHKCREW) PARM(&PUSR &PRTN &PROC)        /* CBI A */

             IF         COND(&PRTN *EQ '*NO')  THEN(DO)             /* CBI A */

                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)                              /* CBI A */

             RETURN
             ENDDO
             ENDDO                                                /* (CBI A) */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
             ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  Check user in */

             RMVMSG     CLEAR(*ALL)
             CHKUSR     TYPE(*IN)
             MONMSG     MSGID(CPF9898) EXEC(GOTO GETOUT)

/*  On with the show ... */

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
 NOMSG:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)

             CHKUSR     TYPE(*OUT)

             ENDPGM
