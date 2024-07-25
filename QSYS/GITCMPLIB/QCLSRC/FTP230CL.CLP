/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP230CL  FTP Customer Order Export - Display single member      */
/*  08 March 1999                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/08/99  DAS  4.11                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP230CL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('FTP customer order export - +
                          Display single member')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CALL       PGM(FTP230) PARM(&TYPE &MBR &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO


/*  Make sure members exist                                          */

             IF         COND(&TYPE = 'H') THEN(CHKOBJ OBJ(EXPFORDH) +
                          OBJTYPE(*FILE) MBR(&MBR))

             IF         COND(&TYPE = 'D') THEN(CHKOBJ OBJ(EXPFORDD) +
                          OBJTYPE(*FILE) MBR(&MBR))

             IF         COND(&TYPE = 'C') THEN(CHKOBJ OBJ(EXPFORDC) +
                          OBJTYPE(*FILE) MBR(&MBR))

             IF         COND(&TYPE = 'T') THEN(CHKOBJ OBJ(EXPFORDT) +
                          OBJTYPE(*FILE) MBR(&MBR))


/*  Display list of members. */

             IF         COND(&TYPE = 'H') THEN(DSPPFM FILE(EXPFORDH) +
                          MBR(&MBR))

             IF         COND(&TYPE = 'D') THEN(DSPPFM FILE(EXPFORDD) +
                          MBR(&MBR))

             IF         COND(&TYPE = 'C') THEN(DSPPFM FILE(EXPFORDC) +
                          MBR(&MBR))

             IF         COND(&TYPE = 'T') THEN(DSPPFM FILE(EXPFORDT) +
                          MBR(&MBR))

             GOTO       CMDLBL(BOTTOM)

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

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
