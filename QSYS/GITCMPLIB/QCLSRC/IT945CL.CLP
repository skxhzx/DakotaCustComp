/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IT945CL   Open replenishment transactions by item                */
/*  01 June, 2005                                                    */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/01/05  HNK  5.00                                            */
/*      - Created                                                    */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IT945CL:    PGM        PARM(&ITEM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGMTYPE)  TYPE(*CHAR) LEN(8)  VALUE(*NORMAL)
             DCL        VAR(&PGM)      TYPE(*CHAR) LEN(8)  VALUE(IT940)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ITEM)   TYPE(*CHAR) LEN(15)
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

             CALL       PGM(IT945) PARM(&UNQKEY &RETURN &PGMTYPE &ITEM)

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
