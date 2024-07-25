/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT145CL   Close open transfer receiving transactions             */
/*  07 November, 1994                                                */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT145CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGMTYPE)  TYPE(*CHAR) LEN(8)  VALUE(*TRANSFR)
             DCL        VAR(&PGM)      TYPE(*CHAR) LEN(8)  VALUE(PT140A)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT) TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)  TYPE(*CHAR) LEN(1) VALUE('"')
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

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN &PGMTYPE)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(PT140B) PARM(&UNQKEY &RETURN &PGMTYPE)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)

DONE:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
