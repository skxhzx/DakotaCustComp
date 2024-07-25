/*-----------------------------------------------------------------*/
/*                                                                 */
/*  CRTPIRDBR   Q&D to create PIRDBR file.                         */
/*  10 April 2003                                                  */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*    04/10/03  DAS  4.16                                          */
/*      - Created.                                                 */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &RSTLIB   DDS library                                    */
/*        &RSTLIBF  File library to be updated                     */
/*                                                                 */
/*-----------------------------------------------------------------*/

 CRTPIRDBR:  PGM        PARM(&RSTLIB &RSTLIBF)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

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

/* Create database relations file. */

                CHGVAR     VAR(&MSGDTA) VALUE('Creating database +
                          relations file')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                DSPDBR     FILE(&RSTLIBF/*ALL) OUTPUT(*OUTFILE) +
                             OUTFILE(&RSTLIBF/PIRDBR)

/* Create database relations logical file.  (2.18a)  */

                CRTLF      FILE(&RSTLIBF/PIRDBR1) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             RETURN

/*-----------------------------------------------------------------*/
/*  Receive any error messages and pass them on before leaving.    */
/*-----------------------------------------------------------------*/

 GETOUT:
             IF         &ABORT SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     VAR(&ABORT) VALUE('1')

             CHGVAR     VAR(&MSGDTA) VALUE('Error occured creating +
                          PIRDBR file. See following messages.')
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)

 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
