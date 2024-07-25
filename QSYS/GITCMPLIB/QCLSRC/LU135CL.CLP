/*---------------------------------------------------------------------********/
/*  LU135CL: This CLP creates a report showing info related to flag           */
/*           records deleted thru menu; PIRFLG/Opt# 2.                        */
/*                                                                            */
/*           This report is created by PIRFLG/Opt# 8 and                      */
/*           PIRLDRPT/Opt# 5.                                                 */
/*                                                                            */
/*  April 26, 2006                                                            */
/*  Jose Duque                                                                */
/*                                                                            */
/*  Revisions                                                        */
/*                                                                   */
/*    06/26/09  RBD  5.20                                            */
/*     - Added GETWHSE for retrieval of *LOADER options.             */
/*     - Removed hardcoding of start and end times, will use         */
/*       new pgm GETLOARNG instead to retrieve *LOADER options.      */
/*                                                                   */
/*---------------------------------------------------------------------********/

             PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILEKY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&FILNAM)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FTIME)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PICK)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TIME)       TYPE(*CHAR) LEN(6)
             DCL        VAR(&TTIME)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&VCPCK)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&NVPCK)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PRCNT)      TYPE(*CHAR) LEN(4)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                        VALUE(LU137)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                        VALUE('Transactions lookup')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                        VALUE('Selecting records for display')

/*520 A*/    DCL        VAR(&WHSNUM)     TYPE(*DEC) LEN(3 0)
/*520 A*/    DCL        VAR(&STIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&ETIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*  Get options. */

OPTNS:
             CALL       PGM(&OPTPGM) PARM(&WHSE &FDATE &TDATE +
                                          &RETURN &DEV)


/*  See if user wants to proceed. */

             IF         COND(&RETURN *EQ '*CANCEL' *OR &RETURN *EQ +
                       '*EXIT') THEN(DO)
             SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                        MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
             GOTO OUT
             ENDDO

/* 520 A   Get job information  */

             RTVJOBA    USER(&USER)

/* 520 A   Get user's warehouse information */

             CALL       PGM(GETWHSE) PARM(&USER &WHSNUM)

/* 520 A   Get loader options, route loading start and end times */

             CALL       PGM(GETLOARNG) PARM(&WHSNUM &STIME &ETIME)
             CHGVAR     VAR(&FTIME)  VALUE(&STIME)
             CHGVAR     VAR(&TTIME)  VALUE(&ETIME)


/*-------------------------------------------------------------------*/
OPNQRY:      /* Collect total trans qty PICKED */

/* 520 D *** CHGVAR     VAR(&FTIME) VALUE('180000')                  */
/* 520 D *** CHGVAR     VAR(&TTIME) VALUE('060000')                  */

             CHGVAR     VAR(&QRYSLT) VALUE(' ')


/* From Date */
             CHGVAR     VAR(&QRYSLT) VALUE('FLGWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'FLGDTE *GE    +
                             ' *CAT &FDATE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'FLGDTE *LE    +
                             ' *CAT &TDATE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'FLGTIM *GE' *BCAT &QUOTE *CAT &FTIME +
                           *CAT &QUOTE)


/* To  Date */
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'FLGWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'FLGDTE *GE    +
                             ' *CAT &FDATE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'FLGDTE *LE    +
                             ' *CAT &TDATE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'FLGTIM *LE' *BCAT &QUOTE *CAT &TTIME +
                           *CAT &QUOTE)



/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(FLGDELF) SHARE(*YES)
             OPNQRYF    FILE((FLGDELF)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)
             CHGVAR     VAR(&FILNAM) VALUE('LU' || &TIME)

             CPYFRMQRYF FROMOPNID(FLGDELF) TOFILE(QTEMP/&FILNAM) +
                        MBROPT(*ADD) CRTFILE(*YES)

             OVRDBF     FILE(FLGDELF) TOFILE(QTEMP/&FILNAM)
             RUNQRY     QRY(PRTDELFLG) OUTTYPE(*RUNOPT) +
                        PRTDEV(&DEV)

             GOTO       CMDLBL(OUT)



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
 OUT:
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)
             DLTOVR     FILE(*ALL)


             ENDPGM
