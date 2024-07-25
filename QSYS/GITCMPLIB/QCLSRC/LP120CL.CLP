/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LP120CL   Pallet license information - View RF                   */
/*  12 February, 1997                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    04/13/10  MLB  5.30                                            */
/*      - Fix: Revised program to call GETUNQMEM before calling      */
/*        so that caller gets unique member for WORKOPT file.        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LP120CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(LP120)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(WORKOPT) +
                                                                  /* (530 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (530 A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*    - Get unique member to use.                                    (530 A) */
                                                                  /* (530 A) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER) /* (530 A) */

/*  On with the show ... */

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)      /* (530 A) */
             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(&FILE)                               /* (530 A) */
             MONMSG     MSGID(CPF9841)                            /* (530 A) */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(&FILE) MBR(&MEMBER)                  /* (530 A) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310) /* Ignore not removed.    (530 A) */

             ENDPGM
