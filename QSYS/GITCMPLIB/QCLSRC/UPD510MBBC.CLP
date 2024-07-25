/*-----------------------------------------------------------------*/
/*                                                                 */
/*  UPD510MBBC      Update Program - Create dtaara's.              */
/*  22 February 2007                                               */
/*  Max Blacknik                                                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*  Revisions                                                      */
/*    02/22/07  MLB  5.10                                          */
/*      - Create new export file number dtaara's used by clients   */
/*        with Stanpack Host software installed.                   */
/*                                                                 */
/*-----------------------------------------------------------------*/
/*                                                                 */
/*       Parameters                                                */
/*                                                                 */
/*        &NEWF     New file name                                  */
/*        &OLDF     Old file name                                  */
/*        &TYPE     Type                                           */
/*        &FTYPE    File type                                      */
/*        &RSTLIBF  File library to update                         */
/*        &RETURN   Return code                                    */
/*                                                                 */
/*-----------------------------------------------------------------*/

 UPD510MBA:  PGM        PARM(&FLIB)

/*-----------------------------------------------------------------*/
/*  Declare variables                                              */
/*-----------------------------------------------------------------*/

   /* Parameters and work variables */

             DCL        VAR(&FLIB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)     TYPE(*CHAR) LEN(1)

   /* Standard message handling variables */

             DCL        VAR(&ABORT)    TYPE(*LGL)  VALUE('0')
             DCL        VAR(&ERRFLAG)  TYPE(*LGL)  VALUE('1')
             DCL        VAR(&MSGDTA)   TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)      TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

             CHGVAR     VAR(&MSGDTA) VALUE('Creating new export dtaara''s')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)

             CRTDTAARA  DTAARA(&FLIB/EXPFADJ#) TYPE(*DEC) LEN(1 0) +
                          VALUE(0) TEXT('Next Adj Export file# for +
                          Stanpack Host.') AUT(*ALL)
             MONMSG     MSGID(CPF1008 CPF1023 CPF1092)

             CRTDTAARA  DTAARA(&FLIB/EXPFINV#) TYPE(*DEC) LEN(1 0) +
                          VALUE(0) TEXT('Next Inv Counts Export +
                          file# for Stanpack Host.') AUT(*ALL)
             MONMSG     MSGID(CPF1008 CPF1023 CPF1092)

             CRTDTAARA  DTAARA(&FLIB/EXPFORD#) TYPE(*DEC) LEN(1 0) +
                          VALUE(0) TEXT('Next Cust Orders Export file# for +
                          Stanpack Host.') AUT(*ALL)
             MONMSG     MSGID(CPF1008 CPF1023 CPF1092)

             CRTDTAARA  DTAARA(&FLIB/EXPFPO#) TYPE(*DEC) LEN(1 0) +
                          VALUE(0) TEXT('Next P/O Export file# for +
                          Stanpack Host.') AUT(*ALL)
             MONMSG     MSGID(CPF1008 CPF1023 CPF1092)

             CRTDTAARA  DTAARA(&FLIB/EXPFRTN#) TYPE(*DEC) LEN(1 0) +
                          VALUE(0) TEXT('Next Cust Returns Export fille# for +
                          Stanpack Host.') AUT(*ALL)
             MONMSG     MSGID(CPF1008 CPF1023 CPF1092)

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
                          dtaara create process. See following messages+
                          and messages in PIRUPDDET message queue.')
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPD)
             SNDUSRMSG  MSG(&MSGDTA) MSGTYPE(*INFO) TOMSGQ(PIRUPDDET)
             CHGVAR     VAR(&MSGDTA) VALUE('Error occured during +
                          dtaara create process. See following messages+
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
