/*-----------------------------------------------------------------*/
/*                                                                 */
/*  SAVEIT      Save library to save file in library TRANSFER      */
/*  19 May 2000                                                    */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*    05/19/00  DAS  4.14                                          */
/*      - Created                                                  */
/*                                                                 */
/*    06/22/00  DAS  4.14a                                         */
/*      - Added logic to send messages back to user                */
/*                                                                 */
/*    11/02/01  DAS  4.16                                          */
/*      - Added &TGTRLS parameter                                  */
/*                                                                 */
/*    06/25/02  DAS  4.16a                                         */
/*      - Revised SAVLIB command to create print output            */
/*                                                                 */
/*    08/21/08  DAS  5.20a                                         */
/*      - Revised to send *escape message upon error               */
/*      - Revised SAVLIB command to do save-while-active           */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &LIB2SAV  Library to save                                */
/*        &TFRLIB   Transfer library                               */
/*        &TGTRLS   Target release                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/

 SAVEIT:     PGM        PARM(&LIB2SAV &TFRLIB &TGTRLS)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&LIB2SAV)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&TFRLIB)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&TGTRLS)   TYPE(*CHAR) LEN(8)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CHKOBJ     OBJ(&LIB2SAV) OBJTYPE(*LIB)
             RMVMSG     CLEAR(*ALL)

             CHGVAR     VAR(&MSGDTA) VALUE('Creating save file' *BCAT +
                          &TFRLIB *CAT '/' *CAT &LIB2SAV)
             MSGBFC     MESSAGE(&MSGDTA)
             CRTSAVF    FILE(&TFRLIB/&LIB2SAV)
             MONMSG     MSGID(CPF7302) EXEC(DO)
               RMVMSG     CLEAR(*ALL)
               CLRSAVF    FILE(&TFRLIB/&LIB2SAV)
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE('Saving library' *BCAT +
                          &LIB2SAV *BCAT 'to save file' *BCAT +
                          &TFRLIB *BCAT '/' *CAT &LIB2SAV *BCAT +
                          'release ' *CAT &TGTRLS)
             MSGBFC     MESSAGE(&MSGDTA)

             SAVLIB     LIB(&LIB2SAV) DEV(*SAVF) +
                          SAVF(&TFRLIB/&LIB2SAV) TGTRLS(&TGTRLS) +
                          SAVACT(*LIB) OUTPUT(*PRINT)

             SNDPGMMSG  MSG('SAVEIT finished successfully. See +
                          following messages for details.') +
                          MSGTYPE(*COMP)

             CHGVAR     VAR(&ERRFLAG) VALUE('0')
             GOTO       CMDLBL(NEXTMSG)

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')

             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          SAVEIT. See following messages for details.')
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA(&MSGDTA) +
                          MSGTYPE(*COMP)

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
             IF         COND(&ERRFLAG) THEN(DO)
             SNDPGMMSG  MSGID(CPF9899) MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             ENDDO

             ENDPGM
