/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LP130CL   Pallet license information - View RF(Full Screen)      */
/*  08 September, 1999                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*  09/08/99  HNK  4.12                                              */
/*   - Created                                                       */
/*                                                                   */
/*  10/12/00  DAS  4.14                                              */
/*   - Added parameters to LP130.                                    */
/*                                                                   */
/*  10/20/11  MLB  6.40                                              */
/*    - Fix: Added support for WORKOPT file that was missing.        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LP130CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(LP130)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (640 A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.                 (640 A) */
/*    - Get unique member to use.                                    (640 A) */
/*    - Override file to use unique member.                          (640 A) */

             IF (&MEMBER = ' ') DO                                /* (640 A) */
               CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER) +
                                                                  /* (640 A) */
             ENDDO                                                /* (640 A) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (640 A) */

/*  On with the show ... */

         /*  CALL       PGM(&PGM)   414 D */
             CALL       PGM(&PGM) PARM('' 0)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(WORKOPT)                             /* (640 A) */
             CLOF       OPNID(WORKOPT)                            /* (640 A) */
             MONMSG     MSGID(CPF4519 CPF4520)                    /* (640 A) */
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (640 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310 CPF0001)        /* (640 A) */

             ENDPGM
