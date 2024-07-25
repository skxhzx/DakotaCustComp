/*-------------------------------------------------------------------*/
/*  LOADTEQCL2: Closed Returned Trailer Equip Verification.          */
/*              This CLP is called by either LOADR51 or LOADR52      */
/*              which are executed from LOADTEQCL (Pirrtn/Opt 20).   */
/*                                                                   */
/*  October 29, 2008                                                 */
/*  Jose G. Duque                                                    */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 LOADTEQCL2: PGM   PARM(&PGMID)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

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




REPEAT:
             /* Loadr51 displays data by loader and Loadr55 link to    */
             /* "Closed Returned Trailer Equipment Verification" screen*/

             IF         (&PGMID = 'LOADR51') DO
             CALL       PGM(LOADR54)  PARM(&RETURN)

             IF         (&RETURN = '*F9') DO
                        CALL PGM(LOADR55) PARM(&RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE GOTO CMDLBL(DONE)
                        ENDDO

             ENDDO

             ELSE DO
             /* Loadr55 and Loadr54 display, "Closed Returned Trailer  */
             /* Equipment Verification" screen, by trailer# and route# */
             /* respectively.                                          */

             CALL       PGM(LOADR55)  PARM(&RETURN)

             IF         (&RETURN = '*F9') DO
                        CALL PGM(LOADR54) PARM(&RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE GOTO CMDLBL(DONE)
                        ENDDO

             ELSE       GOTO       CMDLBL(DONE)
             ENDDO

DONE:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
