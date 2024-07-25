/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL110CL   Slot maintenance                                       */
/*  08 August 1994                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  5/9/13   GJA     6.50a                                           */
/*    - Enh:  Add user authorization check.                          */
/*-------------------------------------------------------------------*/

 SL110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT1)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SL110A)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')              /* 6.50a */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10) /* 6.50a */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20) /* 6.50a */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)  /* 6.50a */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10) /* 6.50a */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*  Check if user is authorized to use this option              6.50a */

               CHGVAR     VAR(&PGMID) VALUE(SL110CL)         /* 6.50a */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')         /* 6.50a */
               RTVJOBA    USER(&PUSR)                        /* 6.50a */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)    /* 6.50a */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)   /* 6.50a */
                 RETURN                                      /* 6.50a */
               ENDDO                                         /* 6.50a */

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
                        CALL PGM(SL110B) PARM(&UNQKEY &RETURN)
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
