/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FTP200CL  FTP Import - Display single member                     */
/*  30 March 2000                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/30/00  DAS  4.13                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    06/06/00  DAS  4.14                                            */
/*      - Added files IMPFSTUF and IMPFHSLT.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FTP200CL:   PGM        PARM(&FILE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CANCELMSG)  TYPE(*CHAR) LEN(60)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

  /* Initialize message */

             IF         COND(&FILE *EQ 'IMPFITMO') THEN(DO)
               CHGVAR     VAR(&CANCELMSG) VALUE('FTP Order Quantities +
                            Import - Display Single Member')
             ENDDO

  /* 414A */ IF         COND(&FILE *EQ 'IMPFSTUF') THEN(DO)
             CHGVAR     VAR(&CANCELMSG) VALUE('FTP StuffIt Import - +
                          Display Single Member')
             ENDDO

  /* 414A */ IF         COND(&FILE *EQ 'IMPFHSLT') THEN(DO)
             CHGVAR     VAR(&CANCELMSG) VALUE('FTP Home Slot Changes +
                          Import - Display Single Member')
             ENDDO

/*  On with the show ... */

             CALL       PGM(FTP200) PARM(&CANCELMSG &MBR &RETURN)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO


/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)


/*  Display list of members. */

             DSPPFM     FILE(&FILE) MBR(&MBR)

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
