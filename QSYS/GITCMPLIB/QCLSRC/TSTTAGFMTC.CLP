/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TSTTAGFMTC Test Print Clam Tag labels                            */
/*  26 December 2005                                                 */
/*  Jeffrey Jahnkele                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TSTTAGFMT:  PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(TSTTAGFMT)

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
