/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RESNDPOCL   COPY HISTORY P/O HDR/DTL INTO EXPORT HDR/DTL         */
/*  19 AUGUST 2008                                                   */
/*  MAX BLACKNIK                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    08/19/08  MLB  5.20                                            */
/*     - CREATED.                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &PO     -  P/O                                                 */
/*    &DATE   -  DATE EXPORTED                                       */
/*    &TIME   -  TIME EXPORTED                                       */
/*    &EXPMBR -  EXPORT MBR TO USE.                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO726CL:    PGM        PARM(&WHSE &PO &EXPDTE &EXPTIM &EXPMBR)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Export program. */

             DCL        VAR(&PO    ) TYPE(*CHAR) LEN(9)
             DCL        VAR(&EXPDTE) TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXPDATE) TYPE(*DEC) LEN(8 0)
             DCL        VAR(&EXPTIM) TYPE(*CHAR) LEN(6)
             DCL        VAR(&EXPTIME) TYPE(*DEC) LEN(6 0)
             DCL        VAR(&EXPPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(RESNDPO)

  /* Import files */

             DCL        VAR(&FILEH) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOH')
             DCL        VAR(&FILED) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOD')
             DCL        VAR(&FILEE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPOE')                          /* (417)  */

  /* Number of 'Transfer complete' messages to look for */

             DCL        VAR(&TFRNEEDED) TYPE(*DEC) LEN(1 0) VALUE(2)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&EXPFLAG)    TYPE(*CHAR) LEN(8) /* 414A */
             DCL        VAR(&EXPTYPE)    TYPE(*CHAR) LEN(8)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXPMBR)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGKEY)     TYPE(*CHAR) LEN(4)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&PGM)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RTN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSEN)      TYPE(*DEC ) LEN(3 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))
             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* Create member name */


/* Create members for export files */

             ADDPFM     FILE(&FILEH) MBR(&EXPMBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* IGNORE NOT ADDED. */
             ADDPFM     FILE(EXPFPOHSPK) MBR(&EXPMBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* IGNORE NOT ADDED. */
             ADDPFM     FILE(&FILED) MBR(&EXPMBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* IGNORE NOT ADDED. */
             ADDPFM     FILE(&FILEE) MBR(&EXPMBR)                   /* (417) */
             MONMSG     MSGID(CPF3204 CPF7306) /* IGNORE NOT ADDED. */
             ADDPFM     FILE(EXPFPODSPK) MBR(&EXPMBR)
             MONMSG     MSGID(CPF3204 CPF7306) /* IGNORE NOT ADDED. */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Exporting P.O.''s into member' +
                          *BCAT &EXPMBR *TCAT ' in P.O. export files') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*  Call program to move route to export files */

             OVRDBF     FILE(&FILEH) MBR(&EXPMBR)
             OVRDBF     FILE(&FILED) MBR(&EXPMBR)

             CHGVAR     VAR(&WHSEN) VALUE(&WHSE)
             CHGVAR     VAR(&EXPDATE) VALUE(&EXPDTE)
             CHGVAR     VAR(&EXPTIME) VALUE(&EXPTIM)

             CALL       PGM(&EXPPGM) PARM(&WHSEN &PO &EXPDATE &EXPTIME)

             DLTOVR     FILE(&FILEH &FILED)

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             RCLRSC     LVL(*CALLER)
             RETURN

/*  Receive any messages and pass them on  */

 GETOUT:


 BOTTOM:


             ENDPGM
