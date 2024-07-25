/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RF840CL  RF 8 x 40 Menu                                          */
/*  08 May, 1997                                                     */
/*  Roxanne Harrison                                                 */
/*  Created using RF820CL                                            */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    07/25/97  DAS  AFI                                             */
/*      - Changed option 8 to special slot replenishment program.    */
/*      - Added option 90 for signoff                                */
/*    09/10/98   RH  4.10                                            */
/*      - Added option 10, Will Call Pick.                           */
/*    08/23/99   HNK 4.12                                            */
/*      - IT275CL CALLED INSTEAD OF IT270 - SPECIFIC SLOT REPL       */
/*                                                                   */
/*    09/20/99   DAS 4.12A                                           */
/*      - Removed call for Option 7 - Replenishments                 */
/*    12/22/99   RH  4.13                                            */
/*      - Added call for Option 7 - Transfer.                        */
/*    02/25/00   MLB 4.13a                                           */
/*      - Moved call for Option 8 - Replenishments to Option 13.     */
/*      - Added call for Option 8 - Repl/Letdowns.                   */
/*                                                                   */
/*    03/22/00   RH  4.13b                                           */
/*      - Change option 10, Will Call Pick to option 12.             */
/*      - Added call for Option 10-Task Entry                        */
/*      - Added call for Option 11-Inventory Entry                   */
/*                                                                   */
/*    07/10/00  DAS  4.14                                            */
/*      - Added call for Option 14-Stage Putaway                     */
/*                                                                   */
/*    07/27/00  DAS  4.14a                                           */
/*      - MAJOR REVISION.                                            */
/*      - Program RF840 changed to NOT return to this program in     */
/*        order to call the menu option program. RF840 now calls     */
/*        the program directly.                                      */
/*      - All option logic removed to cleanup program, except for    */
/*        option 90.                                                 */
/*      - Added BOTTOM tag.                                          */
/*      - Removed RETURN from F3/F12.                                */
/*      - Change CPF0000 trap to goto BOTTOM instead of MENU.        */
/*                                                                   */
/*    06/15/01  DAS  4.15                                            */
/*      - Revised to call program to set screen size being used.     */
/*                                                                   */
/*    06/12/08  MLB  5.20                                            */
/*      - Fix: Revised pgm to add MONMSG on call to RFSCRN for       */
/*        program failures.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RF840CL:    PGM        PARM(&MENU &LIB &RETURN)

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

 MENU:       CALL       PGM(RF840) PARM(&OPT)
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
