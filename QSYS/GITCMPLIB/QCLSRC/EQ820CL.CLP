/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EQ820CL  Equip User 8 x 20 Menu                                  */
/*  27 March 2003                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*    04/11/97   RH  2.20                                            */
/*      - Added option 7, Verify zero slots.                         */
/*    04/23/97   RH  2.20                                            */
/*      - Added option 8, Inventory adjustments.                     */
/*      - Added option 9, Item lookup.                               */
/*    05/08/97   RH  2.20                                            */
/*      - Change order of menu options.                              */
/*    09/10/98   RH  4.10                                            */
/*      - Added option 10, Will Call Pick.                           */
/*    07/30/99   RH  4.12                                            */
/*      - Added option 90, Sign Off.                                 */
/*    03/22/00   RH  4.13                                            */
/*      - Added call for Option 11-Inventory Entry                   */
/*                                                                   */
/*    07/10/00  DAS  4.14                                            */
/*      - Added call for Option 14-Stage Putaway                     */
/*                                                                   */
/*    07/27/00  DAS  4.14a                                           */
/*      - Added BOTTOM tag.                                          */
/*      - Added message forwarding to end of program.                */
/*      - Change F3 & F12 to goto BOTTOM instead of doing RETURN.    */
/*      - Change CPF0000 trap to goto GETOUT instead of MENU.        */
/*                                                                   */
/*    07/27/00  DAS  4.14a                                           */
/*      - MAJOR REVISION.                                            */
/*      - Program RF820 changed to NOT return to this program in     */
/*        order to call the menu option program. RF820 now calls     */
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
/*-------------------------------------------------------------------*/

 EQ820CL:    PGM        PARM(&MENU &LIB &RETURN)

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

   /* 417    CALL PIRRFSCR ('*SET' '08' '020')*/  /* 415 A */

/*  Call menu program  */

 MENU:       CALL       PGM(EQ820) PARM(&OPT)

/*  See if user wants to exit using F3  */

             IF         COND(&OPT *EQ 'F3') THEN(DO)
/*             CHGVAR     VAR(&RETURN) VALUE(X'FFFF') */
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
         /*    RETURN                                      414aD */
             ENDDO

/*  See if user wants to exit using F12  */

             IF         COND(&OPT *EQ 'F2') THEN(DO)
               CHGVAR     VAR(&RETURN) VALUE(X'FFFE')
         /*    RETURN                                      414aD */
             ENDDO

/*  Option 90 - Sign-off  */

             IF         COND(&OPT *EQ '90') THEN(SIGNOFF)

/*  Clean up before leaving */

BOTTOM:                                             /* 414aA */
             RCLRSC     LVL(*CALLER)

             ENDPGM
