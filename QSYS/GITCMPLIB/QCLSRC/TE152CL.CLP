/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TE152CL   Task Entry                                             */
/*  02 March, 2000                                                   */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Created using TE112CL                                            */
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

 TE152CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(TE152)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (710 A) */

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
