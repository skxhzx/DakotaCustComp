/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADHCL   Route Status History audit View/Print.                 */
/*            Executed from Menu: Pirldrpt/Opt # 1.                  */
/*                                                                   */
/*  October 31, 2006                                                 */
/*                                                                   */
/*  Jose Duque                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/20/09  RBD  5.20                                            */
/*     - Removed hardcoding of start and end times, will use         */
/*       new pgm GETLOARNG instead to retrieve *LOADER options.      */
/*                                                                   */
/*    11/20/09  RBD  5.30                                            */
/*     - Fix:  Deleted first call to GETLOARNG, should not have      */
/*       been called twice, was causing pgm to fail.                 */
/*     - Fix:  Removed PIRF library reference.                       */
/*     - Fix:  Use RTVJOBA to get prtdev for runqry if *JOB          */
/*       is returned in LOADR7, as *JOB is considered invalid        */
/*       by runqry.                                                  */
/*                                                                   */
/*    03/13/13  MLB  6.50                                            */
/*     - Fix: Revised pgm to add &quote around route number value    */
/*       entered.  Route number was being treated as numeric value   */
/*       when it is alpha in LDRHDR file. Was causing CPF5033 error  */
/*       in pgm LOADR8B.                                             */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    MM/DD/YY  CBI-XXX                                              */
/*      Text.....................                                    */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADHCL:    PGM        PARM(&WHSE &FDATE &TDATE &FDTE6 &TDTE6 +
                             &RETURN &VP &JOBQ &DEV &FORM &RTE# +
                             &SORT)

/*-----------------------*/
/* Constant declarations */
/*-----------------------*/
  /* Name of this program */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADHCL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(LOADR7)


             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(LDRHHDR)


/*------------------------*/
/* Informational messages */
/*------------------------*/
             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Route Status History Audit')

             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                            VALUE('Printing ''Route Status History Audit')

/*--------------------*/
/* Field declarations */
/*--------------------*/
             DCL        VAR(&DEV)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&FDATE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&FDTE6)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&FILNAM)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER2)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER3)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER4)    TYPE(*CHAR) LEN(10)
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
             DCL        VAR(&TIME1)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIME2)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&VP)         TYPE(*CHAR) LEN(1)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)
/*520 A*/    DCL        VAR(&WHSNUM)     TYPE(*DEC) LEN(3 0)
/*520 A*/    DCL        VAR(&STIME)      TYPE(*DEC) LEN(6 0)
/*520 A*/    DCL        VAR(&ETIME)      TYPE(*DEC) LEN(6 0)
/*530 A*/    DCL        VAR(&PRTDEV)     TYPE(*CHAR) LEN(10)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(NOMSG2))

/*------------*/
/*  Main line */

/*------------*/
 OPTNS:

/*-------------------------------------------*/
/* Don't get options if being run from JOBQ. */
/*-------------------------------------------*/
             RTVJOBA    TYPE(&TYPE) PRTDEV(&PRTDEV) /*530 M*/
             IF (&TYPE = '0') THEN(GOTO REPORT)

/*---------------------*/
/* Get report options. */
/*---------------------*/
             CALL       PGM(&OPTPGM) PARM(&WHSE &FDATE &TDATE &FDTE6 +
                          &TDTE6 &RETURN &VP &JOBQ &DEV &FORM &RTE# +
                          &SORT)

/*530 A*/    IF (&DEV = '*JOB') THEN(DO)
/*530 A*/    CHGVAR     VAR(&DEV)  VALUE(&PRTDEV)
/*530 A*/    ENDDO

/*--------------------------------*/
/*  See if user wants to proceed. */
/*--------------------------------*/
             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

/* 520 A   Get loader options, route loading start and end times */
/* 520 A   using whse entered in options pgm.                    */

             CHGVAR     VAR(&WHSNUM)  VALUE(&WHSE)
             CALL       PGM(GETLOARNG) PARM(&WHSNUM &STIME &ETIME)
             CHGVAR     VAR(&TIME1)  VALUE(&STIME)
             CHGVAR     VAR(&TIME2)  VALUE(&ETIME)

/*------------------------------------------*/
/* See if user wants to put report on JOBQ. */
/*------------------------------------------*/
             IF (&JOBQ = 'Y') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&WHSE &FDATE +
                          &TDATE &FDTE6 &TDTE6 &RETURN &VP &JOBQ +
                          &DEV &FORM &RTE# &SORT)) JOB(&SBMPGM) +
                          JOBQ(QGPL/QS36EVOKE)
              GOTO      CMDLBL(NOMSG2)
             ENDDO

/*-------------------------*/
/* Otherwise, run program. */
/*-------------------------*/
 REPORT:

             MSGBFC     MESSAGE('Selecting records')

/*-----------------------------------*/
/* Create selection criteria string. */
/*-----------------------------------*/
SELECT:
             CHGVAR     VAR(&QRYSLT) VALUE('LHHWHS *EQ ' *CAT &WHSE)

             IF         COND(&RTE# *NE *ALL)                       +
             THEN(DO)
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')
             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT ('LHHRTE  +
                        *EQ ' *CAT &Quote *cat &RTE# *cat &quote)) /* (650 M)*/
/*                      *EQ ' *CAT &RTE#))                        /* (650 D) */
             ENDDO

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT '*AND')

             CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT +
                         '((LHHSTD *EQ %RANGE('  *CAT &FDATE +
                         *BCAT &TDATE *CAT ')))')

             OVRDBF     FILE(&FILE) TOFILE(&FILE) SHARE(*YES)
             OPNQRYF    FILE((&FILE)) QRYSLT(&QRYSLT) +
                        SEQONLY(*NO) OPTIMIZE(*FIRSTIO)

             CALL       PGM(GETUNQMEM) PARM(*REUSE RTESUMMH &MEMBER)
             CALL       PGM(GETUNQMEM) PARM(*REUSE RTES3F   &MEMBER2)
             CALL       PGM(GETUNQMEM) PARM(*REUSE RTES5F   &MEMBER3)
             CALL       PGM(GETUNQMEM) PARM(*REUSE RTES6F   &MEMBER4)


/*----------------------*/
/* Create RTESUMMH file */
/*----------------------*/
             OVRDBF     FILE(RTESUMMH) MBR(&MEMBER)
             CALL       PGM(LOADR8B) PARM(&FDATE &TDATE)


/*-----------------------*/
/* If viewing the report */
/*-----------------------*/
             IF         COND(&VP *EQ 'V') THEN(DO)

             CALL       PGM(LOADR8) PARM(&FDTE6 &TDTE6 &RETURN)

             IF (&RETURN = '*CANCEL') THEN(DO)
             CHGVAR     VAR(&RETURN)  VALUE('       ')
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(RTESUMMH) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)
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

/*-------------------------------------------*/
/*  Report by Route                          */
/*-------------------------------------------*/
             IF (&SORT = '1') THEN(DO)
             OVRDBF     FILE(RTESUMMH) MBR(&MEMBER)
             RUNQRY     QRY(RTESUMM) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)
             ENDDO


/*--------------------------------------------*/
/* Report by Loader                           */
/*--------------------------------------------*/
             IF (&SORT = '2') THEN(DO)
             OVRDBF     FILE(RTESUMMH) MBR(&MEMBER)
             RUNQRY     QRY(RTESUMM2) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)
                            GOTO CMDLBL(NOMSG)
             ENDDO


/*--------------------------------------------------------*/
/*  Report by Loader-Pallet Dtl                           */
/*--------------------------------------------------------*/
             IF (&SORT = '3') THEN(DO)
             OVRDBF     FILE(RTESUMMH) MBR(&MEMBER)
/* 530 D *** RUNQRY     QRY(RTESUMM3) OUTFILE(PIRF/RTES3F +    */
/* 530 M */  RUNQRY     QRY(RTESUMM3) OUTFILE(RTES3F +
                                                        &MEMBER2)

             OVRDBF     FILE(RTES3F) MBR(&MEMBER2)
             RUNQRY     QRY(RTESUMM4) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)

                            GOTO CMDLBL(NOMSG)
             ENDDO


/*-------------------------------------------------------------*/
/*  Report by Loader-Route-Load-Summ                           */
/*-------------------------------------------------------------*/
/* 520 D *** CHGVAR     VAR(&TIME1) VALUE('180000')                         ***/
/* 520 D *** CHGVAR     VAR(&TIME2) VALUE('063000')                         ***/

/*--------------------*/
/* Create RTES3F file */
/*--------------------*/
             OVRDBF     FILE(RTESUMMH) MBR(&MEMBER)
             OVRDBF     FILE(RTES3F) MBR(&MEMBER2)
             CALL       PGM(LOADR8H) PARM(&FDATE &TDATE &TIME1 &TIME2)


             OVRDBF     FILE(RTES3F) MBR(&MEMBER2)
/* 530 D *** RUNQRY     QRY(RTESUMM5) OUTFILE(PIRF/RTES5F +    */
/* 530 M */  RUNQRY     QRY(RTESUMM5) OUTFILE(RTES5F +
                                                        &MEMBER3)

             OVRDBF     FILE(RTES5F) MBR(&MEMBER3)
/* 530 D *** RUNQRY     QRY(RTESUMM6) OUTFILE(PIRF/RTES6F +    */
/* 530 M */  RUNQRY     QRY(RTESUMM6) OUTFILE(RTES6F +
                          &MEMBER4)

             OVRDBF     FILE(RTES6F) MBR(&MEMBER4)
             CALL       PGM(LOADR8C)

             RUNQRY     QRY(RTESUMM7) OUTTYPE(*RUNOPT) +
                          PRTDEV(&DEV) FORMTYPE(&FORM)

                            GOTO CMDLBL(NOMSG)

/*-----------------------------------------*/
/*  Receive any messages and pass them on  */
/*-----------------------------------------*/
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

/*--------------------------*/
/*  Clean up before leaving */
/*--------------------------*/

             RMVM       FILE(RTESUMMH) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             RMVM       FILE(RTES3F)   MBR(&MEMBER2)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             RMVM       FILE(RTES5F)   MBR(&MEMBER3)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

             RMVM       FILE(RTES6F)   MBR(&MEMBER4)
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                              CPF7301 CPF7310)

 NOMSG2:
             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)
             DLTOVR     FILE(*ALL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
