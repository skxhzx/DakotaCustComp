/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RU120CL   Work With Runner Entries                               */
/*  06 May 2004                                                      */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    09/23/11  MLB  6.40                                            */
/*      - Enh: Added client custom code support to program.          */
/*                                                                   */
/*----------------------------------------------------------------   */
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    12/01/05  CBI-JGD                                              */
/*      Added definitions of new file and query to report on         */
/*      replenishments done within 15 minutes or greater from        */
/*      the time the replenishment was issued.                       */
/*                                                                   */
/*      NOTE: This CLP was copied from 'PIR' (existing copy          */
/*            only at this time).                                    */
/*                                                                   */
/*    05/03/06  CBIa-JGD                                             */
/*      Added new file (Workopt2) to be used by 'RU120' pgm.         */
/*      New info (flag delete reason code) needed to be added        */
/*      to the work file in order to be able to process this         */
/*      new info within this application. The new file is            */
/*      replacing , in RU120 only, existing 'WORKOPT' file.          */
/*    09/23/11  CBIb  MLB                                            */
/*      - Added client custom code for CBI to CBIa mod. File         */
/*        WORKOPT is needed for all other clients.                   */
/*    01/09/17  CBIc  MLB                                            */
/*      - Fix: Revised CBI mod to restore call to GETUNQMEM for file */
/*        WORKOPT.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RU120CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (640 A) */

             DCL        VAR(&CBI)     TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (CBI A) */

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(RU120)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&MEMBER)  TYPE(*CHAR) LEN(10)
/* CBI A */  DCL        VAR(&DEPT)    TYPE(*CHAR) LEN(5)
/* CBI A */  DCL        VAR(&FILNAM)  TYPE(*CHAR) LEN(8)
/* CBI A */  DCL        VAR(&FILNAM2) TYPE(*CHAR) LEN(8)
/* CBI A */  DCL        VAR(&TIME)    TYPE(*CHAR) LEN(6)
/* CBI A */  DCL        VAR(&QRYSLT)  TYPE(*CHAR) LEN(2000)
/* CBI A */  DCL        VAR(&QUOTE)   TYPE(*CHAR) LEN(1) VALUE('"')
/* CBI A */  DCL        VAR(&RETURN)  TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (640 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640 A) */


/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
               IF         COND(&CLIENT = &CBI) THEN(DO)           /* (CBIbA) */
/* CBIaM */     CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT2 &MEMBER)
/* CBIcA */     CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
               ENDDO                                              /* (CBIbA) */
               ELSE       CMD(DO)                                 /* (CBIbA) */
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
               ENDDO                                              /* (CBIbA) */
                ENDDO


/*  Create temporary files to hold replenishment information */

             IF         COND(&CLIENT = &CBI) THEN(DO)             /* (CBIbA) */
/* CBI A */  RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)
/* CBI A */  CHGVAR VAR(&FILNAM) VALUE('RE' || &TIME)

/* CBI A */  CRTPF      FILE(QTEMP/&FILNAM) SRCFILE(QDDSFILES) +
                        SRCMBR(FLGREPL) OPTION(*NOSOURCE +
                        *NOLIST) SIZE(*NOMAX)


/* CBI A */  RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)
/* CBI A */  CHGVAR VAR(&FILNAM2) VALUE('RP' || &TIME)

/* CBI A */  CRTPF      FILE(QTEMP/&FILNAM2) SRCFILE(QDDSFILES) +
                        SRCMBR(FLGREPL) OPTION(*NOSOURCE +
                        *NOLIST) SIZE(*NOMAX)
             ENDDO                                                /* (CBIbA) */


             IF         COND(&CLIENT = &CBI) THEN(DO)             /* (CBIbA) */
/* CBIaM */  OVRDBF     FILE(WORKOPT2) MBR(&MEMBER) SHARE(*YES)
             OVRDBF     FILE(WORKOPT)  MBR(&MEMBER) SHARE(*YES)   /* (CBIcA) */
             ENDDO                                                /* (CBIbA) */
             ELSE       CMD(DO)                                   /* (CBIbA) */
               OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)  /* (CBIbA) */
             ENDDO                                                /* (CBIbA) */

/*  On with the show ... */

/*  Load replenishment exceptions file     */

             IF         COND(&CLIENT = &CBI) THEN(DO)             /* (CBIbA) */
/* CBI A */  OVRDBF     FILE(FLGREPL) TOFILE(QTEMP/&FILNAM)
/* CBI A */  CALL       PGM(GETEXCPT)
             ENDDO                                                /* (CBIbA) */

/* CBI D     CALL       PGM(&PGM)                                  */
/* CBI M */  CALL       PGM(&PGM) PARM(&RETURN &DEPT)

/* CBI A */  IF         (&RETURN = '*F21') GOTO CMDLBL(PRINTRPT)
/* CBI A */              ELSE              GOTO CMDLBL(DONE)


/*  Create replenishments elapsed time report */

PRINTRPT:

/* CBI A */  /* Report on specific dept */

/* CBI A */  IF (&DEPT *NE '*ALL') THEN(DO)
/* CBI A */  CHGVAR     VAR(&QRYSLT) VALUE(' ')

/* CBI A */  CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'DEPT *EQ +
                        ' *BCAT &QUOTE *CAT &DEPT *CAT &QUOTE)

/* CBI A     CHGVAR     VAR(&QRYSLT) VALUE(&QRYSLT *BCAT 'USCREW *EQ +
                        ' *BCAT &QUOTE *CAT &PCREW *CAT &QUOTE) */


/* CBI A */  OVRDBF     FILE(&FILNAM) SHARE(*YES)
/* CBI A */  OPNQRYF    FILE((&FILNAM)) FORMAT(&FILNAM2)  +
                        QRYSLT(&QRYSLT)                   +
                        OPTIMIZE(*FIRSTIO) SEQONLY(*NO)

/* CBI A */  CPYFRMQRYF FROMOPNID(&FILNAM) TOFILE(QTEMP/&FILNAM2) +
                        MBROPT(*ADD)

/* CBI A */  RUNQRY     QRY(FLGREPL) +
                        QRYFILE((QTEMP/&FILNAM2)) PRTDEV(LP26)

/* CBI A */  GOTO DONE

/* CBI A */  ENDDO


/* CBI A */  /* Report on all depts */

/* CBI A */  RUNQRY     QRY(FLGREPL) +
                        QRYFILE(QTEMP/&FILNAM) PRTDEV(LP26)


/*  Clean up before leaving */

DONE:
             DLTOVR     FILE(WORKOPT)                             /* (CBIbA) */
             MONMSG     MSGID(CPF9841)                            /* (CBIbA) */
/* CBIaM */  DLTOVR     FILE(WORKOPT2)
             MONMSG     MSGID(CPF9841)
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (CBIbA) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (CBIbA) */
/* CBIaM */  RMVM       FILE(WORKOPT2) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF3203 CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)

             ENDPGM
