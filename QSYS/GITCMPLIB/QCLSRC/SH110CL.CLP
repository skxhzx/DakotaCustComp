/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SH110CL   Shift table maintenance                                */
/*  30 October, 1995                                                 */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    03/28/12  MLB  6.40                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    03/28/12  MLB  DRY                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Coastal                                 */
/*                                                                   */
/*    10/03/16  GJA  CSPa                                            */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line                               */
/*                                                                   */
/*    05/26/17  MLB  CLD                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Saval Foods                             */
/*                                                                   */
/*    11/21/17  MLB  SVL                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cash Wa                                 */
/*                                                                   */
/*    12/04/20  MLB  CWD  ZD# 3098                                   */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Vitco Foods                             */
/*                                                                   */
/*    02/23/21  JCJ  VFI                                             */
/*      - Add user authorization check.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SH110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (640 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */

/*CSPaA*/    DCL        VAR(&COASTAL) TYPE(*CHAR) LEN(10) +
                          VALUE('COASTALSUN')

             DCL        VAR(&SAVALFOODS) TYPE(*CHAR) LEN(10) +
                          VALUE('SAVALFOODS')                     /* (SVL A) */
             DCL        VAR(&CITYLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('CITYLINE ')                      /* (CLD A) */
             DCL        VAR(&CASHWA  ) TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA   ')                      /* (CWD A) */
             DCL        VAR(&VITCO) TYPE(*CHAR) LEN(10) +
                          VALUE('VITCOFOOD')                      /* (VFI A) */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SHIFT)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SH110A)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (DRY A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (640 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (640 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (DRY A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (DRY A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (DRY A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (DRY A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640 A) */

/*  Check if user is authorized to use this option                   (DRY A) */

             IF         COND(&CLIENT *EQ &DAIRYLAND +
                         *OR &CLIENT *EQ &COASTAL +
                         *or &CLIENT *EQ &SAVALFOODS +
                         *or &CLIENT *EQ &CASHWA +
                         *or &CLIENT *EQ &VITCO +
                         *OR &CLIENT *EQ &CITYLINE) THEN(DO)      /* (CWD M) */
               CHGVAR     VAR(&PGMID) VALUE(SH110CL)              /* (DRY A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (DRY A) */
               RTVJOBA    USER(&PUSR)                             /* (DRY A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (DRY A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (DRY A) */
                 RETURN                                           /* (DRY A) */
               ENDDO                                              /* (DRY A) */
             ENDDO                                                /* (DRY A) */

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
                        CALL PGM(SH110B) PARM(&UNQKEY &RETURN)
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
