/*-------------------------------------------------------------------*/
/*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SPI260CL   SAP - Import Customer Orders as Purchase Orders       */
/*  24 June 2006                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    06/24/06  MLB  5.10                                            */
/*      - Created.                                                   */
/*      - Support for custom client code included.                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SPI260CL:    PGM        PARM(&cmd &mbr &otype &run &outq &form)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SPI260CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(NONE)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SPI265)

  /* Client ID's.                                                            */


  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Import Host Purchase Orders')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing Host Purchase Orders')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&cmd)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&import_po)  TYPE(*CHAR) LEN(04)
             DCL        VAR(&mbr)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&mbrpo)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&otype)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&run)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&outq)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&form)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&JOBNBR)     TYPE(*CHAR)  LEN(06)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*  Get client code. */

             CALL       PGM(PIRCLIENT) PARM(&CLIENT)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Don't get options if being run from JOBQ. */

             RTVJOBA    NBR(&JOBNBR) TYPE(&TYPE)

 REPORT:

/* Get printer device to use and then execute print program. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* Create member name */

             CALL       PGM(PIRFTP#) PARM(&NXTNUM)
             CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)
             CHGVAR     VAR(&MBRPO) VALUE('P' *CAT &NXTNUMA)

/* Add member to import files */

             ADDPFM     FILE(IMPFPOH2) MBR(&MBRPO)
             MONMSG     MSGID(CPF5812 CPF7306) EXEC(DO)
               CLRPFM     FILE(IMPFPOH2) MBR(&MBRPO)
             ENDDO

             ADDPFM     FILE(IMPFPOHM) MBR(&MBRPO)
             MONMSG     MSGID(CPF5812 CPF7306) EXEC(DO)
               CLRPFM     FILE(IMPFPOHM) MBR(&MBRPO)
             ENDDO

             ADDPFM     FILE(IMPFPOD2) MBR(&MBRPO)
             MONMSG     MSGID(CPF5812 CPF7306) EXEC(DO)
               CLRPFM     FILE(IMPFPOD2) MBR(&MBRPO)
             ENDDO

/* Apply file overrides */

             OVRDBF     FILE(IMPFPOH2) TOFILE(IMPFPOH2) MBR(&MBRPO)
             OVRDBF     FILE(IMPFPOHM) TOFILE(IMPFPOHM) MBR(&MBRPO)
             OVRDBF     FILE(IMPFPOD2) TOFILE(IMPFPOD2) MBR(&MBRPO)

             OVRDBF     FILE(IMPFORDH) TOFILE(IMPFORDH) MBR(&MBR)
             OVRDBF     FILE(IMPFORDM) TOFILE(IMPFORDM) MBR(&MBR)
             OVRDBF     FILE(IMPFORDD) TOFILE(IMPFPOHM) MBR(&MBR)

/*  Extract Purchase Orders from Import customer order files. */

             CALL       PGM(&RPTPGM) PARM(&cmd &import_po &return)

/*  Run Dakota Purchase Order import program.        */

             IF         COND(&import_po *eq '*YES') THEN(DO)
               SBMJOB  CMD(CALL PGM(PI260CL) PARM(&MBRPO '*JOBQ2' +
                          &OUTQ &FORM)) JOB(PI260CL)
               return
             enddo
             ELSE       CMD(DO)
               DLTOVR     FILE(impfpoh2)
               DLTOVR     FILE(impfpohm)
               DLTOVR     FILE(impfpod2)
               RMVM       FILE(impfpoh2) MBR(&MBRPO)
               MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                            CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
               RMVM       FILE(impfpohm) MBR(&MBRPO)
               MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                            CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
               RMVM       FILE(impfpod2) MBR(&MBRPO)
               MONMSG     MSGID(CPF7301 CPF320A CPF320B CPF3203 +
                            CPF3220 CPF3273 CPF7301 CPF7310 CPF0001)
             Enddo

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
        /*   IF         COND(&SEV *LT 09) THEN(GOTO CMDLBL(NEXTMSG)) */
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
