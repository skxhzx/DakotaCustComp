/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ZT110CL   Zone Template Maintenance                              */
/*  27 September, 2007                                               */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ZT110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(TRUCKH)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(ZT110A)

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
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
