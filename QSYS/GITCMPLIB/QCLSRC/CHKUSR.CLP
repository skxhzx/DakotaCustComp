/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CHKUSR    Check if user already running RF program               */
/*  01 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   01/31/08  DAS  5.20                                             */
/*     - Added BFC to allowed users.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CHKUSR:     PGM        PARM(&TYPE &PCODE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

 /* General variables */

             DCL        VAR(&DTAARA)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&EMP#A)   TYPE(*CHAR) LEN(5)
             DCL        VAR(&EXIST)   TYPE(*LGL)
             DCL        VAR(&LIB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MESSAGE) TYPE(*CHAR) LEN(512)
             DCL        VAR(&TYPE)    TYPE(*CHAR) LEN(5)

 /* GETUSER program parameters */

             DCL        VAR(&PCODE)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&PWHSE)   TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&PEMP#)   TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&PFNAM)   TYPE(*CHAR) LEN(15)
             DCL        VAR(&PINIT)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&PLNAM)   TYPE(*CHAR) LEN(20)
             DCL        VAR(&PWHDP)   TYPE(*CHAR) LEN(5)
             DCL        VAR(&PSTYP)   TYPE(*CHAR) LEN(1)
             DCL        VAR(&PSHFT)   TYPE(*CHAR) LEN(6)
             DCL        VAR(&PCREW)   TYPE(*CHAR) LEN(6)
             DCL        VAR(&PNHRS)   TYPE(*DEC)  LEN(3 1)
             DCL        VAR(&PRTN)    TYPE(*CHAR) LEN(8)

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

             IF (&PCODE *EQ ' ') THEN(DO)
               RTVJOBA USER(&PCODE)
             ENDDO

 /* Multiple BFCTEST users allowed, so just get out */

             IF (&PCODE *EQ 'BFC') THEN(GOTO BOTTOM)  /*520 A*/
             IF (&PCODE *EQ 'BFCTEST') THEN(GOTO BOTTOM)

 /* Get user information */

             CALL       PGM(GETUSER) PARM(&PCODE &PWHSE &PEMP# +
                          &PFNAM &PINIT &PLNAM &PWHDP &PSTYP &PSHFT +
                          &PCREW &PNHRS &PRTN)

 /* If employee # comes back zero, get out */

             IF (&PEMP# *EQ 0) THEN(DO)
               IF (&TYPE *EQ '*OUT') THEN(GOTO BOTTOM)
               CHGVAR     VAR(&MESSAGE) VALUE('No Empl# for ' +
                          *CAT &PCODE)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA(&MESSAGE) MSGTYPE(*ESCAPE)
             ENDDO

 /* Check for existance of employee data area */

             CHGVAR     VAR(&EMP#A) VALUE(&PEMP#)
             CHGVAR     VAR(&DTAARA) VALUE('EMP' *CAT &EMP#A)
             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(&DTAARA) OBJTYPE(*DTAARA)
             MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

 /* If data area doesn't exist, create it */

             IF (*NOT &EXIST) DO
               IF (&TYPE *EQ '*OUT') THEN(GOTO BOTTOM)
               RTVOBJD    OBJ(PIRBATCH) OBJTYPE(*DTAARA) RTNLIB(&LIB)
               CHGVAR     VAR(&MESSAGE) VALUE('Empl# ' *CAT +
                          &EMP#A *BCAT 'data area')
               CRTDTAARA  DTAARA(&LIB/&DTAARA) TYPE(*CHAR) LEN(1) +
                          TEXT(&MESSAGE) AUT(*USE)
             ENDDO

 /* If trying to get *IN, try to gain exclusive access to dtaara */

             IF (&TYPE *EQ '*IN') THEN(DO)
               ALCOBJ     OBJ((&DTAARA *DTAARA *EXCL)) WAIT(0)
               MONMSG     MSGID(CPF1002) EXEC(DO)
                 CHGVAR     VAR(&MESSAGE) VALUE('Id ' *CAT &PCODE +
                            *BCAT 'In Use')
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
