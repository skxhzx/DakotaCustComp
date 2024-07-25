/*-----------------------------------------------------------------*/
/*                                                                 */
/*  Copyright (C) 1999 BFC Software, Inc.- All rights reserved     */
/*  BFC Software, Inc.                                             */
/*  799 Roosevelt Rd.  Bldg 6, Suite 108                           */
/*  Glen Ellyn, IL  60137                                          */
/*  (708) 790-8383                                                 */
/*                                                                 */
/*-------------------------------------------------------------------*/
/*                                                                 */
/*  FTPLIBL  Setup FTP Library List                                */
/*  02 March 1999                                                  */
/*  Dave Sommerville                                               */
/*                                                                 */
/*-------------------------------------------------------------------*/
/*  07/20/99  DAS  4.12                                            */
/*    - Removed all FTP libraries.                                 */
/*                                                                 */
/*  09/22/99  DAS  4.12a                                           */
/*    - Uncommented PIRTESTF library.                              */
/*                                                                 */
/*  05/02/03  HNK  4.17                                            */
/*    - Add PIRTEMP library to test environment.                   */
/*                                                                 */
/*  01/24/11  MLB  6.40                                            */
/*    - Enh: Added 2 new base cmds, *PRDN, *TSTN for use with      */
/*      new install libraries during initial testing/setup.        */
/*  03/07/12  MLB  6.40a                                           */
/*    - Enh: Added new cmds, *MLTP, *MLTT to allow multiple        */
/*      warehouses to be imported in the same batch.               */
/*  08/16/18  RTR  7.20a                                           */
/*    - Fix: Change incoming TYPE to uppercase, prevents list      */
/*      not being set due to host using lowercase.                 */
/*                                                                 */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Cash WA Distributing                     */
/*                                                                   */
/*  01/29/09  MLB  CWD                                               */
/*    - Created 6 new parms for Aberdeen, Kearney locations.         */
/*      *PRD1, *PRD2, *PRD3, *TST1, *TST2 and *TST3.                 */
/*  07/10/18  MLB  CWDa                                              */
/*    - Revised pgm to add library BFCGLO710F to library list for:   */
/*      *PRD1, *PRD2, *PRD3, *TST1, *TST2 and *TST3.                 */
/*  08/01/18  MLB  CWDb                                              */
/*    - Revised pgm to add libs CWDSQL,CWDSQLPGM to library list for:*/
/*      *PRD1, *PRD2, *PRD3, *TST1, *TST2 and *TST3.                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Dairyland                                */
/*                                                                   */
/*  06/28/11  MLB  DRY                                               */
/*    - Revised to set library list based warehouse number passed    */
/*      on &TYPE parm. Example: *P055 = PIRF055. *T055=PIRTSTF055    */
/*  07/11/11  MLB  DRYa                                              */
/*    - Revised to add additional code to remove all PIRxxxxxxx libs */
/*      before adding additional libraries.  Add MONMSG cmds for     */
/*      Add/Rmv library list cmds.                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Kohl Wholesale                           */
/*                                                                   */
/*  07/15/14  MLB  KHL                                               */
/*    - Revised to set library list based on client id passed        */
/*      on &TYPE parm. Example: *PKHL = PIRKHLF. *TKHL=PIRTSTKHLF    */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Foods Galore                             */
/*                                                                   */
/*  09/10/14  RTR  FGL                                               */
/*    - Revised to set library list based on client id passed        */
/*      on &TYPE parm. Example: *PFGL = PIRFFGL. *TKHL=PIRTSTFFGL.   */
/*  05/06/17  RTR  FGLb                                              */
/*    - Revised for new library names after upgrade.                 */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Julius Silvert                           */
/*                                                                   */
/*  12/11/14  MLB  JSL                                               */
/*    - Revised to set library list based on client id passed        */
/*      on &TYPE parm. Example: *PJSL = PIRFJSL. *TJSL=PIRTSTFJSL.   */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: S. Bertram                               */
/*                                                                   */
/*  12/26/14  RTR  SBR                                               */
/*    - Revised to set library list based on client id passed        */
/*      on &TYPE parm. Example: *PSBR = PIRFSBR. *TSBR=PIRTSTFSBR.   */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Seashore Food & Produce                  */
/*                                                                   */
/*  01/23/18  RTR  SFPa                                              */
/*    - Revised to set library list based on client id passed        */
/*      on &TYPE parm. Example: *PSFP = SFPPIRF. *TSFP=SFPPIRTSTF.   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &TYPE  -  *PROD   Production library list                      */
/*              *PRDN   Production library list - New Version (640 A)*/
/*              *PRD1   Production library list - CashWA - Lincoln   */
/*              *PRD2   Production library list - CashWA - Aberdeen  */
/*              *PRD3   Production library list - CashWA - Kearney   */
/*              *MLTP   Multi-whse import library list - Production  (640aA) */
/*              *MLTT   Multi-whse import library list - Test        (640aA) */
/*              *Pnnn   Production library list - nnn=001 thru 999.  */
/*              *TEST   Test library list                            */
/*              *TSTN   Test library list - New Version       (640 A)*/
/*              *TST1   Test library list - CashWA - Lincoln         */
/*              *TST2   Test library list - CashWA - Aberdeen        */
/*              *TST3   Test library list - CashWA - Kearney         */
/*              *Tnnn   Test library list - nnn=001 thru 999.        */
/*              *900    900 test library list                        */
/*              *BFC    BFC test library list                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  FTP command                                                      */
/*                                                                   */
/*    QUOTE RCMD CALL PIR/FTPLIBL *TEST                              */
/*                                                                   */
/*-----------------------------------------------------------------*/

FTPLIBL:     PGM        PARM(&TYPE)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)      /* (DRY A) */
             DCL        VAR(&LIBCNT)     TYPE(*DEC)  LEN(7 0)     /* (DRYaA) */
             DCL        VAR(&LIBL)       TYPE(*CHAR) LEN(2750)    /* (DRYaA) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(5)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(PIR/CVTCASE) PARM('*LOW2UPR' &TYPE +
                          &TYPE) /* (720aA) */

             IF (&TYPE = '*PROD') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
     /*        ADDLIBLE   LIB(PIRFTP) POSITION(*FIRST)   */
     /*        MONMSG     MSGID(CPF2103)                 */
     /*        ADDLIBLE   LIB(PIRFTP2) POSITION(*FIRST)  */
     /*        MONMSG     MSGID(CPF2103)                 */
     /*        ADDLIBLE   LIB(PIRFTPF) POSITION(*FIRST)  */
     /*        MONMSG     MSGID(CPF2103)                 */
             ENDDO
                                                                  /* (640 A) */
             IF (&TYPE = '*PRDN') THEN(DO)                        /* (640 A) */
               ADDLIBLE   LIB(PIRN) POSITION(*FIRST)              /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
               ADDLIBLE   LIB(PIRMODSN) POSITION(*FIRST)          /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
               ADDLIBLE   LIB(PIRNF) POSITION(*FIRST)             /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
             ENDDO                                                /* (640 A) */

             IF (&TYPE = '*PRD1') THEN(DO)
               ADDLIBLE   LIB(BFCGLO710F) POSITION(*FIRST)        /* (CWDaA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDaA) */
               ADDLIBLE   LIB(CWDSQLPGM) POSITION(*FIRST)         /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(CWDSQL) POSITION(*FIRST)            /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS1) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*PRD2') THEN(DO)
               ADDLIBLE   LIB(BFCGLO710F) POSITION(*FIRST)        /* (CWDaA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDaA) */
               ADDLIBLE   LIB(CWDSQLPGM) POSITION(*FIRST)         /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(CWDSQL) POSITION(*FIRST)            /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*PRD3') THEN(DO)
               ADDLIBLE   LIB(BFCGLO710F) POSITION(*FIRST)        /* (CWDaA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDaA) */
               ADDLIBLE   LIB(CWDSQLPGM) POSITION(*FIRST)         /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(CWDSQL) POSITION(*FIRST)            /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO
                                                                  /* (640aA) */
             IF (&TYPE = '*MLTP') THEN(DO)                        /* (640aA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (640aA) */
               MONMSG     MSGID(CPF2103)                          /* (640aA) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (640aA) */
               MONMSG     MSGID(CPF2103)                          /* (640aA) */
               ADDLIBLE   LIB(PIRIMPORT) POSITION(*FIRST)         /* (640aA) */
               MONMSG     MSGID(CPF2103)                          /* (640aA) */
             ENDDO                                                /* (640aA) */
                                                                  /* (640aA) */
             IF (&TYPE = '*MLTT') THEN(DO)                        /* (640aA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (640aA) */
               MONMSG     MSGID(CPF2103)                          /* (640aA) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (640aA) */
               MONMSG     MSGID(CPF2103)                          /* (640aA) */
               ADDLIBLE   LIB(PIRIMPORT) POSITION(*FIRST)         /* (640aA) */
               MONMSG     MSGID(CPF2103)                          /* (640aA) */
             ENDDO                                                /* (640aA) */

       /* Cloud - Kohl Wholesale                                     (KHL A) */
             IF (&TYPE = '*PKHL') THEN(DO)                        /* (KHL A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
               ADDLIBLE   LIB(PIRKHLF) POSITION(*FIRST)           /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
               ADDLIBLE   LIB(PIRMODSKHL) POSITION(*FIRST)        /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
             ENDDO                                                /* (KHL A) */
                                                                  /* (KHL A) */
             IF (&TYPE = '*TKHL') THEN(DO)                        /* (KHL A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
               ADDLIBLE   LIB(PIRTSTKHLF) POSITION(*FIRST)        /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
               ADDLIBLE   LIB(PIRMODSKHL) POSITION(*FIRST)        /* (KHL A) */
               MONMSG     MSGID(CPF2103)                          /* (KHL A) */
             ENDDO                                                /* (KHL A) */

       /* Cloud - Foods Galore                                       (FGL A) */
             IF (&TYPE = '*PFGL') THEN(DO)                        /* (FGL A) */
               ADDLIBLE   LIB(FGLSQLPGM) POSITION(*FIRST)         /* (FGLbA) */
               MONMSG     MSGID(CPF2103)                          /* (FGLbA) */
               ADDLIBLE   LIB(FGLSQL) POSITION(*FIRST)            /* (FGLbA) */
               MONMSG     MSGID(CPF2103)                          /* (FGLbA) */
               ADDLIBLE   LIB(PIR700) POSITION(*FIRST)            /* (FGLbA) */
               MONMSG     MSGID(CPF2103)                          /* (FGLbA) */
               ADDLIBLE   LIB(FGLPIRF) POSITION(*FIRST)           /* (FGLbA) */
               MONMSG     MSGID(CPF2103)                          /* (FGLbA) */
               ADDLIBLE   LIB(FGLPIRMODS) POSITION(*FIRST)        /* (FGLbA) */
               MONMSG     MSGID(CPF2103)                          /* (FGLbA) */
               ADDLIBLE   LIB(FGLPIRCSTM) POSITION(*FIRST)        /* (FGLbA) */
               MONMSG     MSGID(CPF2103)                          /* (FGLbA) */
             ENDDO                                                /* (FGL A) */
                                                                  /* (FGL A) */
             IF (&TYPE = '*TFGL') THEN(DO)                        /* (FGL A) */
               ADDLIBLE   LIB(FGLSQLPGM) POSITION(*FIRST)         /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
               ADDLIBLE   LIB(FGLSQL) POSITION(*FIRST)            /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
               ADDLIBLE   LIB(PIR700) POSITION(*FIRST)            /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
               ADDLIBLE   LIB(FGLPIRTSTF) POSITION(*FIRST)        /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
               ADDLIBLE   LIB(FGLPIRMODS) POSITION(*FIRST)        /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
               ADDLIBLE   LIB(FGLPIRCSTM) POSITION(*FIRST)        /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
               ADDLIBLE   LIB(FGLPIRTEMP) POSITION(*FIRST)        /* (FGL A) */
               MONMSG     MSGID(CPF2103)                          /* (FGL A) */
             ENDDO                                                /* (FGL A) */

       /* Cloud - Julius Silvert                                     (JSL A) */
             IF (&TYPE = '*PJSL') THEN(DO)                        /* (JSL A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
               ADDLIBLE   LIB(PIRFJSL) POSITION(*FIRST)           /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
               ADDLIBLE   LIB(PIRMODSJSL) POSITION(*FIRST)        /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
             ENDDO                                                /* (JSL A) */
                                                                  /* (JSL A) */
             IF (&TYPE = '*TJSL') THEN(DO)                        /* (JSL A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
               ADDLIBLE   LIB(PIRTSTFJSL) POSITION(*FIRST)        /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
               ADDLIBLE   LIB(PIRMODSJSL) POSITION(*FIRST)        /* (JSL A) */
               MONMSG     MSGID(CPF2103)                          /* (JSL A) */
             ENDDO                                                /* (JSL A) */

       /* Cloud - S.Bertram                                          (SBR A) */
             IF (&TYPE = '*PSBR') THEN(DO)                        /* (SBR A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
               ADDLIBLE   LIB(PIRFSBR) POSITION(*FIRST)           /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
               ADDLIBLE   LIB(PIRMODSSBR) POSITION(*FIRST)        /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
             ENDDO                                                /* (SBR A) */
                                                                  /* (SBR A) */
             IF (&TYPE = '*TSBR') THEN(DO)                        /* (SBR A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
               ADDLIBLE   LIB(PIRTSTFSBR) POSITION(*FIRST)        /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
               ADDLIBLE   LIB(PIRMODSSBR) POSITION(*FIRST)        /* (SBR A) */
               MONMSG     MSGID(CPF2103)                          /* (SBR A) */
             ENDDO                                                /* (SBR A) */

       /* Cloud - Seashore Food & Produce                            (SFPaA) */
             IF (&TYPE = '*PSFP') THEN(DO)                        /* (SFPaA) */
               ADDLIBLE   LIB(PIR700) POSITION(*FIRST)            /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
               ADDLIBLE   LIB(SFPPIRF) POSITION(*FIRST)           /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
               ADDLIBLE   LIB(SFPPIRMODS) POSITION(*FIRST)        /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
             ENDDO                                                /* (SFPaA) */
                                                                  /* (SFPaA) */
             IF (&TYPE = '*TSFP') THEN(DO)                        /* (SFPaA) */
               ADDLIBLE   LIB(PIR700) POSITION(*FIRST)            /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
               ADDLIBLE   LIB(SFPPIRTSTF) POSITION(*FIRST)        /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
               ADDLIBLE   LIB(SFPPIRMODS) POSITION(*FIRST)        /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
               ADDLIBLE   LIB(SFPPIRTEMP) POSITION(*FIRST)        /* (SFPaA) */
               MONMSG     MSGID(CPF2103)                          /* (SFPaA) */
             ENDDO                                                /* (SFPaA) */

       /* Warehouse number sent on &type parm. *Pnnn where n= 001 - 999.    */
             IF         COND(%SST(&TYPE 1 2) = '*P' *AND %SST(&TYPE +
                          3 3) >= '001' *AND %SST(&TYPE 3 3) <= +
                          '999') THEN(DO)                         /* (DRY A) */

               RTVJOBA    USRLIBL(&LIBL)                          /* (DRYaA) */
               CHGVAR     VAR(&LIBCNT) VALUE(1)                   /* (DRYaA) */
 NEXTLIB1:     DO                                                 /* (DRYaA) */
                 IF         COND(%SST(&LIBL &LIBCNT 11) = ' ') THEN( +
                              GOTO NOLIBS1)                       /* (DRYaA) */
                 IF         COND(%SST(&LIBL &LIBCNT 3) = 'PIR') THEN(DO) +
                                                                  /* (DRYaA) */
                   CHGVAR     VAR(&LIB) VALUE(%SST(&LIBL &LIBCNT 10)) +
                                                                  /* (DRYaA) */
                   RMVLIBLE   LIB(&LIB)                           /* (DRYaA) */
                   MONMSG    MSGID(CPF2104 CPF2106 CPF2110 CPF2113) /*(DRYaA)*/
                 ENDDO                                            /* (DRYaA) */
                                                                  /* (DRYaA) */
                 CHGVAR     VAR(&LIBCNT) VALUE(&libcnt + 11)      /* (DRYaA) */
                 GOTO       NEXTLIB1                              /* (DRYaA) */
               ENDDO                                              /* (DRYaA) */
                                                                  /* (DRYaA) */
NOLIBS1:                                                          /* (DRYaA) */

               IF         COND(&TYPE = '*P001') THEN(CHGVAR +
                           VAR(&LIB) VALUE('PIRF      '))         /* (DRY A) */
               ELSE       CMD(CHGVAR VAR(&LIB) VALUE('PIRF' *tcat +
                            %sst(&type 3 3)))                     /* (DRY A) */
                                                                  /* (DRY A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
               ADDLIBLE   LIB(&LIB) POSITION(*FIRST)              /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
             ENDDO                                                /* (DRY A) */

             IF (&TYPE = '*TEST') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
        /*     ADDLIBLE   LIB(PIRFTP) POSITION(*FIRST)    */
        /*     MONMSG     MSGID(CPF2103)                  */
        /*     ADDLIBLE   LIB(PIRFTP2) POSITION(*FIRST)   */
        /*     MONMSG     MSGID(CPF2103)                  */
        /*     ADDLIBLE   LIB(PIRFTPF) POSITION(*FIRST)   */
        /*     MONMSG     MSGID(CPF2103)                  */
             ENDDO
                                                                  /* (640 A) */
             IF (&TYPE = '*TSTN') THEN(DO)                        /* (640 A) */
               ADDLIBLE   LIB(PIRN) POSITION(*FIRST)              /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
               ADDLIBLE   LIB(PIRMODSN) POSITION(*FIRST)          /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
               ADDLIBLE   LIB(PIRTESTNF) POSITION(*FIRST)         /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
               ADDLIBLE   LIB(PIRTEMP) POSITION(*FIRST)           /* (640 A) */
               MONMSG     MSGID(CPF2103)                          /* (640 A) */
             ENDDO                                                /* (640 A) */

             IF (&TYPE = '*TST1') THEN(DO)
               ADDLIBLE   LIB(BFCGLO710F) POSITION(*FIRST)        /* (CWDaA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDaA) */
               ADDLIBLE   LIB(CWDSQLPGM) POSITION(*FIRST)         /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(CWDSQL) POSITION(*FIRST)            /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS1) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP1) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*TST2') THEN(DO)
               ADDLIBLE   LIB(BFCGLO710F) POSITION(*FIRST)        /* (CWDaA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDaA) */
               ADDLIBLE   LIB(CWDSQLPGM) POSITION(*FIRST)         /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(CWDSQL) POSITION(*FIRST)            /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*TST3') THEN(DO)
               ADDLIBLE   LIB(BFCGLO710F) POSITION(*FIRST)        /* (CWDaA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDaA) */
               ADDLIBLE   LIB(CWDSQLPGM) POSITION(*FIRST)         /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(CWDSQL) POSITION(*FIRST)            /* (CWDbA) */
               MONMSG     MSGID(CPF2103)                          /* (CWDbA) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP720) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

       /* Warehouse number sent on &type parm. *Tnnn where n= 001 - 999.    */
             IF         COND(%SST(&TYPE 1 2) = '*T' *AND %SST(&TYPE +
                          3 3) >= '001' *AND %SST(&TYPE 3 3) <= +
                          '999') THEN(DO)                         /* (DRY A) */

               RTVJOBA    USRLIBL(&LIBL)                          /* (DRYaA) */
               CHGVAR     VAR(&LIBCNT) VALUE(1)                   /* (DRYaA) */
 NEXTLIB2:     DO                                                 /* (DRYaA) */
                 IF         COND(%SST(&LIBL &LIBCNT 11) = ' ') THEN( +
                              GOTO NOLIBS2)                       /* (DRYaA) */
                 IF         COND(%SST(&LIBL &LIBCNT 3) = 'PIR') THEN(DO) +
                                                                  /* (DRYaA) */
                   CHGVAR     VAR(&LIB) VALUE(%SST(&LIBL &LIBCNT 10)) +
                                                                  /* (DRYaA) */
                   RMVLIBLE   LIB(&LIB)                           /* (DRYaA) */
                   MONMSG    MSGID(CPF2104 CPF2106 CPF2110 CPF2113) /*(DRYaA)*/
                 ENDDO                                            /* (DRYaA) */
                                                                  /* (DRYaA) */
                 CHGVAR     VAR(&LIBCNT) VALUE(&libcnt + 11)      /* (DRYaA) */
                 GOTO       NEXTLIB2                              /* (DRYaA) */
               ENDDO                                              /* (DRYaA) */
                                                                  /* (DRYaA) */
NOLIBS2:                                                          /* (DRYaA) */
                                                                  /* (DRYaA) */

               IF         COND(&TYPE = '*T001') THEN(CHGVAR +
                           VAR(&LIB) VALUE('PIRTESTF  '))         /* (DRY A) */
               ELSE       CMD(CHGVAR VAR(&LIB) VALUE('PIRTSTF' *tcat +
                            %sst(&type 3 3)))                     /* (DRY A) */
                                                                  /* (DRY A) */
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)               /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
               ADDLIBLE   LIB(&LIB) POSITION(*FIRST)              /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)           /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
               ADDLIBLE   LIB(PIRTEMP) POSITION(*FIRST)           /* (DRY A) */
               MONMSG     MSGID(CPF2103)                          /* (DRY A) */
             ENDDO                                                /* (DRY A) */

             IF (&TYPE = '*900') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIR900F) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
        /*     ADDLIBLE   LIB(PIRFTP) POSITION(*FIRST)   */
        /*     MONMSG     MSGID(CPF2103)                 */
        /*     ADDLIBLE   LIB(PIRFTP2) POSITION(*FIRST)  */
        /*     MONMSG     MSGID(CPF2103)                 */
        /*     ADDLIBLE   LIB(PIRFTPF) POSITION(*FIRST)  */
        /*     MONMSG     MSGID(CPF2103)                 */
             ENDDO

             IF (&TYPE = '*BFC') THEN(DO)
               ADDLIBLE   LIB(PIRB) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIR900FDS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRWORKDS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRWORK619) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
        /*     ADDLIBLE   LIB(PIRFTP) POSITION(*FIRST)     */
        /*     MONMSG     MSGID(CPF2103)                   */
        /*     ADDLIBLE   LIB(PIRFTP2) POSITION(*FIRST)    */
        /*     MONMSG     MSGID(CPF2103)                   */
        /*     ADDLIBLE   LIB(PIRFTPF) POSITION(*FIRST)    */
        /*     MONMSG     MSGID(CPF2103)                   */
             ENDDO

END:         ENDPGM
