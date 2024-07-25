/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CHKINOUT  Check DataArea In/Out - Only allowed to check in once  */
/*  19 September 2000                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CHKINOUT:   PGM        PARM(&TYPE &DTAARA)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&DTAARA)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXIST)   TYPE(*LGL)
             DCL        VAR(&LIB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MESSAGE) TYPE(*CHAR) LEN(512)
             DCL        VAR(&TYPE)    TYPE(*CHAR) LEN(5)

 /* Variables for sending messages to calling screen */

             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 /* Get user id if one was not sent in */

             IF (&DTAARA *EQ ' ') THEN(DO)
             CHGVAR     VAR(&MESSAGE) VALUE('CHKINOUT: Error - Data +
                          area name can not be blank')
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MESSAGE) MSGTYPE(*ESCAPE)
             ENDDO

 /* Check for existance of data area */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(&DTAARA) OBJTYPE(*DTAARA)
             MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

 /* If data area doesn't exist, create it */

             IF (*NOT &EXIST) DO
               IF (&TYPE *EQ '*OUT') THEN(GOTO BOTTOM)
               RTVOBJD    OBJ(PIRBATCH) OBJTYPE(*DTAARA) RTNLIB(&LIB)
               CRTDTAARA  DTAARA(&LIB/&DTAARA) TYPE(*CHAR) LEN(1) +
                          TEXT('Auto created by CHKINOUT') AUT(*USE)
             ENDDO

 /* If trying to get *IN, try to gain exclusive access to dtaara */

             IF (&TYPE *EQ '*IN') THEN(DO)
               ALCOBJ     OBJ((&DTAARA *DTAARA *EXCL)) WAIT(0)
               MONMSG     MSGID(CPF1002) EXEC(DO)
             CHGVAR     VAR(&MESSAGE) VALUE(&DTAARA *BCAT 'In Use')
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                            MSGDTA(&MESSAGE) MSGTYPE(*ESCAPE)
               ENDDO
             ENDDO

 /* If trying to get *OUT, let go of dtaara */

             IF (&TYPE *EQ '*OUT') THEN(DO)
               DLCOBJ     OBJ((&DTAARA *DTAARA *EXCL))
               MONMSG     MSGID(CPF1005)
             ENDDO

      /*     RMVMSG     CLEAR(*ALL)  */

 /* If trying to get *VIEW, call WRKOBJLCK */

             IF (&TYPE *EQ '*VIEW') THEN(DO)
               WRKOBJLCK  OBJ(&DTAARA) OBJTYPE(*DTAARA)
             ENDDO

 /* Receive any messages and pass them on */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                        MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:
 BOTTOM:
