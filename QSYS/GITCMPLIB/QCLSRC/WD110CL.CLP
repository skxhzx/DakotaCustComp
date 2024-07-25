/*-------------------------------------------------------------------*/
/*                                                                   */
/*  WD110CL   Warehouse department maintenance                       */
/*  20 February 1993                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*    09/09/14  MLB  6.50                                            */
/*    - Enh:  Add client custom support.                             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*    09/09/14  MLB  DRY                                             */
/*    - Enh: Only allow authorized users access.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 WD110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Client Custom Identifiers                                     /* (650 A) */
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND ')                     /* (DRY A) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (DRY A) */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(WHDEPT)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(WD110A)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (650 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (DRY A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (DRY A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (DRY A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (DRY A) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get client identifier                                             (650 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (650 A) */

             IF         COND(&CLIENT = DAIRYLAND) THEN(DO)        /* (DRY A) */
               CHGVAR     VAR(&PGMID) VALUE(WD110CL)              /* (DRY A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (DRY A) */
               RTVJOBA    USER(&PUSR)                             /* (DRY A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN) +
                                                                  /* (DRY A) */
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
                        CALL PGM(WD110B) PARM(&UNQKEY &RETURN)
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
