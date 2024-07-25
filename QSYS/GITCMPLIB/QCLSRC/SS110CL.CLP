/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SS110CL   Slot status code table maintenance                     */
/*  05 August, 1994                                                  */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/12/15  MLB  6.50                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    01/12/15  MLB  DRY                                             */
/*      - Add user authorization check. Per Kelly R email.           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SS110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (650 A)  */

             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOTSTAT)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SS110)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

/* Informational message. */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (DRY A) */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (650 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (650 A) */
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

/* Get Client ID */                                               /* (650 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (650 A) */


/*  Check if user is authorized to use this option                /* (DRY A) */

             IF         COND(&CLIENT *EQ &DAIRYLAND +
                                                   )  THEN(DO)    /* (DRY A) */
               CHGVAR     VAR(&PGMID) VALUE(SS110CL)              /* (DRY A) */
               RTVJOBA    USER(&PUSR)                             /* (DRY A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN) +
                                                                  /* (DRY A) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (DRY A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (DRY A) */
                 RETURN                                           /* (DRY A) */
               ENDDO                                              /* (DRY A) */
             ENDDO                                                /* (DRY A) */
                                                                  /* (DRY A) */
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
