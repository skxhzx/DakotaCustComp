/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TF120TCL  Close open route transactions                          */
/*  14 March, 1996                                                   */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TF120TCL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(PT120A)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT) TYPE(*CHAR) LEN(2000)
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

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(LABEL8) SHARE(*YES)
             OPNQRYF    FILE((LABEL8) (ORDD)) FORMAT(LABEL8) +
                          KEYFLD((LABEL8/L8WHSE) (LABEL8/L8RTE) +
                          (LABEL8/L8PO) (LABEL8/L8TRN#)) +
                          JFLD((LABEL8/L8ORD ORDD/ODORD) +
                          (LABEL8/L8ITEM ORDD/ODITEM))

/*  On with the show ... */

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(PT120B) PARM(&UNQKEY &RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)

DONE:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             DLTOVR     FILE(LABEL8)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
