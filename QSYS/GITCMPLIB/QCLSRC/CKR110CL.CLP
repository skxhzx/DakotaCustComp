/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CKR110CL   Check Right - Options                                 */
/*  22 June 2009                                                     */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    06/22/09  JCJ  5.20                                            */
/*      - Created. Copied from TAX110CL                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CKR110CL:    PGM


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)    TYPE(*CHAR) LEN(8) VALUE(*CHANGE)
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(CKR110)  PARM(&CMD &RETURN)

DONE:
/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             MONMSG     MSGID(CPF9841)
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)

             ENDPGM
