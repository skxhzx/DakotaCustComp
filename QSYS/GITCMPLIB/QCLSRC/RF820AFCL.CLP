/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RF820AFCL  RF 8 x 20 Menu                                        */
/*  20 February 2008                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    02/20/08  MLB  5.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RF820AFCL:    PGM        PARM(&MENU &LIB &RETURN)

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

             CALL PIRRFSCR ('*SET' '08' '020')

/*  Call menu program  */

 MENU:       CALL       PGM(RF820AF) PARM(&OPT)

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
