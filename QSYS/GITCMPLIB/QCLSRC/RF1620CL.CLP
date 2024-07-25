/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RF1620CL  RF 16 x 20 Menu                                        */
/*  11 June 2001                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    06/11/01  DAS  4.15                                            */
/*      - Created                                                    */
/*                                                                   */
/*   06/12/08  MLB  5.20                                             */
/*     - Fix: Revised pgm to add MONMSG on call to RFSCRN for        */
/*       program failures.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RF1620CL:   PGM        PARM(&MENU &LIB &RETURN)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MENU)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(2)
             DCL        VAR(&OPT)        TYPE(*CHAR) LEN(2)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(BOTTOM))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Set screen size for other programs to use */

             CALL PIRRFSCR ('*SET' '16' '020')

/*  Call menu program  */

 MENU:       CALL       PGM(RF1620) PARM(&OPT)
             MONMSG     MSGID(CPF0006 CPF4128 CPF9999) EXEC(DO)   /* (520 A) */
               DSPJOBLOG  OUTPUT(*PRINT)                          /* (520 A) */
               SIGNOFF                                            /* (520 A) */
             ENDDO  /* End pgm if connection lost. */             /* (520 A) */

/*  See if user wants to exit using F3  */

             IF         COND(&OPT *EQ 'F3') THEN(DO)
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
             ENDDO

/*  See if user wants to exit using F12  */

             IF         COND(&OPT *EQ 'F2') THEN(DO)
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
             ENDDO

/*  Option 90 - Sign-off  */

             IF         COND(&OPT *EQ '90') THEN(SIGNOFF)

/*  Clean up before leaving */

BOTTOM:
             RCLRSC     LVL(*CALLER)

             ENDPGM
