/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR400CL   RF Order Selection                                     */
/*  29 March, 2006                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    03/29/06  RH   5.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*    11/09/19  MLB  7.30                                            */
/*      - Fix: Revised pgm to add call to GETUNQMEM for WORKOPT.     */
/*        OR400 calls WH900 to verify whse and it opens WORKOPT      */
/*        causing record lock errors. Found at ISP.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR400CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OR400)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (730 A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.                 (730 A) */
/*    - Get unique member to use.                                    (730 A) */
/*    - Override file to use unique member.                          (730 A) */

             IF (&MEMBER = ' ') DO                                /* (730 A) */
                CALL PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)  /* (730 A) */
             ENDDO                                                /* (730 A) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (730 A) */

/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)                             /* (730 A) */
             MONMSG     MSGID(CPF9841)                            /* (730 A) */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (730 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (730 A) */

             ENDPGM
