/*---------------------------------------------------------------------********/
/*  LOADCASADR: This CLP creates a report showing info related                */
/*              to Loader Case/Pieces Adjustment; This adjustments            */
/*              are created thru Pirloadr/Opt 6.                              */
/*                                                                            */
/*              This CLP is executed thru PIRLDRPT/Opt # 7.                   */
/*                                                                            */
/*  April 21, 2008                                                            */
/*  Jose Duque                                                                */
/*                                                                            */
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
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&POPT)       TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)



  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                        VALUE(LOADR41)

  /* Informational messages */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
             VALUE('   You are not authorized to use this option.')

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                        VALUE('Transactions lookup')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                        VALUE('Selecting records for display')

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&PGMID) VALUE(LOADCASADR)

             RTVJOBA    USER(&PUSR)

/*  Check if user is authorized to use this option */

             CALL       PGM(CHKLIST) PARM(&PGMID &POPT &PUSR &PRTN)

             IF         COND(&PRTN *EQ '*NO')  THEN(DO)

                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)

             RETURN
             ENDDO

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


/*-------------------------------------------------------------------*/
OPNQRY:      /* Collect total trans qty PICKED */

             CHGVAR     VAR(&FTIME) VALUE('180000')
             CHGVAR     VAR(&TTIME) VALUE('060000')

             CHGVAR     VAR(&QRYSLT) VALUE(' ')


/* From Date */
             CHGVAR     VAR(&QRYSLT) VALUE('LUWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LUSTD *GE     +
                             ' *CAT &FDATE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'LUSTD *LE     +
                             ' *CAT &TDATE)

/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'FLGTIM *GE' *BCAT &QUOTE *CAT &FTIME +
                           *CAT &QUOTE)                             */


/* To  Date */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')     */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'FLGWHS *EQ ' *CAT &WHSE)                */

/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'FLGDTE *GE    +
                             ' *CAT &FDATE)                         */

/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'FLGDTE *LE    +
                             ' *CAT &TDATE)                         */

/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')    */
/*           CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'FLGTIM *LE' *BCAT &QUOTE *CAT &TTIME +
                           *CAT &QUOTE)                             */



/* Use OPNQRYF to select and order the records we need */

             OVRDBF     FILE(LUPDLOG) SHARE(*YES)
             OPNQRYF    FILE((LUPDLOG)) OPTION(*ALL) QRYSLT(&QRYSLT) +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)
             CHGVAR     VAR(&FILNAM) VALUE('LU' || &TIME)

             CPYFRMQRYF FROMOPNID(LUPDLOG) TOFILE(QTEMP/&FILNAM) +
                        MBROPT(*ADD) CRTFILE(*YES)

             OVRDBF     FILE(LUPDLOG) TOFILE(QTEMP/&FILNAM)
             RUNQRY     QRY(PRTCASADJ) OUTTYPE(*RUNOPT) +
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
