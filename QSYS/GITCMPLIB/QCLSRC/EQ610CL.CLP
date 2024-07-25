/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EQ610CL   Equipment - Yard Status                                */
/*  27 January 2004                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EQ610CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(EQUIP  )
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(EQ610)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

/*           OVRDBF     FILE(&FILE) SHARE(*YES)       */
/*           OPNDBF     FILE(&FILE) OPTION(*ALL)      */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             MONMSG     MSGID(CPF4519 CPF4520)
             DLTOVR     FILE(&FILE)
             MONMSG     MSGID(CPF9841)
             DLTOVR     FILE(WORKOPT)
             MONMSG     MSGID(CPF9841)
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)

             ENDPGM
