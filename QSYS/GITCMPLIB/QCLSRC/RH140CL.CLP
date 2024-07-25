/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RH140CL   Work with printed routes                               */
/*  25 June 1997                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*   02/19/13  MLB  6.50                                             */
/*     - Fix: Revised program add mbr DFTMBR to file IMPFPCKQ to     */
/*       prevent CPF4102 from occuring when PT132 calls HQ245 and    */
/*       there are no mbrs in the file.                              */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RH140CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RTEHED)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(RH140A)

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
             OPNDBF     FILE(&FILE) OPTION(*ALL)
             CHKOBJ     OBJ(IMPFPCKQ) OBJTYPE(*FILE) MBR(DFTMBR)  /* (650 A) */
             MONMSG     MSGID(CPF9815) EXEC(DO)                   /* (650 A) */
               ADDPFM     FILE(IMPFPCKQ) MBR(DFTMBR) TEXT('Do Not +
                           Remove')                               /* (650 A) */
               MONMSG     MSGID(CPF5812 CPF7306)                  /* (650 A) */
             ENDDO                                                /* (650 A) */

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
             IF         (&RETURN = '*F9') DO
                        CALL PGM(RH140B) PARM(&UNQKEY &RETURN)
                             IF (&RETURN = '*F9') GOTO CMDLBL(REPEAT)
                             ELSE
                             GOTO  CMDLBL(DONE)
                        ENDDO
             ELSE
                        GOTO       CMDLBL(DONE)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
