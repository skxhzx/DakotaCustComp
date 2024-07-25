/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DT110CL   Default Truck table maintenance                        */
/*  03 October 2007                                                  */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  DT110CL - 5.10                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  10/03/07  JCJ  5.10                                              */
/*   - Created                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DT110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(TRUCKDFT)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(DT110)

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

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNDBF     FILE(&FILE) OPTION(*ALL)

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)
             MONMSG     MSGID(CPF3141)

             ENDPGM
