/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UTMNUSCL  PIR Utility Menus -                                    */
/*  18 June 2010                                                     */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/18/10  RH   5.30                                            */
/*      - Created                                                    */
/*    08/27/12  RH   6.40                                            */
/*      - ENH: Add opt 5 BFC Tomcat Server Utility Menu              */
/*    08/31/20  JCJ  7.30                                            */
/*      - ENH: Changed PIRTOM2 to PIRTOM3.                           */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UTMNUSCL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(UTMNUS)
             DCL        VAR(&DESC) TYPE(*CHAR) LEN(60) VALUE(' +
                          PIR UTILITY MENUS')
             DCL        VAR(&GLOBAL) TYPE(*CHAR) LEN(4) VALUE(*NO)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD) TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(2)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  On with the show ... */

             CHGVAR     VAR(&CMD) VALUE('*ADD    ')
 MENU:       CALL       PGM(UTMNUS) PARM(&CMD &PGM &OPT &RETURN)

/*  See if user wants to exit using F3  */

             IF         COND(&OPT *EQ 'F3') THEN(GOTO CMDLBL(ENDMNU))

/*  See if user wants to exit using F12  */

             IF         COND(&OPT *EQ 'F2') THEN(GOTO CMDLBL(ENDMNU))


/*  Option 1 - PIR Utility       */
             IF         COND(&OPT *EQ '01') THEN(GO MENU(PIRUTIL))

/*  Option 2 - Voice Utility          */
             IF         COND(&OPT *EQ '02') THEN(GO MENU(VOUTIL))
/*  Option 3 - Transaction Utility    */
             IF         COND(&OPT *EQ '03') THEN(GO MENU(PIRUTIL3))
/*  Option 4 - PIR Zebra Utility    */
             IF         COND(&OPT *EQ '04') THEN(GO MENU(PIRZEBRA))
/*  Option 5 - BFC Tomcat Server Utility Menu */
             IF         COND(&OPT *EQ '05') THEN(GO MENU(PIRTOM3))
/*  Option 90 - Sign off  */

             IF         COND(&OPT *EQ '90') THEN(GOTO CMDLBL(OFFMNU))

/*  Loop back and redisplay the menu  */

             GOTO       CMDLBL(MENU)

/*  End and signoff    */

 OFFMNU:     SIGNOFF
/*  Clean up before leaving */

 ENDMNU:     RCLRSC     LVL(*CALLER)

             ENDPGM
