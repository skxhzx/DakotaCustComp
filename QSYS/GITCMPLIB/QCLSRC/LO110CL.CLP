/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LO110CL   TRUCK LOADER                                           */
/*  06 JULY, 2004                                                    */
/*  KENNETH ELDER                                                    */
/*                                                                   */
/*  Created                                                          */
/*  07/06/04  KDE                                                    */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LO110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('TRUCK LOADER')

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


/*  LOAD FIRST SCREEN  */

AGAIN:

             CALL       PGM(LO110) PARM(&WHSE &PRTE &PRTID &MEMBER +
                          &RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)

               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) +
                          MSGTYPE(*INFO)
             GOTO       CMDLBL(GETOUT)
               ENDDO

/*  RUN SUBFILE PROGRAM FOR BALANCE OF PALLETS FOR ROUTE   */
             CALL       PGM(LO120CL) PARM(&WHSE &PRTE &PRTID &MEMBER)
             GOTO       CMDLBL(AGAIN)

   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

 GETOUT:

             ENDPGM
