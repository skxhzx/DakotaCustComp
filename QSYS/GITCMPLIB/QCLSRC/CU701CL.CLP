/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CU701CL   Cleanup file members                                   */
/*  06 April 2010                                                    */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    04/06/10  GJA  5.30                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    01/06/12  MLB  6.40                                            */
/*      - Enh: Added client custom code support to program.          */
/*    01/06/12  MLB  6.40a                                           */
/*      - Fix: Revised pgm to use *PRV instead of *SAME for sending  */
/*        completion messages to CU700CL.                            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Glazier Foods                           */
/*                                                                   */
/*    01/06/12  MLB  GFC                                             */
/*      - Revised program to remove members from following files     */
/*        if the mbrs are older than 7 days.                         */
/*      - EXPFPOH, EXPFPOD, EXPFPOE.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cashwa                                  */
/*                                                                   */
/*    07/11/12  LMC  CWD                                             */
/*      - Revised program to remove members from the TOTEEXP file    */
/*        if the mbrs are older than 7 days.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Kohl Wholesale                          */
/*                                                                   */
/*    09/02/16  MLB  KHL                                             */
/*      - Revised program to remove members from the IMPFPCKQ file   */
/*        if the mbrs are older than 7 days.                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Holt Paper Co.                          */
/*                                                                   */
/*    07/03/20  MLB  HPC                                             */
/*      - Revised program to remove members from the IMPFPCKQ file   */
/*        if the mbrs are older than 14 days.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Seashore Fruit & Produce                */
/*                                                                   */
/*    10/08/20  MLB  SFP                                             */
/*      - Revised program to remove members from the import order    */
/*        files > 7 days old for: IMPFORDH8/D8/HM8/DM8.              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CU701CL:    PGM        PARM(&FILE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (640cA) */

             DCL        VAR(&GLAZIER) TYPE(*CHAR) LEN(10) +
                          VALUE('GLAZIER')                        /* (GFC A) */
             DCL        VAR(&CASHWA) TYPE(*CHAR) LEN(10) +
                          VALUE('CASHWA')                         /* (CWD  A) */
             DCL        VAR(&KOHL) TYPE(*CHAR) LEN(10) +
                          VALUE('KOHL')                           /* (KHL A) */
             DCL        VAR(&HOLTPAPER) TYPE(*CHAR) LEN(10) +
                          VALUE('HOLTPAPER ')                     /* (HPC A) */
             DCL        VAR(&SEASHORE) TYPE(*CHAR) LEN(10) +
                          VALUE('SEASHORE')                       /* (SFP A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640cA) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640cA) */
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATEIN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&DELPATH1)   TYPE(*CHAR) LEN(100)     /* (RFSaA) */
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TOMCAT)     TYPE(*CHAR) LEN(10)      /* (700aA) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&cutoff)     TYPE(*CHAR) LEN(7)       /* (GFC A) */
             DCL        VAR(&crtdate)    TYPE(*CHAR) LEN(7)       /* (GFC A) */
             DCL        VAR(&FILE)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&jobdate)    TYPE(*CHAR) LEN(7)       /* (GFC A) */
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&pcmd)       TYPE(*CHAR) LEN(8)       /* (GFC A) */
             DCL        VAR(&pDateIn)    TYPE(*dec)  LEN(8 0)     /* (GFC A) */
             DCL        VAR(&pDateOut)   TYPE(*dec)  LEN(8 0)     /* (GFC A) */
             DCL        VAR(&pDateOutA)  TYPE(*char) LEN(8)       /* (GFC A) */
             DCL        VAR(&pTimeIn)    TYPE(*dec)  LEN(6 0)     /* (GFC A) */
             DCL        VAR(&pTimeOut)   TYPE(*dec)  LEN(6 0)     /* (GFC A) */
             DCL        VAR(&pYears)     TYPE(*dec)  LEN(3 0)     /* (GFC A) */
             DCL        VAR(&pMonths)    TYPE(*dec)  LEN(3 0)     /* (GFC A) */
             DCL        VAR(&pDays)      TYPE(*dec)  LEN(3 0)     /* (GFC A) */
             DCL        VAR(&pHours)     TYPE(*dec)  LEN(3 0)     /* (GFC A) */
             DCL        VAR(&pMinutes)   TYPE(*dec)  LEN(3 0)     /* (GFC A) */
             DCL        VAR(&pSeconds)   TYPE(*dec)  LEN(3 0)     /* (GFC A) */
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&today)      TYPE(*CHAR) LEN(8)       /* (GFC A) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)

             DCLF       FILE(QAFDMBRL)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (640 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640 A) */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* See if we should put this on the JOBQ. */

/*           RTVJOBA    TYPE(&TYPE)                                  (640aD) */
             RTVJOBA    USER(&USER) TYPE(&TYPE)                   /* (640aM) */
             IF         COND(&TYPE = '1') THEN(DO)
             SBMJOB     CMD(CALL PGM(CU701CL) PARM(&FILE)) JOB(CU701CL)
             GOTO       CMDLBL(GETOUT)
             ENDDO

             CHGVAR     VAR(&MSG) VALUE('** Begin Member Cleanup: ' +
                          *CAT &FILE)
/*           SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)                      (640aD) */
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*PRV)                    /* (640aM) */
                                                                  /* (GFC A) */
 /*          IF         COND(&CLIENT = &GLAZIER) THEN(DO) */      /* (CWD D) */
             IF         COND(&CLIENT = &GLAZIER *OR +
                             &CLIENT = &KOHL *OR +
                             &CLIENT = &HOLTPAPER *OR +
                             &CLIENT = &SEASHORE *OR +
                             &CLIENT = &CASHWA) THEN(DO)          /* (SFP M) */
               RTVJOBA    CYMDDATE(&JOBDATE)                      /* (GFC A) */
               CVTDAT     DATE(&JOBDATE) TOVAR(&TODAY) FROMFMT(*CYMD) +
                            TOFMT(*YYMD) TOSEP(*NONE)             /* (GFC A) */
               CHGVAR     VAR(&PCMD) VALUE('*SUB')                /* (GFC A) */
               CHGVAR     VAR(&PDATEIN) VALUE(&TODAY)             /* (GFC A) */
               CHGVAR     VAR(&PDAYS) VALUE(7)                    /* (GFC A) */
               IF         COND(&CLIENT = &HOLTPAPER) THEN(DO)     /* (HPC A) */
                 CHGVAR     VAR(&PDAYS) VALUE(14)                 /* (HPC A) */
               ENDDO                                              /* (HPC A) */
               CALL       PGM(CLCDUR2) PARM(&PCMD &PDATEIN &PTIMEIN +
                            &PYEARS &PMONTHS &PDAYS &PHOURS &PMINUTES +
                            &PSECONDS &PDATEOUT &PTIMEOUT)        /* (GFC A) */
               CHGVAR     VAR(&PDATEOUTA) VALUE(&PDATEOUT)        /* (GFC A) */
               CVTDAT     DATE(&PDATEOUTA) TOVAR(&CUTOFF) FROMFMT(*YYMD) +
                            TOFMT(*CYMD) TOSEP(*NONE)             /* (GFC A) */
             ENDDO                                                /* (GFC A) */

/* Get a list of all the files in the library. */

             DSPFD      FILE(*LIBL/&FILE) TYPE(*MBRLIST) +
                          OUTPUT(*OUTFILE) OUTFILE(QTEMP/MBRLIST)

             OVRDBF     FILE(QAFDMBRL) TOFILE(QTEMP/MBRLIST)
             OPNDBF     FILE(QTEMP/MBRLIST) OPTION(*INP)
             RMVMSG     CLEAR(*ALL)

/* Whip through files reorganizing files with deleted records. */

 READ:       RCVF       RCDFMT(QWHFDML)
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(EOF))

             IF         COND(&MLNAME *NE &FILE) THEN(DO)
                                                                  /* (GFC A) */
             SELECT                                               /* (GFC A) */
             WHEN       COND(&CLIENT = &GLAZIER) THEN(DO)         /* (GFC A) */
               CHGVAR     VAR(&CRTDATE) VALUE(&mlccen *cat &mlcdat) /*(GFC A)*/
               IF         COND((&FILE = 'EXPFPOH' +
                            *or &FILE = 'EXPFPOD' +
                            *or &FILE = 'EXPFPOE') *AND +
                            (&CRTDATE >= &CUTOFF)) THEN(DO)       /* (GFC A) */
/*               Keep mbrs newer than 7 days.                     /* (GFC A) */
                 GOTO       CMDLBL(READ)                          /* (GFC A) */
               ENDDO                                              /* (GFC A) */
             ENDDO                                                /* (GFC A) */
             WHEN       COND(&CLIENT = &CASHWA) THEN(DO) /* (CWD A) */
             CHGVAR     VAR(&CRTDATE) VALUE(&MLCCEN *CAT &MLCDAT) +
                          /*(CWD A)*/
             IF         COND((&FILE = 'TOTEEXP') *AND (&CRTDATE >= +
                          &CUTOFF)) THEN(DO) /* (CWD A) */
/*               Keep mbrs newer than 7 days.                     /* (CWD A) */
                 GOTO       CMDLBL(READ)                          /* (CWD A) */
               ENDDO                                              /* (CWD A) */
             ENDDO                                                /* (CWD A) */

             WHEN       COND(&CLIENT = &KOHL) THEN(DO)            /* (KHL A) */

             CHGVAR     VAR(&CRTDATE) VALUE(&MLCCEN *CAT &MLCDAT) /*( KHL A) */
             IF         COND((&FILE = 'IMPFPCKQ') *AND (&CRTDATE >= +
                          &CUTOFF)) THEN(DO)                      /* (KHL A) */
/*               Keep mbrs newer than 7 days.                     /* (KHL A) */
                 GOTO       CMDLBL(READ)                          /* (KHL A) */
               ENDDO                                              /* (KHL A) */
             ENDDO                                                /* (KHL A) */

             WHEN       COND(&CLIENT = &SEASHORE) THEN(DO)        /* (SFP A) */

             CHGVAR     VAR(&CRTDATE) VALUE(&MLCCEN *CAT &MLCDAT) /*( SFP A) */
             IF         COND((&FILE = 'IMPFORDH8' +
                          *OR &FILE = 'IMPFORDD8' +
                          *OR &FILE = 'IMPFORDHM8' +
                          *OR &FILE = 'IMPFORDDM8') +
                          *AND (&CRTDATE >= &CUTOFF)) THEN(DO)    /* (SFP A) */
/*               Keep mbrs newer than 7 days.                     /* (SFP A) */
                 GOTO       CMDLBL(READ)                          /* (SFP A) */
               ENDDO                                              /* (SFP A) */
             ENDDO                                                /* (SFP A) */

             ENDSELECT                                            /* (GFC A) */

/*  Remove file members */

             RMVM       FILE(*LIBL/&FILE) MBR(&MLNAME)
             MONMSG     MSGID(CPF32CF CPF32C3 CPF320A CPF3203 +
                          CPF3220 CPF3273 CPF7301 CPF7303 CPF7310)

             ENDDO

             GOTO READ
 EOF:        CHGVAR     VAR(&MSG) VALUE('End Member Cleanup: ' *CAT +
                          &FILE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CLOF       OPNID(MBRLIST)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
