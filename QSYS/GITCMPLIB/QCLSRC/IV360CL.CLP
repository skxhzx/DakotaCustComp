/*-------------------------------------------------------------------*/
/*                                                                   */
/*  IV360CL   Clear inventory check records                          */
/*  15 December 2003                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 IV360CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE(INVCHK1)
             DCL        VAR(&PGM)   TYPE(*CHAR) LEN(8)  VALUE(IV360)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

             OVRDBF     FILE(&FILE) SHARE(*YES)
          /* OPNDBF     FILE(&FILE) OPTION(*ALL) */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

   /* Use OPNQRYF to select and order the records we need */

             OPNQRYF    FILE((&FILE)) OPTION(*ALL) +
                          QRYSLT('IVCSTA *NE "4 "') KEYFLD(*FILE)
  /* 4.16a                QRYSLT('IVCSTA="1 "') KEYFLD(*FILE) */

/*  On with the show ... */

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
