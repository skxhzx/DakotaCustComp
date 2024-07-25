/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SE110CL   Shorts Entry                                           */
/*  10 September, 2004                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Created                                                          */
/*  09/10/04  HNK  4.17                                              */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SE110CL:    PGM        PARM(&WHSE &WHDP &EMP# &PSHFT &PCREW &PTRN# +
                          &PRTID &PRTE &PPLID &PPAL# &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Shorts entry')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&EMP#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PCREW)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PRTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PPAL#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PSHFT)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PTRN#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PDETL)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TODT)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
             DCL        VAR(&WHDP)       TYPE(*CHAR) LEN(5)

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  Get options. */

AGAIN:

             CALL       PGM(SE110) PARM(&WHSE &WHDP &EMP# &PSHFT +
                          &PCREW &PTRN# &PRTID &PRTE &PPLID &PPAL# +
                          &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
             GOTO       CMDLBL(GETOUT)
               ENDDO

/*  Otherwise, run program. */

 REPORT:

             CALL       PGM(SE112) PARM(&WHSE &WHDP &EMP# &PSHFT +
                          &PCREW &PTRN# &PRTID &PRTE &PPLID &PPAL# +
                          &RETURN)

             RCLRSC     LVL(*CALLER)

             GOTO       CMDLBL(AGAIN)

 /* Receive any messages and pass them on */

 GETOUT:

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 OUT:
 NOMSG:

             ENDPGM
