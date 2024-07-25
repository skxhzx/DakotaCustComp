/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDFITEMCL   Copy PIRITEM records into IMPFITEM.PIRITEM           */
/*  04 July 1999                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDFITEMCL:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Import file and member */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFITEM')

             DCL        VAR(&MBR) TYPE(*CHAR) LEN(10) +
                          VALUE('PIRITEM')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Make sure members exist                                          */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Initializing member +
                          IMPFITEM.PIRITEM') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

             IF (*NOT &EXIST) DO
               ADDPFM     FILE(&FILE) MBR(&MBR)
             ENDDO

             IF (&EXIST) DO
               CLRPFM     FILE(&FILE) MBR(&MBR)
             ENDDO

/* Override import files to correct member */

             OVRDBF     FILE(&FILE) TOFILE(*FILE) MBR(&MBR)

/* Import orders */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Copying PIRITEM into +
                          IMPFITEM.PIRITEM') TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)

             CALL       PGM(QDFITEM)

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)
             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

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

               RCLRSC     LVL(*CALLER)

             ENDPGM
