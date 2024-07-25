/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OR605CL   Truck Build - Traffic Cop                              */
/*  24 July 2002                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    07/24/02  MLB  4.16                                            */
/*      - Created.                                                   */
/*        This program allows the Truck Build portions of            */
/*        allocate/build, pick/print to be processed in batch.       */
/*                                                                   */
/*    09/27/10  MLB  5.30                                            */
/*      - Enh: Revised program to submit *ALOCBLD jobs to            */
/*        jobq BFCJOBQ and submit *PCKPRNT to BFCJOBQPK. Splitting   */
/*        allocate/build, pick/print processes to improve throughput.*/
/*                                                                   */
/*    01/22/12  MLB  6.40                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*    12/30/17  DAs  7.10a                                           */
/*      - Enh: Added logging.                                        */
/*      - Originally done by Jeff for USF 4/1/13 650a                */
/*                                                                   */
/*    11/22/19  MLB  7.30                                            */
/*      - Enh: Revised p0gm to retrieve PIRINIT *dtaara              */
/*        for use with creating client specific jobq's.              */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    02/25/04  MLB  CBI                                             */
/*      - Changed to submit to BFCJOBQ instead of QBATCH. BFCJOBQ    */
/*        is a "single-thread' jobq.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    01/22/12  MLB  SGC                                             */
/*      - Revised pgm to send Pick/Print jobs to jobq BFCJOBQ        */
/*        instead of BFCJOBQPK. Was done to ease processing load     */
/*        on CPU from having maximum of 3 jobs running in QBATCH     */
/*        at the same time.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    11/26/13  MLB  RFS                                             */
/*      - Revised pgm to send Pick/Print jobs to jobq BFCALCwww or   */
/*        BFCPCKwww where w=Branch warehouse number.  This is being  */
/*        done so that errors for one branch won't affect the other  */
/*        branch warehouses TruckBuilder processing.                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    04/13/17  MLB  DRY                                             */
/*      - Revised pgm to send Pick/Print jobs to jobq BFCALCwww or   */
/*        BFCPCKwww where w=Branch warehouse number.  This is being  */
/*        done so that errors for one branch won't affect the other  */
/*        branch warehouses TruckBuilder processing.                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    04/29/19  MLB  PFG                                             */
/*      - Revised pgm to send Pick/Print jobs to jobq BFCALCBwww or  */
/*        BFCPCKBwww where w=Branch warehouse number.  This is being */
/*        done so that errors for one branch won't affect the other  */
/*        branch warehouses TruckBuilder processing.                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*    11/22/19  MLB  SRV01                                           */
/*      - Revised pgm to send Pick/Print jobs to jobq ALCiiiwww or   */
/*        PCKiiiwww where i=client initials and w=client whse nbr.   */
/*        This was done to separate each client's jobs from other    */
/*        clients. Mod coded for variable, CLOUDSITE = *YES.         */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OR605CL:    PGM        PARM(&PCMD &PCMD2 &PTYPE &PJTYP &PWHS &PBAT +
                          &PSTAT &PRTID &PORD &PRWHS &PTRTE &PRTN +
                          &PMSG &PPRG)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (640 A) */

             DCL        VAR(&SGC) TYPE(*CHAR) LEN(10) +
                          VALUE('SGC')                            /* (SGC A) */
             DCL        VAR(&RFS) TYPE(*CHAR) LEN(10) +
                          VALUE('RFS')                            /* (RFS A) */
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */
             DCL        VAR(&PFG) TYPE(*CHAR) LEN(10) +
                          VALUE('PFG')                            /* (PFG A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&clientinit) TYPE(*CHAR) LEN(10)      /* (730 A) */
             DCL        VAR(&cloudsite)  TYPE(*CHAR) LEN(4)       /* (730 A) */
             DCL        VAR(&EXIST)      TYPE(*LGL)               /* (RFS A) */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)

             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&PCMD)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PCMD2)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PTYPE)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&PJTYP)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PWHS)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&PWHSE3)     TYPE(*DEC)  LEN(3 0)     /* (RFS A) */
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)       /* (RFS A) */
             DCL        VAR(&PBAT)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&PSTAT)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PORD)       TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&PRWHS)      TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&PTRTE)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PMSG)       TYPE(*CHAR) LEN(4)
             DCL        VAR(&PPRG)       TYPE(*CHAR) LEN(10)

/*710aA*/    DCL        VAR(&TMSTMP)     TYPE(*CHAR) LEN(26)
/*710aA*/    DCL        VAR(&WHSE3)      TYPE(*DEC)  LEN(3 0)
/*710aA*/    DCL        VAR(&PGM)        TYPE(*CHAR) LEN(9) VALUE(WRTRTELOG)
/*710aA*/    DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)
/*710aA*/    DCL        VAR(&GRPID)      TYPE(*DEC)  LEN(7 0)
/*710aA*/    DCL        VAR(&GRPCODE)    TYPE(*CHAR) LEN(10)
/*710aA*/    DCL        VAR(&SUBGRP)     TYPE(*CHAR) LEN(12)
/*710aA*/    DCL        VAR(&LTYPE)      TYPE(*CHAR) LEN(1)
/*710aA*/    DCL        VAR(&CURUSR)     TYPE(*CHAR) LEN(10)
/*710aA*/    DCL        VAR(&PGM2)       TYPE(*CHAR) LEN(10)
/*710aA*/    DCL        VAR(&JOBQTS)     TYPE(*CHAR) LEN(26)
/*710aA*/    DCL        VAR(&JOBQUC)     TYPE(*CHAR) LEN(26)

  /* Informational message. */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE(' ')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE(' ')

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)

/* Get Client ID */                                               /* (640 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640 A) */

             CHGVAR     VAR(&CLOUDSITE) VALUE('*YES')             /* (730 A) */
             RTVDTAARA  DTAARA(PIRINIT *ALL) RTNVAR(&CLIENTINIT)  /* (730 A) */
             MONMSG     MSGID(CPF1015 CPF1063 CPF1067 CPF9899) EXEC(DO)
               CHGVAR     VAR(&CLIENTINIT) VALUE('XXX')           /* (730 A) */
             ENDDO                                                /* (730 A) */

             IF (&TYPE = '0') THEN(GOTO REPORT)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             SELECT                                               /* (530 A) */
             WHEN       COND(&PCMD2 = '*PCKPRNT') THEN(DO)        /* (530 A) */
               select                                             /* (RFS A) */
               when       COND(&CLIENT = &SGC) THEN(DO)           /* (RFS M) */
                 CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQ')           /* (SGC A) */
               enddo                                              /* (SGC A) */

               when       COND(&CLIENT = &RFS +
                           *or &CLIENT = &DAIRYLAND) THEN(DO)     /* (DRY M) */
                 CHGVAR     VAR(&PWHSE3) VALUE(&PWHS)             /* (RFS A) */
                 CHGVAR     VAR(&PWHSE) VALUE(&PWHSE3)            /* (RFS A) */
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (RFS A) */
                 CHGVAR     VAR(&JOBQ) VALUE('BFCPCK' *CAT &PWHSE) /*(RFS A) */
                 CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)             /* (RFS A) */
                 MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                              VALUE('0')) /* Jobq not found.         (RFS A) */
                   IF         COND(*NOT &EXIST) THEN(DO)          /* (RFS A) */
                     CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQPK')     /* (RFS A) */
                   ENDDO                                          /* (RFS A) */
               enddo                                              /* (SGC A) */

               when       COND(&CLIENT = &PFG) THEN(DO)           /* (PFG A) */
                 CHGVAR     VAR(&PWHSE3) VALUE(&PWHS)             /* (PFG A) */
                 CHGVAR     VAR(&PWHSE) VALUE(&PWHSE3)            /* (PFG A) */
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (PFG A) */
                 CHGVAR     VAR(&JOBQ) VALUE('BFCPCKB' *CAT &PWHSE) /*(PFG A)*/
                 CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)             /* (PFG A) */
                 MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                              VALUE('0')) /* Jobq not found.         (PFG A) */
                   IF         COND(*NOT &EXIST) THEN(DO)          /* (PFG A) */
                     CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQPK')     /* (PFG A) */
                   ENDDO                                          /* (PFG A) */
               enddo                                              /* (PFG A) */

               when       COND(&CLOUDSITE = '*YES') THEN(DO)      /* (SRV01A)*/
                 CHGVAR     VAR(&PWHSE3) VALUE(&PWHS)             /* (SRV01A)*/
                 CHGVAR     VAR(&PWHSE) VALUE(&PWHSE3)            /* (SRV01A)*/
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (SRV01A)*/
                 CHGVAR     VAR(&JOBQ) VALUE('PCK' *TCAT &CLIENTINIT +
                              *TCAT &PWHSE)                       /* (SRV01A)*/
                 CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)             /* (SRV01A)*/
                 MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                              VALUE('0')) /* Jobq not found.         (SRV01A)*/
                   IF         COND(*NOT &EXIST) THEN(DO)          /* (SRV01A)*/
                     CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQPK')     /* (SRV01A)*/
                   ENDDO                                          /* (SRV01A)*/
               enddo                                              /* (SRV01A)*/

               OTHERWISE  CMD(DO)                                 /* (RFS M) */
               CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQPK')           /* (530 A) */
               enddo                                              /* (SGC A) */
               endselect                                          /* (RFS A) */
             enddo                                                /* (530 A) */
                                                                  /* (RFS A) */
             OTHERWISE  CMD(DO)

               select                                             /* (RFS A) */
               when       COND(&CLIENT = &RFS +
                           *or &CLIENT = &DAIRYLAND) THEN(DO)     /* (DRY M) */
                 CHGVAR     VAR(&PWHSE3) VALUE(&PWHS)             /* (RFS A) */
                 CHGVAR     VAR(&PWHSE) VALUE(&PWHSE3)            /* (RFS A) */
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (RFS A) */
                 CHGVAR     VAR(&JOBQ) VALUE('BFCALC' *CAT &PWHSE) /*(RFS A) */
                 CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)             /* (RFS A) */
                 MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                              VALUE('0')) /* Jobq not found.         (RFS A) */
                   IF         COND(*NOT &EXIST) THEN(DO)          /* (RFS A) */
                     CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQ')       /* (RFS A) */
                   ENDDO                                          /* (RFS A) */
               enddo                                              /* (RFS A) */

               when       COND(&CLIENT = &PFG) THEN(DO)           /* (PFG A) */
                 CHGVAR     VAR(&PWHSE3) VALUE(&PWHS)             /* (PFG A) */
                 CHGVAR     VAR(&PWHSE) VALUE(&PWHSE3)            /* (PFG A) */
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (PFG A) */
                 CHGVAR     VAR(&JOBQ) VALUE('BFCALCB' *CAT &PWHSE) /*(PFG A)*/
                 CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)             /* (PFG A) */
                 MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                              VALUE('0')) /* Jobq not found.         (PFG A) */
                   IF         COND(*NOT &EXIST) THEN(DO)          /* (PFG A) */
                     CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQ')       /* (PFG A) */
                   ENDDO                                          /* (PFG A) */
               enddo                                              /* (PFG A) */

               when       COND(&CLOUDSITE = '*YES') THEN(DO)      /* (SRV01A)*/
                 CHGVAR     VAR(&PWHSE3) VALUE(&PWHS)             /* (SRV01A)*/
                 CHGVAR     VAR(&PWHSE) VALUE(&PWHSE3)            /* (SRV01A)*/
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (SRV01A)*/
                 CHGVAR     VAR(&JOBQ) VALUE('ALC' *TCAT &CLIENTINIT +
                              *TCAT &PWHSE)                       /* (SRV01A)*/
                 CHKOBJ     OBJ(&JOBQ) OBJTYPE(*JOBQ)             /* (SRV01A)*/
                 MONMSG     MSGID(CPF9801) EXEC(CHGVAR VAR(&EXIST) +
                              VALUE('0')) /* Jobq not found.         (SRV01A)*/
                   IF         COND(*NOT &EXIST) THEN(DO)          /* (SRV01A)*/
                     CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQPK')     /* (SRV01A)*/
                   ENDDO                                          /* (SRV01A)*/
               enddo                                              /* (SRV01A)*/

               OTHERWISE  CMD(DO)                                 /* (RFS M) */
               CHGVAR     VAR(&JOBQ) VALUE('BFCJOBQ')             /* (530 A) */
             enddo                                                /* (530 A) */
             endselect                                            /* (RFS A) */
             enddo                                                /* (RFS A) */
             endselect                                            /* (530 A) */

/*710aA*/    CHGVAR     VAR(&WHSE3)   VALUE(&PWHS)
/*710aA*/    CHGVAR     VAR(&GRPCODE) VALUE(&PCMD2)
/*710aA*/    CHGVAR     VAR(&SUBGRP)  VALUE('JQ' *TCAT &JOBQ)
/*710aA*/    CHGVAR     VAR(&LTYPE)   VALUE('1')
/*710aA*/    CHGVAR     VAR(&GRPID)   VALUE(0)
/*710aA*/    CHGVAR     VAR(&PGM2)    VALUE('OR605CL')

/*710aA*/    CALL       PGM(&PGM) PARM(&WHSE3 &PRTID &TMSTMP &GRPID +
                          &GRPCODE &SUBGRP &LTYPE &CURUSR &PGM2 +
                          &JOBQTS &JOBQUC)
                                                                  /* (530 A) */
             SBMJOB     CMD(OR605 PCMD(&PCMD) PCMD2(&PCMD2) +
                          PTYPE(&PTYPE) PJTYP(&PJTYP) PWHS(&PWHS) +
                          PBAT(&PBAT) PSTAT(&PSTAT) PRTID(&PRTID) +
                          PORD(&PORD) PRWHS(&PRWHS) PTRTE(&PTRTE) +
                          PRTN(&PRTN) PMSG(&PMSG) PPRG(&PPRG)) +
                          JOB(OR605CL) JOBQ(&JOBQ)                /* (530 M) */
             GOTO       CMDLBL(GETOUT)

/*  Otherwise, run program. */

 REPORT:

             CALL       PGM(OR605) PARM(&PCMD &PCMD2 &PTYPE &PJTYP +
                          &PWHS &PBAT &PSTAT &PRTID &PORD &PRWHS +
                          &PTRTE &PRTN &PMSG &PPRG)
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

             RCLRSC     LVL(*CALLER)

             ENDPGM
