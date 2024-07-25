/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LB840CL   Work with associated labels for tran#                  */
/*  18 April 2001                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    04/18/01  DAS  4.15                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LB840CL:    PGM        PARM(&CMD &TRN#)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TRN#)       TYPE(*CHAR) LEN(7)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Create selection criteria string. */

             CHGVAR     VAR(&QRYSLT) VALUE('LBTRN# *EQ ' *CAT &TRN#)

   /* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(LABEL) SHARE(*YES)
             OPNQRYF    FILE((LABEL)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          KEYFLD(*FILE)

             CALL       PGM(LB840) PARM(&CMD &TRN#)

             DLTOVR     FILE(LABEL)
             RCLRSC     *CALLER

             ENDPGM
