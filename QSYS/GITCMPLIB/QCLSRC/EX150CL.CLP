/*-------------------------------------------------------------------*/
/*                                                                   */
/*  EX150CL   Clear Item Receiving exceptions                        */
/*  13 September 2004                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*   09/13/04  RH   4.17                                             */
/*     - Created using EX120                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions                                          */
/*                                                                   */
/*    11/04/14  CBI -JGD                                             */
/*      Add pgm "EX150B" to respond to "F9" key pressed from         */
/*      existing pgm "EX150A" within this CLP.                       */
/*      EX150A - displays screen sorted buy item.                    */
/*      EX150B - displays screen sorted by date.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 EX150CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (640 A) */
             DCL        VAR(&CHENEY) TYPE(*CHAR) LEN(10) +
                          VALUE('CHENEYBROS')                     /* (DRY A) */
             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (640 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (640 A) */
             DCL        VAR(&FILE)  TYPE(*CHAR) LEN(10) VALUE('      ')
             DCL        VAR(&PGM)   TYPE(*CHAR) LEN(8)  VALUE(EX150A)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640 A) */

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

          /* OVRDBF     FILE(&FILE) SHARE(*YES)  */
          /* OPNDBF     FILE(&FILE) OPTION(*ALL) */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

REPEAT:
             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

/* CBI M */  IF         (&RETURN = '*F9') DO
/* CBI M */             CALL PGM(EX150B) PARM(&UNQKEY &RETURN)
/* CBI M */                  IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
/* CBI M */                  ELSE
/* CBI M */                  GOTO  CMDLBL(DONE)
/* CBI M */             ENDDO
/* CBI M */  ELSE
/* CBI M */             GOTO       CMDLBL(DONE)

DONE:
/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
