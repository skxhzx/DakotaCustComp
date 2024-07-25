/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RF840SCL RF 8 x 40 Menu  Stand Alone                             */
/*  10 November, 2006                                                */
/*  Roxanne Harrison                                                 */
/*  Created using RF840CL for Stand Alone                            */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    11/10/06  RH  5.10                                             */
/*      - Created for Stand Alone                                    */
/*                                                                   */
/*    06/12/08  MLB  5.20                                            */
/*      - Fix: Revised pgm to add MONMSG on call to RFSCRN for       */
/*        program failures.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RF840SCL:    PGM        PARM(&MENU &LIB &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MENU)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(2)
             DCL        VAR(&OPT)        TYPE(*CHAR) LEN(2)

         /*  MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(MENU))      414aD */
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(BOTTOM)) /* 414aA */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Set screen size for other programs to use */  /* 415 A */

             CALL PIRRFSCR ('*SET' '08' '040')    /* 415 A */

/*  Call menu program  */

 MENU:       CALL       PGM(RF840S) PARM(&OPT)
             MONMSG     MSGID(CPF0006 CPF4128 CPF9999) EXEC(DO)   /* (520 A) */
               DSPJOBLOG  OUTPUT(*PRINT)                          /* (520 A) */
               SIGNOFF                                            /* (520 A) */
             ENDDO  /* End pgm if connection lost. */             /* (520 A) */

/*  See if user wants to exit using F3  */

             IF         COND(&OPT *EQ 'F3') THEN(DO)
/*             CHGVAR     VAR(&RETURN) VALUE(X'FFFF') */
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
        /*     RETURN                                      414aD */
             ENDDO

/*  See if user wants to exit using F12  */

             IF         COND(&OPT *EQ 'F2') THEN(DO)
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
        /*     RETURN                                      414aD */
             ENDDO

/*  Option 90 - Sign-off  */

             IF         COND(&OPT *EQ '90') THEN(SIGNOFF)

/*  Clean up before leaving */

BOTTOM:                                             /* 414aA */
             RCLRSC     LVL(*CALLER)

             ENDPGM
