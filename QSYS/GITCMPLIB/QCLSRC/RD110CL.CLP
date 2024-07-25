/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RD110CL   Dispositon Code table maintenance                      */
/*  29 October 2001                                                  */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    04/04/16  MLB  7.00                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    04/04/16  MLB  DRY                                             */
/*      - Add user authorization check. Per Kelly R. email dated     */
/*        04.04.16                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: SGC Foodservice                         */
/*                                                                   */
/*    04/11/20  MLB  SGC                                             */
/*      - Add user authorization check. Per Bill H. phone call       */
/*        04.11.20                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RD110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (700 A) */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */
             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC       ')                     /* (SGC A) */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RDSCODE)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(RD110)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (DRY A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (700 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (700 A) */
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

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (700 A) */

/*  Check if user is authorized to use this option                   (DRY A) */

             IF         COND(&CLIENT *EQ &DAIRYLAND +
                         *OR &CLIENT *EQ &SGC    ) THEN(DO)       /* (SGC M) */
               CHGVAR     VAR(&PGMID) VALUE(RD110CL)              /* (DRY A) */
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

             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
