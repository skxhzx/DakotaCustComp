/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDATECL    PIR update - Main update program                   */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*                                                                 */
/*    06/27/96  DAS  2.14                                          */
/*      - Moved ENDDO for *NE '*ERROR' statement to after          */
/*        the cleanup code.                                        */
/*      - Added logic to rename PIRDBR file to '.O' instead        */
/*        of deleting them.                                        */
/*                                                                 */
/*    02/12/97  DAS  2.18                                          */
/*      - Revised to always check for PIRDBR1 file instead of      */
/*        only checking it when PIRDBR is created.                 */
/*                                                                 */
/*      - Added unconditional compile of program UPDATE because    */
/*        the database relation file layout changed between        */
/*        OS/400 V2R3M0 and V3R1M0.                                */
/*    07/17/97  RH   4.02                                          */
/*      - Add parameters &RSTLIB and &RSTLIBF libraries to be      */
/*        updated.                                                 */
/*    04/17/00  RH/DAS 4.13                                        */
/*      - Delete existing PIRDBR file.                             */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &RSTLIB   Program library to be updated                  */
/*        &RSTLIBF  File library to be updated                     */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDATECL:   PGM        PARM(&RSTLIB &RSTLIBF &RETURN)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&RSTLIB)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&RSTLIBF)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Delete old relation file */

             CHKOBJ     OBJ(&RSTLIBF/PIRDBR1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL5)
             DLTF       FILE(&RSTLIBF/PIRDBR1)

 SKIPDEL5:   CHKOBJ     OBJ(&RSTLIBF/PIRDBR) OBJTYPE(*FILE) MBR(*NONE  )
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL6)
             DLTF       FILE(&RSTLIBF/PIRDBR)

SKIPDEL6:
/* Create database relations file. */

             CHKOBJ     OBJ(&RSTLIBF/PIRDBR) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('Creating database +
                          relations file')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                DSPDBR     FILE(&RSTLIBF/*ALL) OUTPUT(*OUTFILE) +
                             OUTFILE(&RSTLIBF/PIRDBR)
 /* (2.18d)     CHKOBJ     OBJ(PIRF/PIRDBR1) OBJTYPE(*FILE) MBR(*NONE)    */
 /* (2.18d)     MONMSG     MSGID(CPF9801) EXEC(DO)                        */
 /* (2.18d)        CRTLF      FILE(PIRF/PIRDBR1) SRCFILE(PIR/QDDSFILES) + */
 /* (2.18d)                     WAITRCD(30)                               */
 /* (2.18d)     ENDDO                                                     */
             ENDDO

/* Create database relations logical file.  (2.18a)  */

             CHKOBJ     OBJ(&RSTLIBF/PIRDBR1) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CRTLF      FILE(&RSTLIBF/PIRDBR1) SRCFILE(&RSTLIB/QDDSFILES) +
                             WAITRCD(30)
             ENDDO

/* Unconditionally compile program UPDATE.  (2.18a)  */

             CRTRPGPGM  PGM(&RSTLIB/UPDATE) SRCFILE(&RSTLIB/QRPGSRC)

/* Call master file update program. */

             CALL       PGM(UPDATE) PARM(&RSTLIB &RSTLIBF &RETURN)

             IF         COND(&RETURN *NE '*ERROR') THEN(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('File updates completed +
                             successfully')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
        /*   ENDDO    2.14  */

/* Do some clean up. */

             CHKOBJ     OBJ(&RSTLIBF/PIRDBR1.O) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL1)
             DLTF       FILE(&RSTLIBF/PIRDBR1.O)

SKIPDEL1:    RNMOBJ     OBJ(&RSTLIBF/PIRDBR1) OBJTYPE(*FILE) +
                          NEWOBJ(PIRDBR1.O)

             CHKOBJ     OBJ(&RSTLIBF/PIRDBR.O) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL2)
             DLTF       FILE(&RSTLIBF/PIRDBR.O)

SKIPDEL2:    RNMOBJ     OBJ(&RSTLIBF/PIRDBR) OBJTYPE(*FILE) +
                          NEWOBJ(PIRDBR.O)

             CHKOBJ     OBJ(&RSTLIBF/UPDFILES.O) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(GOTO SKIPDEL3)
             DLTF       FILE(&RSTLIBF/UPDFILES.O)

SKIPDEL3:    RNMOBJ     OBJ(&RSTLIBF/UPDFILES) OBJTYPE(*FILE) +
                          NEWOBJ(UPDFILES.O)

             RETURN

             ENDDO

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
