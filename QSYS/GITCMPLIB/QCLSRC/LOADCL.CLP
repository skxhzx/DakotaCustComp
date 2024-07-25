/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADCL: Loader Module -Truck loader module - Initial Menu.       */
/*  May 24, 2006                                                     */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*      - Created.                                                   */
/*                                                                   */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    ##/##/##  XXXx-XXX                                             */
/*      Text . . .                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*-------------------------------------------------------------------*/

 LOADCL:     PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational message. */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
             VALUE('   You are not authorized to use this option.')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&POPT)       TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGMID) VALUE(LOADCL)

             RTVJOBA    USER(&PUSR)

/*  Check if user is authorized to use this option */

             CALL       PGM(CHKLIST) PARM(&PGMID &POPT &PUSR &PRTN)

             IF         COND(&PRTN *EQ '*NO')  THEN(DO)

                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)

             RETURN
             ENDDO


/* Otherwise, display menu.                                            */
/* Display load module initial screen 'Route Status Summary            */

             GO PIRLOADR

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                        MSGID(&MSGID) SEV(&SEV) +
                        MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) TOUSR(&PUSR) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
