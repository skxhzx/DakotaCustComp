/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DK110CL   Dock door maintenance                                  */
/*  05 November 2001                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    11/05/01  DAS  4.16                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 DK110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(DOCDOOR)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(DK110A)

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

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(DK110B) PARM(&UNQKEY &RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
