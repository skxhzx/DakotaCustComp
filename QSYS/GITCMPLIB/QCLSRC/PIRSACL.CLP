/*-------------------------------------------------------------------*/
/*   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PIRSACL     Gateway to Dakota Voice SA                           */
/*  09 November 2005                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*   11/09/05  5.00  MLB                                             */
/*     - Created.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &ENVTYPE - *PROD - Setup Production library list               */
/*               *TEST - Setup Test library list                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PIRSACL:  PGM        PARM(&ENVTYPE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ENVTYPE)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60)

             MONMSG     MSGID(CPF0000) EXEC(GOTO GETOUT)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Save Host user library list. */
             ADDLIBLE   LIB(JADA) POSITION(*LAST)
             MONMSG     MSGID(CPF2103 CPF2118)

/* Set Dakota Voice SA library list to either *PROD or *TEST. */

/* Cmd = *PROD - Setup Production Dakota Voice SA library list. */

             IF COND(&ENVTYPE = '*PROD') THEN(DO)
               RSTLIBL DTAARA(PIR/LIBLPIR)
               MONMSG     MSGID(CPD0030 CPF0001) EXEC(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                              MSGDTA('Library list configuration did +
                              not complete successfully. Contact IT +
                              supervisor before proceeding.') +
                              MSGTYPE(*INFO)
                 GOTO       CMDLBL(GETOUT)
               ENDDO
             ENDDO

/* Cmd = *TEST - Setup Test Dakota Voice SA library list. */

             IF COND(&ENVTYPE = '*TEST') THEN(DO)
               RSTLIBL DTAARA(PIR/LIBLPIRTST)
               MONMSG     MSGID(CPD0030 CPF0001) EXEC(DO)
                 SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                              MSGDTA('Library list configuration did +
                              not complete successfully. Contact IT +
                              supervisor before proceeding.') +
                              MSGTYPE(*INFO)
                 GOTO       CMDLBL(GETOUT)
               ENDDO
             ENDDO

/* Start Dakota Voice SA. */
             GO         MENU(PIRMAIN)

/* Add Utility library back to bottom of library list. */

             ADDLIBLE   LIB(JADA) POSITION(*LAST)
             MONMSG     MSGID(CPF2103 CPF2118)

/* Restore Host user library list. */

             RSTLIBL DTAARA(*PRV) CURLIB(*REPLACE)
             MONMSG     MSGID(CPD0030 CPF0001) EXEC(DO)
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                            MSGDTA('Library list configuration did +
                            not complete successfully. Contact IT +
                            supervisor before proceeding.') +
                            MSGTYPE(*INFO)
               GOTO       CMDLBL(GETOUT)
             ENDDO

 GETOUT:

             RMVLIBLE   LIB(JADA)
             MONMSG     MSGID(CPF2104 CPF2110)
             RCLRSC     LVL(*CALLER)

             ENDPGM
