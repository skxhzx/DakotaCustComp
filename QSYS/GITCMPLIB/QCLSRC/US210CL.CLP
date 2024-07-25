/*-------------------------------------------------------------------*/
/*                                                                   */
/*  US210CL   PROGRAM OPTION USER MAINTENANCE                        */
/*  03 DECEMBER 2007                                                 */
/*  CHUCK MANNY                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/20/17  JGD  7.00                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    01/23/17  CBI-JGD                                              */
/*      Add new function to restrict access to this app.             */
/*      to unauthorized users.                                       */
/*      Acces path: PIRMAIN opt # 89, CBIMAIN Opt# 7, CBIMNUM OPT# 1 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    09/18/18  MLB  DRY                                             */
/*      - Add to authorization check.                                */
/*        Per Kelly R email dated 09.18.2018.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 US210CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (720 A)  */

             DCL        VAR(&CHENEY)  TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI A) */
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(PGMUSRID)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(US210)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/* Informational message. */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (CBI A) */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (720 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (720 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (CBI A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (CBI A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (CBI A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (CBI A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (720 A) */

/*  Check if user is authorized to use this option                   (CBI A) */

             IF         COND(&CLIENT *EQ &CHENEY +
                       *OR &CLIENT *EQ &DAIRYLAND)  THEN(DO)      /* (DRY M) */
               CHGVAR     VAR(&PGMID) VALUE(US210CL)              /* (CBI A) */
               RTVJOBA    USER(&PUSR)                             /* (CBI A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN) +
                                                                  /* (CBI A) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (CBI A) */
                          SNDPGMMSG  MSG(&NOAUTHRZE)   +
                          MSGTYPE(*INFO)                          /* (CBI A) */
               RETURN                                             /* (CBI A) */
               ENDDO                                              /* (CBI A) */
             ENDDO                                                /* (CBI A) */
/*-------------------------------------------------------------------*/

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

             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
