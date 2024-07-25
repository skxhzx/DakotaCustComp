/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADINICL Load Status Summary (initial program).                 */
/*  May 24, 2006                                                     */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  02/17/11  JGD  6.40                                              */
/*   - Enh: Redefine Workopt file override stament                   */
/*          SHARE=(*YES) added.                                      */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    ##/##/##  XXXx-XXX                                             */
/*      Text . . .                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADINICL:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&PUSRI)  TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PRTN)  VALUE('        ')



/*    - Get unique member to use.                                      */

             CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
/*           OVRDBF     FILE(WORKOPT) MBR(&MEMBER)                   */
/* 640 A */  OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)


/* Display load module initial screen 'Route Status Summary            */

             CALL       PGM(LOADR1)


/* Clean up before leaving                                             */

             RCLRSC     LVL(*CALLER)

             DLTOVR     *ALL
             MONMSG     MSGID(CPF9841)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)
/*           RMVM       FILE(WORKOPT) MBR(&MEMBER)               */
/*           MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                        CPF7301 CPF7310)                         */

 /* ENDJOB:     SIGNOFF  */
             ENDPGM
