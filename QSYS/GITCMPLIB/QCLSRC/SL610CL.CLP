/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL610CL   View slot information - UPC full screen                */
/*  07 February, 1997                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    03/30/17  MLB  7.10                                            */
/*      - Enh: Revised pgm to add support for overriding to unique   */
/*        WORKOPT mbr. Was locking users out of other interactive    */
/*        menu options.                                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL610CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SL610)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (710 A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.                 (710 A) */
/*    - Get unique member to use.                                    (710 A) */
/*    - Override file to use unique member.                          (710 A) */

             IF (&MEMBER = ' ') DO                                /* (710 A) */
               CALL PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)   /* (710 A) */
             ENDDO                                                /* (710 A) */

/*  On with the show ... */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (710 A) */
             CALL       PGM(&PGM)

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(WORKOPT)                             /* (710 A) */
             MONMSG     MSGID(CPF9841)                            /* (710 A) */
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (710 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (710 A) */

             ENDPGM
