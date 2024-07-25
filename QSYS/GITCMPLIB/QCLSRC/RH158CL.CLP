/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH158CL   Export Catchweights for Route                          */
/*  27 April 2005                                                    */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    04/27/05  MLB  5.00                                            */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD    -  Command                                             */
/*    &WHSE   -  Warehouse                                           */
/*    &RTID   -  Route id                                            */
/*    &RTE    -  Host route                                          */
/*    &RTN    -  Return code                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will ensure default member CATCHWGT is added as a  */
/*   new member in all of the export files.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH158CL:    PGM        PARM(&CMD &WHSE &RTID &RTE &RTN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(RH158)

  /* Export files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDD')
             DCL        VAR(&FILEC) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDC')
             DCL        VAR(&FILET) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFORDT')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10) VALUE('CATCHWGT')
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(3 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Create members for export files */

             ADDPFM     FILE(&FILEH) MBR(&MBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* Ignore member not +
                          added. */
             ADDPFM     FILE(&FILED) MBR(&MBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* Ignore member not +
                          added. */
             ADDPFM     FILE(&FILEC) MBR(&MBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* Ignore member not +
                          added. */
             ADDPFM     FILE(&FILET) MBR(&MBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* Ignore member not +
                          added. */

/*  Call program to move Only Catchweights to unique Export file. */

             OVRDBF     FILE(&FILEH) MBR(&MBR)
             OVRDBF     FILE(&FILED) MBR(&MBR)
             OVRDBF     FILE(&FILEC) MBR(&MBR)
             OVRDBF     FILE(&FILET) MBR(&MBR)

             CALL       PGM(&EXPPGM) PARM(&CMD &WHSE &RTID &RTE &RTN)


/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             RMVMSG     CLEAR(*ALL)

/*  Receive any messages and pass them on  */

 GETOUT:

 /* Receive any messages and pass them on */


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

             ENDPGM
