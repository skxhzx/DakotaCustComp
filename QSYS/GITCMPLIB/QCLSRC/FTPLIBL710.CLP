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
/*                                                                 */
/*-------------------------------------------------------------------*/
/* Client Custom Revisions: Cash WA Distributing                     */
/*                                                                   */
/*  01/29/09  MLB  CWD                                               */
/*    - Created 6 new parms for Aberdeen, Kearney locations.         */
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
/*-----------------------------------------------------------------*/
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
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*PRD2') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*PRD3') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRF3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
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
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS1) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP1) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*TST2') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP2) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
             ENDDO

             IF (&TYPE = '*TST3') THEN(DO)
               ADDLIBLE   LIB(PIR) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTESTF3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRMODS3) POSITION(*FIRST)
               MONMSG     MSGID(CPF2103)
               ADDLIBLE   LIB(PIRTEMP) POSITION(*FIRST)
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
