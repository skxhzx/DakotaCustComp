/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT160CL   Close open customer return transactions                */
/*  09 November 1994                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/24/96  DAS  2.13                                            */
/*      - Added varialbe &PGMTYPE to identify whether the            */
/*        transactions are normal customer, transfer or POS.         */
/*      - Added new variable to called programs.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT160CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGMTYPE)  TYPE(*CHAR) LEN(8)  VALUE(*NORMAL)
             DCL        VAR(&PGM)      TYPE(*CHAR) LEN(8)  VALUE(PT160A)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

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

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN &PGMTYPE)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(PT160B) PARM(&UNQKEY &RETURN &PGMTYPE)
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
