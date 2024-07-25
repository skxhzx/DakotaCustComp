/*-------------------------------------------------------------------*/
/*                                                                   */
/*  OS110CL   Will Call Selection Maintenance                        */
/*  10 September, 1998                                               */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    04/14/99  RH   4.11                                            */
/*      - Move statement for RCLRSC to before CLRPFM statement.      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 OS110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(ORDSLCT1)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(OS110)
  /* Informational message. */


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)
             DCL        VAR(&PLEVEL) TYPE(*CHAR) LEN(8)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  End if not at RF level                     */
                CALL       PGM(PRODLVL) PARM(&PLEVEL)
             IF (&PLEVEL = '*BASE') THEN(DO)
               SNDPGMMSG  MSG('Program only available to RF product') +
                          MSGTYPE(*COMP)
  /*                      MSGTYPE(*INFO)      */
               GOTO ENDIT
               ENDDO
             IF (&PLEVEL = '*EPM ') THEN(DO)
               SNDPGMMSG  MSG('Program only available to RF product') +
                          MSGTYPE(*COMP)
               GOTO ENDIT
               ENDDO
/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

             OVRDBF     FILE(&FILE) SHARE(*YES)
             OPNDBF     FILE(&FILE) OPTION(*ALL)

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(&PGM)  PARM(&UNQKEY &RETURN)

/*  Clean up before leaving */

             CLOF       OPNID(&FILE)
             DLTOVR     FILE(&FILE)
             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)
 ENDIT:
/* 4.11      RCLRSC     LVL(*CALLER)  */

             ENDPGM
