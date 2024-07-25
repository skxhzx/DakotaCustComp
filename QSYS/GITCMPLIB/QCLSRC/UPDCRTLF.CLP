/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDCRTLF    PIR update - Create LF                             */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*    07/17/97  RH   4.02                                          */
/*      - Add parameter &RSTLIB Program library to update.         */
/*        Add parameter &RSTLIBF File library to update.           */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &FILE     Logical file to create                         */
/*        &TYPE     Type                                           */
/*        &RSTLIB   File library to update                         */
/*        &RSTLIBF  File library to update                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDLF:      PGM        PARM(&FILE &TYPE &RSTLIB &RSTLIBF &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&FILE)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&RSTLIB)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIBF)  TYPE(*CHAR) LEN(10)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CHGVAR     VAR(&MSGDTA) VALUE('Creating logical file' +
                          *BCAT &FILE)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/* Only do create if file doesn't exist. */

             CHKOBJ     OBJ(&RSTLIBF/&FILE) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/&FILE) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
                CHGVAR     VAR(&MSGDTA) VALUE('Create successful')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&RETURN) VALUE('*OK')
                RETURN
             ENDDO

/* File already existed. */

   /* If this is a 'New' file, then everything is ok. */

             IF         COND(&TYPE *EQ 'N') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('Create not necessary.  +
                             File already existed.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&RETURN) VALUE('*OK')
             ENDDO

   /* Otherwise, the old file should have been deleted earlier. */

             IF         COND(&TYPE *NE 'N') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('*** WARNING - File not +
                             created ***' *BCAT &FILE *BCAT 'already +
                             existed.')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&RETURN) VALUE('*WARNING')
             ENDDO
             RETURN

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')

             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          file update process.  See following messages +
                          and messages in PIRUPDDET message queue.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          file update process.  See following messages +
                          and messages in PIRUPD message queue.')
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)

 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDUSRMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPDDET)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
