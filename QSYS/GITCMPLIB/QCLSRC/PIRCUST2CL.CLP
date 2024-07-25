/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIRCUS2TCL: Provide secured access to 'Customer Orders' screen.  */
/*              Menu: Pirmain/Opt# 2. This clp replaces control      */
/*              statement 'Go Pircust2 *no' in 'Pirmainqq' control   */
/*              module.                                              */
/*                                                                   */
/*  September 26, 2006                                               */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PIRCUST2CL: PGM

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
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&PROC)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PROC)  VALUE(PIRCUST2CL)

             RTVJOBA    USER(&PUSR)

/*  Check if user is authorized to use this option */

             CALL       PGM(CHKCREW) PARM(&PUSR &PRTN &PROC)

             IF         COND(&PRTN *EQ '*NO')  THEN(DO)

                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)

             RETURN
             ENDDO


/*  Otherwise, display menu. */

             GO PIRCUST2 *NO

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
