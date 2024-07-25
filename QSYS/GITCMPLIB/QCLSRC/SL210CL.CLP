/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL210CL   Slot maintenance                                       */
/*  11 August 1994                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL210CL:    PGM

/*-------------------------------------------------------------------*/
/*  7/1/15   RH      7.00a                                           */
/*    - Enh:  Add user authorization check.                          */
/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(SLOT1)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SL210A)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')              /* 7.00a */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10) /* 7.00a */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20) /* 7.00a */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)  /* 7.00a */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10) /* 7.00a */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*  Check if user is authorized to use this option              7.00a */

               CHGVAR     VAR(&PGMID) VALUE(SL210CL)         /* 7.00a */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')         /* 7.00a */
               RTVJOBA    USER(&PUSR)                        /* 7.00a */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)    /* 7.00a */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)   /* 7.00a */
                 RETURN                                      /* 7.00a */
               ENDDO                                         /* 7.00a */

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
                        CALL PGM(SL210B) PARM(&UNQKEY &RETURN)
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
