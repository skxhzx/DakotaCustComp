/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EX170CL   Clear Item Runner exceptions                           */
/*  24 May 2007                                                      */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   05/24/07  DAS  5.10                                             */
/*     - Created                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EX170CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE('      ')
             DCL        VAR(&PGM)   TYPE(*CHAR) LEN(8)  VALUE(EX170A)

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

          /* OVRDBF     FILE(&FILE) SHARE(*YES)  */
          /* OPNDBF     FILE(&FILE) OPTION(*ALL) */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
