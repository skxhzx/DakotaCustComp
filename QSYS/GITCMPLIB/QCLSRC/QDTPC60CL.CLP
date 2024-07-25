/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDTPC60CL   Q&D TPC - Delete new dept DRY slots added in error.  */
/*  13 February 2017                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    02/13/17  MLB  7.10                                            */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &whse   -  Warehouse                                           */
/*    &whdp   -  Department                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDTPC60CL:    PGM        PARM(&WHSE &WHDP)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&UPDPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(QDTPC60)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSEN)      TYPE(*DEC ) LEN(3 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member name */

/*  Call program to update slot file */

             OVRDBF     FILE(SLOT2RMV) TOFILE(PIRTFR/SLOT2RMV)
             OVRDBF     FILE(SLOT1)

             CHGVAR     VAR(&WHSEN) VALUE(&WHSE)

             CALL       PGM(&UPDPGM) PARM(&WHSEN &WHDP)

             DLTOVR     FILE(SLOT2RMV SLOT1)

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             RCLRSC     LVL(*CALLER)
             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:


 BOTTOM:


             ENDPGM
