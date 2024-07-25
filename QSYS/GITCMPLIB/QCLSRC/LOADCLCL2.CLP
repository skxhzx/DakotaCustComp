/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADCLCL2: Loader Module - Previous Closed Routes Sumary -       */
/*             (Shows any loading night).                            */
/*                                                                   */
/*  January 10, 2007                                                 */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    05/19/09  RBD  5.20                                            */
/*     - Removed hardcoding of whse, will use GETWHSE instead.       */
/*     - Removed hardcoding of start and end times, will use         */
/*       new pgm GETLOARNG instead to retrieve *LOADER options.      */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    ##/##/##  CBI-XXX                                              */
/*      Text . . .                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADCLCL2:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Closed Routes Status Summary')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing Closed Routes Report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLOSED)     TYPE(*CHAR) LEN(1) VALUE('C')
             DCL        VAR(&DATE1)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE2)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&DELETED)    TYPE(*CHAR) LEN(1) VALUE('D')
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&TDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PLSMIN)     TYPE(*CHAR) LEN(1)
             DCL        VAR(&TIME1)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME2)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&QDATE)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&QTIME)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
/*520 A*/    DCL        VAR(&WHSNUM)     TYPE(*DEC) LEN(3 0)
/*520 A*/    DCL        VAR(&STIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&ETIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                        VALUE(LOADR18)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* 520 A   Get job information  */

             RTVJOBA    USER(&USER)

/* 520 A   Get user's warehouse information */

             CALL       PGM(GETWHSE) PARM(&USER &WHSNUM)
             CHGVAR     VAR(&WHSE)  VALUE(&WHSNUM)

/* 520 A   Get loader options, route loading start and end times */

             CALL       PGM(GETLOARNG) PARM(&WHSNUM &STIME &ETIME)
             CHGVAR     VAR(&TIME1)  VALUE(&STIME)
             CHGVAR     VAR(&TIME2)  VALUE(&ETIME)

             MSGBFC     MESSAGE('Selecting records')


/*  Get options. */

OPTNS:
             CALL       PGM(&OPTPGM) PARM(&FDATE &TDATE &RETURN)

/*  See if user wants to proceed. */

             IF         COND(&RETURN *EQ '*CANCEL' *OR &RETURN *EQ +
                       '*EXIT') THEN(DO)
             SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                        MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
             GOTO NOMSG
             ENDDO

 REFRESH:
/* 520 D *** CHGVAR     VAR(&WHSE)    VALUE('001')                          ***/


   /* Create selection criteria string. */

/* 520 D *** CHGVAR     VAR(&TIME1) VALUE('180000')                         ***/

/* 520 D *** CHGVAR     VAR(&TIME2) VALUE('063000')                         ***/

             CHGVAR     VAR(&QRYSLT) VALUE('LHHWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LHHSTD *EQ' *BCAT &QUOTE *CAT &FDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LHHSTT *GE' *BCAT &QUOTE *CAT &TIME1 +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LHHWHS *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LHHSTD *EQ' *BCAT &QUOTE *CAT &TDATE +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'LHHSTT *LE' *BCAT &QUOTE *CAT &TIME2 +
                           *CAT &QUOTE)

             OVRDBF     FILE(LDRHHDR) TOFILE(LDRHHDR) SHARE(*YES)

             OPNQRYF    FILE(LDRHHDR) QRYSLT(&QRYSLT) +
                          KEYFLD((LHHWHS) (LHHRTE) (LHHRTI)  +
                                 (LHHSTD) (LHHSTT))          +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)


             CALL       PGM(LOADR13B) PARM(&FDATE &TDATE +
                                          &TIME1 &TIME2 &RETURN)

             IF         COND(&RETURN = '*REFRESH') THEN(DO)
             RCLRSC     LVL(*CALLER)
             GOTO       REFRESH
             ENDDO
             IF         COND(&RETURN = '*CANCEL ') THEN(DO)
             RCLRSC     LVL(*CALLER)
             GOTO       OPTNS
             ENDDO

             GOTO       CMDLBL(NOMSG)


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

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
