/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO110CL   PO header file maintenance                             */
/*  08 October, 1996                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    06/07/18  MLB  7.20                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Greco & Sons                            */
/*                                                                   */
/*    06/07/18  MLB  GRC                                             */
/*      - Add user authorization check. Per Roxanne H. email dated   */
/*        06.06.18.                                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (720 A) */

             DCL        VAR(&GRECO) TYPE(*CHAR) LEN(10) +
                          VALUE('GRECO     ')                     /* (GRC A) */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(POHDR)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(PO110A)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (GRC A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (720 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (720 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (GRC A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (GRC A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (GRC A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (GRC A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (720 A) */

/*  Check if user is authorized to use this option                   (GRC A) */

             IF         COND(&CLIENT *EQ &GRECO +
                                                  ) THEN(DO)      /* (GRC A) */
               CHGVAR     VAR(&PGMID) VALUE(PO110CL)              /* (GRC A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (GRC A) */
               RTVJOBA    USER(&PUSR)                             /* (GRC A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (GRC A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (GRC A) */
                 RETURN                                           /* (GRC A) */
               ENDDO                                              /* (GRC A) */
             ENDDO                                                /* (GRC A) */

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNDBF     FILE(&FILE) OPTION(*ALL)

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(PO110B) PARM(&UNQKEY &RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)

DONE:

/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
