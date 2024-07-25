/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADFLCL   Flag Status Summary (view flags by route).            */
/*  October 24, 2006                                                 */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/19/09  RBD  5.20                                            */
/*     - Removed hardcoding of whse, will use GETWHSE instead.       */
/*     - Removed hardcoding of start and end times, will use         */
/*       new pgm GETLOARNG instead to retrieve *LOADER options.      */
/*    05/01/13  LMC  6.50a                                           */
/*     - Qualified runner file to *libl in the runqry for            */
/*       Runnerb.                                                    */
/*                                                                   */
/*    03/31/17  MLB  7.10                                            */
/*     - Enh: Added client custom code support to pgm.               */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions: Cheney Pate Dawson                      */
/*                                                                   */
/*    03/28/17  CBI  MLB                                             */
/*      - xt . . .                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADFLCL:  PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (710 A) */

             DCL        VAR(&CHENEY) TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI A) */
             DCL        VAR(&CBIGO) TYPE(*CHAR) LEN(10) +
                          VALUE('GOLDSBORO ')                     /* (CBI A) */
             DCL        VAR(&CBIGR) TYPE(*CHAR) LEN(10) +
                          VALUE('GREENSBORO')                     /* (CBI A) */
             DCL        VAR(&CBIST) TYPE(*CHAR) LEN(10) +
                          VALUE('STATESVILL')                     /* (CBI A) */

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Cleared flags report')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Printing cleared flags report')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (710 A) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (710 A) */
             DCL        VAR(&CLOSED)     TYPE(*CHAR) LEN(1) VALUE('C')
             DCL        VAR(&DATE1)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE2)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&DELETED)    TYPE(*CHAR) LEN(1) VALUE('D')
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

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (710 A) */


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

/* Get unique member to use.                                                  */

             CALL       PGM(GETUNQMEM) PARM(*REUSE RUNCPY2 &MEMBER)

 REFRESH:
             RTVSYSVAL  SYSVAL(QDATE) RTNVAR(&QDATE)
             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&QTIME)
/* 520 D *** CHGVAR     VAR(&WHSE)    VALUE('001')                         ****/
             CHGVAR     VAR(&PLSMIN)  VALUE('P')

/* 520 D *** IF         COND(&QTIME *LT '160000') THEN(CHGVAR +
                        VAR(&PLSMIN) VALUE('M'))                          *****/
/* 520 M*/   IF         COND(&QTIME *GE '000001' *AND &QTIME *LE +
                        &TIME2) THEN(CHGVAR VAR(&PLSMIN) +
                        VALUE('M'))


/* Convert date to be used in OpnQry                                          */

             CALL       PGM(LOADRDTE) PARM(&QDATE &DATE1 &DATE2 &PLSMIN)

   /* Qry reads 'Runner' file, brakes down datestamp field into 2   +
      fields 'date' and 'time', writes record out. This new file is +
      a mirror image of 'Runner' file, and it is used by the OpnQry.*/

             SELECT                                               /* (CBI A) */
             WHEN       COND(&CLIENTLOC = &CBIGO) THEN(DO)        /* (CBI A) */
               RUNQRY     QRY(RUNNERBGO) QRYFILE((*LIBL/RUNNER *FIRST)) +
                            OUTFILE(RUNCPY2 &MEMBER)              /* (CBI A) */
             ENDDO                                                /* (CBI A) */

             WHEN       COND(&CLIENTLOC = &CBIGR) THEN(DO)        /* (CBI A) */
               RUNQRY     QRY(RUNNERBGR) QRYFILE((*LIBL/RUNNER *FIRST)) +
                            OUTFILE(RUNCPY2 &MEMBER)              /* (CBI A) */
             ENDDO                                                /* (CBI A) */

             WHEN       COND(&CLIENTLOC = &CBIST) THEN(DO)        /* (CBI A) */
               RUNQRY     QRY(RUNNERBST) QRYFILE((*LIBL/RUNNER *FIRST)) +
                            OUTFILE(RUNCPY2 &MEMBER)              /* (CBI A) */
             ENDDO                                                /* (CBI A) */

             OTHERWISE  CMD(DO)                                   /* (CBI A) */
             RUNQRY     QRY(RUNNERB) QRYFILE((*LIBL/RUNNER *FIRST)) +
                          OUTFILE(RUNCPY2 &MEMBER)       /* 650a */
             ENDDO                                                /* (CBI A) */
             ENDSELECT                                            /* (CBI A) */


   /* Create selection criteria string. */

/* 520 D *** CHGVAR     VAR(&TIME1) VALUE('160000')                       *****/

/* 520 D *** CHGVAR     VAR(&TIME2) VALUE('063000')                       *****/

             CHGVAR     VAR(&QRYSLT) VALUE('RUWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *NE' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *NE' *BCAT &QUOTE *CAT &DELETED +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTD *EQ' *BCAT &QUOTE *CAT &DATE1 +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTT *GE' *BCAT &QUOTE *CAT &TIME1 +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*OR')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUWHSE *EQ ' *CAT &WHSE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *NE' *BCAT &QUOTE *CAT &CLOSED +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUSTAT *NE' *BCAT &QUOTE *CAT &DELETED +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTD *EQ' *BCAT &QUOTE *CAT &DATE2 +
                           *CAT &QUOTE)

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                           'RUODTT *LE' *BCAT &QUOTE *CAT &TIME2 +
                           *CAT &QUOTE)


             OVRDBF     FILE(LDR371) TOFILE(RUNCPY2) MBR(&MEMBER) +
                          SHARE(*YES)

             OPNQRYF    FILE((RUNCPY2 &MEMBER) (LABEL) (RTEHED)     +
                          (PIRITEM) (PIRTRAN)) FORMAT(LDR371)       +
                          QRYSLT(&QRYSLT)                           +
                          KEYFLD((RTEHED/RHRTE) (RUNCPY2/RUWHDP)    +
                          (PIRITEM/ITITEM))                         +
                          JFLD((RUNCPY2/RULBL# LABEL/LBLBL#)        +
                          (LABEL/LBRTE RTEHED/RHRTID)               +
                          (LABEL/LBITEM PIRITEM/ITITEM)             +
                          (RUNCPY2/RUOTRN PIRTRAN/PTTRN#))          +
                          SEQONLY(*NO) OPTIMIZE(*FIRSTIO)


/*           CPYFRMQRYF FROMOPNID(RUNCPY2) TOFILE(JGDLIB/RUNCPY2) +
                        MBROPT(*REPLACE) CRTFILE(*NO)            */


             CALL       PGM(LOADR5) PARM(&WHSE &DATE1 &DATE2 &RETURN)
             IF         COND(&RETURN = '*REFRESH') THEN(DO)
             RCLRSC     LVL(*CALLER)
             GOTO       REFRESH
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

             RMVM       FILE(RUNCPY2) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310)

             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
