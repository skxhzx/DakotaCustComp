/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADEQCL  Trailer Equipment audit View/Print - Pirloadr/Opt 10_  */
/*                                                                 | */
/*  October 31, 2006                               Pirldrpt/Opt 3 <- */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    MM/DD/YY  CBI-XXX                                              */
/*      Text.....................                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADEQCL:   PGM        PARM(&WHSE &FDATE &TDATE &FDTE6 &TDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADEQCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADR24)


             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LDRTEQ)


  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Trailer Equipment Audit')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Printing ''Trailer Equipment Audit')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&FDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&FILNAM)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RTE#)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&SORT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

 OPTNS:

/* Don't get options if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO REPORT)

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&WHSE &FDATE &TDATE &FDTE6 +
                          &TDTE6 &RETURN &VP &JOBQ &DEV &FORM &RTE# +
                          &SORT)


/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO


/*  See if user wants to put report on JOBQ. */

             IF (&JOBQ = 'Y') THEN(DO)
                SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &FDATE +
                &TDATE &FDTE6 &TDTE6 &RETURN &VP &JOBQ &DEV &FORM)) +
                JOB(&SBMPGM)
                GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

             MSGBFC     MESSAGE('Selecting records')
   /* Create selection criteria string. */

SELECT:
             CHGVAR     VAR(&QRYSLT) VALUE('LTWHSE *EQ ' *CAT &WHSE)

             IF         COND(&RTE# *NE *ALL)                       +
             THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LTRTE   +
                        *EQ ' *CAT &RTE#))
             ENDDO
/*-------------------------------------------------------------------*/
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LTSTRD *GE' *BCAT &QUOTE *CAT &FDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LTSTRD *LE' *BCAT &QUOTE *CAT &TDATE +
                           *CAT &QUOTE)
/*-------------------------------------------------------------------*/


             OVRDBF     FILE(LDR25) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) FORMAT(LDR25) QRYSLT(&QRYSLT) +
                        KEYFLD((LDRTEQ/LTWHSE) (LDRTEQ/LTSTRD)      +
                        (LDRTEQ/LTRTE))                             +
                        SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             CALL       PGM(GETUNQMEM) PARM(*REUSE LDR25B &MEMBER)


/* Delete, from qry file above, recs that do not fall into shift hours */

             OVRDBF     FILE(LDR25B)   TOFILE(LDR25B) MBR(&MEMBER)
             CALL       PGM(LOADR31) PARM(&FDATE &TDATE)


/* If viewing the report */

             IF         COND(&VP *EQ 'V') THEN(DO)

             CALL       PGM(LOADR25) PARM(&FDTE6 &TDTE6 &RETURN)

             IF (&RETURN = '*CANCEL') THEN(DO)
             CHGVAR     VAR(&RETURN)  VALUE('       ')
             RMVM        FILE(LDR25B) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RCLRSC     LVL(*CALLER)
             GOTO OPTNS
             ENDDO

             IF (&RETURN = '*EXIT') THEN(DO)
             CHGVAR     VAR(&RETURN)  VALUE('       ')
             GOTO CMDLBL(NOMSG)
             ENDDO

             IF         (&RETURN = '*F21') GOTO CMDLBL(PRINTRPT)
             ELSE
                        GOTO CMDLBL(NOMSG)
             ENDDO


PRINTRPT:

             OVRDBF     FILE(LDR25B)   TOFILE(LDR25B) MBR(&MEMBER)
             /*  By Route */

             IF (&SORT = '1') THEN(DO)
             RUNQRY     QRY(EQBYRTE) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)
             ENDDO


             /*  By Loader */

             IF (&SORT = '2') THEN(DO)
             RUNQRY     QRY(EQBYLOADR) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)
             ENDDO


/*  Receive any messages and pass them on  */

 GETOUT:
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

/*  Clean up before leaving */

             RMVM        FILE(LDR25B) MBR(&MEMBER)
             MONMSG      MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                               CPF7301 CPF7310)

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
