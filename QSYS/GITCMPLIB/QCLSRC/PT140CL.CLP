/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT140CL   Close open receiving transactions                      */
/*  07 November, 1994                                                */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/18/96  DAS  2.11                                            */
/*      - Added opnqryf statement to select only the PO's that       */
/*        do not end with 'TF'.                                      */
/*                                                                   */
/*    05/28/96  DAS  2.13                                            */
/*      - Added varialbe &PGMTYPE to identify whether the            */
/*        transactions are normal customer, transfer or POS.         */
/*      - Added new variable to called programs.                     */
/*      - This negates the 2.11 changes.                             */
/*    04/03/00  HNK  4.13                                            */
/*      - Default to call PT140B for all POs.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT140CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGMTYPE)  TYPE(*CHAR) LEN(8)  VALUE(*NORMAL)
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
/*           CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN &PGMTYPE)       */
/*           IF         (&RETURN = '*F9') DO                            */
/*                      CALL PGM(PT140B) PARM(&UNQKEY &RETURN &PGMTYPE) */
/*                           IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)   */
/*                           ELSE                                       */
/*                           GOTO  CMDLBL(DONE)                         */
/*                      ENDDO                                           */
/*           ELSE                                                       */
/*                      GOTO       CMDLBL(DONE)                         */

             CALL       PGM(PT140B)  PARM(&UNQKEY &RETURN &PGMTYPE)
             IF         (&RETURN = '*F9') DO
                        CALL PGM(PT140A) PARM(&UNQKEY &RETURN &PGMTYPE)
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
