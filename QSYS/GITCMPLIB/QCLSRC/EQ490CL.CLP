/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EQ490CL   RF Route Equipment: Return w/o Route Id                */
/*  13 Feb, 2017                                                     */
/*  Retha Davis                                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    09/04/21  MLB  7.50                                            */
/*      - Fix: Revised pgm to add WORKOPT override with call to      */
/*        GETUNQMEM. Users were getting locks trying to access       */
/*        other green screen options. Found at SFP.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EQ490CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       */

             DCL        VAR(&CHENEY) TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(EQ490)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (750 A) */
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)

/*  Check if user is authorized to use this option                   */

             IF         COND(&CLIENT *EQ &CHENEY +
                                                 ) THEN(DO)
               CHGVAR     VAR(&PGMID) VALUE(EQ490CL)
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')
               RTVJOBA    USER(&PUSR)
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)
                 RETURN
               ENDDO
             ENDDO

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
               CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
             ENDDO

/*  On with the show ... */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (750 A) */
             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)                             /* (750 A) */
             MONMSG     MSGID(CPF9841)                            /* (750 A) */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (750 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (750 A) */

             ENDPGM
