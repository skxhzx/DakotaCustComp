/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPDCPY      PIR update - Copy                                  */
/*  18 June 1996                                                   */
/*  Dave Sommerville                                               */
/*                                                                 */
/*  Revisions                                                      */
/*    07/17/97  RH   4.02                                          */
/*        Add parameter &RSTLIBF File library to update.           */
/*    04/17/00  DAS/RH  4.13                                       */
/*        Change CHKOBJ to check for *FIRST member.                */
/*        Add MONMSG FOR CPF9815.                                  */
/*                                                                 */
/*    04/09/03  DAS  4.16                                          */
/*      - Added &CNVPGM and &RSTLIB parameters.                    */
/*      - If &CNVPGM is not blank the value will be called as a    */
/*        program, otherwise a normal CPYF will take place.        */
/*      - Added logic to see if new file exists.                   */
/*      - Revised GETOUT routine to say 'copy process' instead     */
/*        of 'file process'.                                       */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &NEWF     New file name                                  */
/*        &OLDF     Old file name                                  */
/*        &CNVPGM   Conversion program                             */
/*        &RSTLIB   Program library                                */
/*        &RSTLIBF  File library to update                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPDCPY:     PGM        PARM(&NEWF &OLDF &CNVPGM &RSTLIB &RSTLIBF +
                          &RETURN) /*416M*/

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&NEWF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&OLDF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&CNVPGM)   TYPE(*CHAR) LEN(10) /*416A*/
             DCL        VAR(&RSTLIB)   TYPE(*CHAR) LEN(10) /*416A*/
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

             CHGVAR     VAR(&MSGDTA) VALUE('Copying' *BCAT &OLDF +
                          *BCAT 'to' *BCAT &NEWF)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

/* Error if new file doesn't exist */  /*416A*/

             CHKOBJ     OBJ(&RSTLIBF/&NEWF) OBJTYPE(*FILE) MBR(*NONE)
             MONMSG     MSGID(CPF9801) EXEC(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('New file does not +
                             exist')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&RETURN) VALUE('*ERROR')
                RETURN
             ENDDO

/* If a current file doesn't exist then there is no reason to do copy. */

        /*   CHKOBJ     OBJ(&RSTLIBF/&OLDF) OBJTYPE(*FILE) MBR(*FIRST)   415D */
             CHKOBJ     OBJ(&RSTLIBF/&OLDF) OBJTYPE(*FILE) MBR(*NONE) /* 415M */
             MONMSG     MSGID(CPF9801 CPF9815) EXEC(DO)
                CHGVAR     VAR(&MSGDTA) VALUE('New file - Copy not +
                             necessary')
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')
                RETURN
             ENDDO

/* If old file doesn't have member then there is no reason to do copy.    415A*/

             CHKOBJ     OBJ(&RSTLIBF/&OLDF) OBJTYPE(*FILE) MBR(*FIRST)  /*415A*/
             MONMSG     MSGID(CPF9801 CPF9815) EXEC(DO)                 /*415A*/
             CHGVAR     VAR(&MSGDTA) VALUE('No member in current +
                          file - Copy not necessary') /*415A*/
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)   /*415A*/
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET) /*415*/
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')                /*415A*/
                RETURN                                                  /*415A*/
             ENDDO                                                      /*415A*/

/* If new file doesn't have member then there is no reason to do copy.    415A*/

             CHKOBJ     OBJ(&RSTLIBF/&NEWF) OBJTYPE(*FILE) MBR(*FIRST)  /*415A*/
             MONMSG     MSGID(CPF9801 CPF9815) EXEC(DO)                 /*415A*/
             CHGVAR     VAR(&MSGDTA) VALUE('No member in new file - +
                          Copy not necessary') /*415A*/
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)   /*415A*/
                SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET) /*415*/
                CHGVAR     VAR(&RETURN) VALUE('*NOTFND')                /*415A*/
                RETURN                                                  /*415A*/
             ENDDO                                                      /*415A*/

/* Copy old to new. */

             IF         COND(&CNVPGM = ' ') THEN(DO)         /*416A*/
             CPYF       FROMFILE(&OLDF) TOFILE(&NEWF) +
                          MBROPT(*ADD) FMTOPT(*MAP *DROP)
             ENDDO                                           /*416A*/

/* Or run program to do the copy */                          /*416A*/

             IF         COND(&CNVPGM *NE ' ') THEN(DO)
             CALL       PGM(&CNVPGM) PARM(&NEWF &OLDF &RSTLIB &RSTLIBF)
             ENDDO

             CHGVAR     VAR(&MSGDTA) VALUE('Copy successful')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&RETURN) VALUE('*OK')
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
                          copy update process.  See following messages +
                          and messages in PIRUPDDET message queue.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          copy update process.  See following messages +
                          and messages in PIRUPD message queue.')
             SNDPGMMSG  MSG(&MSGDTA) MSGTYPE(*COMP)

 NEXTMSG:    DO
             RCVMSG     MSGDTA(&MSGDTA) MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             SNDUSRMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPDDET)
             SNDUSRMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*INFO) +
                          TOMSGQ(PIRUPD)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*-----------------------------------------------------------------*/
/*        End of program                                           */
/*-----------------------------------------------------------------*/

END:         ENDPGM
