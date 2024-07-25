/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL620CL   View slot information - UPC mini screen                */
/*  07 February, 1997                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    07/20/09  MLB  5.20                                            */
/*      - Fix: Revised program to call GETUNQMEM before calling      */
/*        so that caller gets unique member for WORKOPT file.        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL620CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SL620)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE)   TYPE(*CHAR) LEN(10) VALUE(WORKOPT)
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*    - Get unique member to use.                                    (520 A) */
                                                                  /* (520 A) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER) /* (520 A) */

/*  On with the show ... */

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)      /* (520 A) */
             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(&FILE)                               /* (520 A) */
             MONMSG     MSGID(CPF9841)                            /* (520 A) */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(&FILE) MBR(&MEMBER)                  /* (520 A) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310) /* Ignore not removed.    (520 A) */

             ENDPGM
