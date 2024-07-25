/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RFSCRNCL RF Screen Select Menu 8 X 20                            */
/*  1 July 1999                                                      */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   06/11/01  DAS  4.15                                             */
/*     - Changed to set screen row/columns for other programs to use.*/
/*     - Changed option 4 to display RF1620 menu.                    */
/*     - Changed signoff to option 90.                               */
/*     - Added call to set screen size for 2480 menu.                */
/*                                                                   */
/*   07/12/02  MLB  4.16                                             */
/*     - Revised program to monitor for abnormal termination and     */
/*       exit.                                                       */
/*   08/01/05  RH   5.00                                             */
/*     - 4.16 change missed in 4.16 update.                          */
/*   11/10/06  RH   5.10                                             */
/*     - Enh - Add &FEAT to call Stand Alone programs.               */
/*                                                                   */
/*   06/12/08  MLB  5.20                                             */
/*     - Fix: Revised pgm to add MONMSG on call to RFSCRN for        */
/*       program failures.                                           */
/*   03/12/10  RH   5.30                                             */
/*     - Enh: Add code to Get Client.                                */
/*   03/12/10  RH   MJKa                                             */
/*     - Enh: If user is not manager, display limited RF2480L        */
/*       screen. Add call to CHKLIST                                 */
/*   04/10/10  RH   CCPa                                             */
/*     - Enh: If user is not manager, display limited RF2480L        */
/*       screen. Add call to CHKLIST                                 */
/*   07/21/11  RH   640a                                             */
/*     - Enh: Change custom MJKa and CCPa mods to standard 640a      */
/*       If user is not manager, display limited RF2480L screen      */
/*       Add call to CHKLIST  Delete old mod marks for readability   */
/*       Add user to US210CL to allow access.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RFSCRNCL:   PGM        PARM(&MENU &LIB &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&CLIENTLOC)  TYPE(*CHAR) LEN(10)      /* (530 A) */
             DCL        VAR(&MENU)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(2)
             DCL        VAR(&OPT)        TYPE(*CHAR) LEN(2)
             DCL        VAR(&FEAT)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)      /* (MJK A) */
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)      /* (MJK A) */
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)       /* (MJK A) */
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)      /* (MJK A) */
             DCL        VAR(&MJKELN) TYPE(*CHAR) LEN(10) +
                          VALUE('MJKELLNER')                     /* (MJK A) */
             DCL        VAR(&CAPCTY) TYPE(*CHAR) LEN(10) +
                          VALUE('CAPITOLCTY')                    /* (CCP A) */

/*           MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(MENU))      (4.16)  */
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ENDMNU)) /* (4.16)  */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (530 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (530 A) */


/*  Call menu program  */

 MENU:       CALL       PGM(RFSCRN) PARM(&OPT &FEAT)
             MONMSG     MSGID(CPF0006 CPF4128 CPF9999) EXEC(DO)   /* (520 A) */
               DSPJOBLOG  OUTPUT(*PRINT)                          /* (520 A) */
               GOTO       CMDLBL(ENDMNU)                          /* (520 A) */
             ENDDO  /* End pgm if connection lost. */             /* (520 A) */
/*           MONMSG     MSGID(CPF0006) EXEC(GOTO CMDLBL(ENDMNU)) /* +
                          (4.16) */

/*  See if user wants to exit using F3  */

             IF         COND(&OPT *EQ 'F3') THEN(DO)
/*             CHGVAR     VAR(&RETURN) VALUE(X'FFFF') */
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
               RETURN
             ENDDO

/*  See if user wants to exit using F12  */

             IF         COND(&OPT *EQ 'F2') THEN(DO)
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
               RETURN
             ENDDO

   /* Set screen size for other programs to use */
   /* Note: For *PGM menus, this is done in the menu's CL program */

             CALL PIRRFSCR ('*SET' '24' '080') /* 415 A */

/*  Feature 3 - Stand Alone screens   */

             IF         COND(&FEAT *EQ '3') THEN(DO)
/*  Option 1 - Full screen       */
             IF         COND(&OPT *EQ '01') THEN(GO MENU(RF2480S))

/*  Option 2 - Fork lift screen       */

             IF         COND(&OPT *EQ '02') THEN(CALL PGM(RF840SCL) +
                          PARM('' '' ''))

/*  Option 3 - Hand held screen.         */
             IF         COND(&OPT *EQ '03') THEN(CALL PGM(RF820SCL) +
                          PARM('' '' ''))

/*  Option 4 - Hand held 16-line screen */             /* 415 M */

             IF         COND(&OPT *EQ '04') THEN(CALL PGM(RF162SCL) +
                          PARM('' '' ''))
             ENDDO

/*  Normal screens.                   */

/*530 A*/    CHGVAR     VAR(&PGMID) VALUE(RFSCRNCL)
/*530 A*/    RTVJOBA    USER(&PUSR)
/*530 A      RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)   */
             IF         COND(&FEAT *NE '3') THEN(DO)
/*  Check if user is authorized to use this option                   (PAK A) */
/*  6.40a Previous mods removed for readability.                     (640aA) */

               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR +
                            &PRTN)                                /* (MJK A) */
               IF       COND(&OPT *EQ '01') THEN(DO)          /* (M    JK A) */
               IF       COND(&PRTN *EQ '*NO') THEN(GO MENU(RF2480L)) /*MJKA  */
               IF       COND(&PRTN *EQ '*YES') THEN(GO MENU(RF2480)) /* MJKA */
             ENDDO                                                /* (MJK A) */

/*  Option 2 - Fork lift screen       */

             IF         COND(&OPT *EQ '02') THEN(CALL PGM(RF840CL) +
                          PARM('' '' ''))

/*  Option 3 - Hand held screen.         */

             IF         COND(&OPT *EQ '03') THEN(CALL PGM(RF820CL) +
                          PARM('' '' ''))

/*  Option 4 - Hand held 16-line screen */             /* 415 M */

             IF         COND(&OPT *EQ '04') THEN(CALL PGM(RF1620CL) +
                          PARM('' '' ''))
             ENDDO

/*  Option 90 - Sign off  */                           /* 415 A */

             IF         COND(&OPT *EQ '90') THEN(GOTO CMDLBL(ENDMNU))


/*  Loop back and redisplay the menu  */

             GOTO       CMDLBL(MENU)

/*  End and signoff    */

 ENDMNU:     SIGNOFF
/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
