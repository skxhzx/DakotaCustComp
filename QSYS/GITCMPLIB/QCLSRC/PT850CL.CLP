/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PT850CL   Reset Selection Transaction to Open Status.            */
/*                                                                   */
/*  August 25, 2006                                                  */
/*  Jose Duque                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*  08/25/06  JD   5.10                                              */
/*    - Created.                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PT850CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(PT850)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

  /* Informational message. */

             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
             VALUE('   You are not authorized to use this option.')

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)

             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */

             CHGVAR     VAR(&PGMID) VALUE(PT850CL)
             RTVJOBA    USER(&PUSR)

/*  Check if user is authorized to use this option */

             CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
             IF         COND(&PRTN *EQ '*NO')  THEN(DO)
                        SNDPGMMSG  MSG(&NOAUTHRZE)   +
                        MSGTYPE(*INFO)

             RETURN
             ENDDO
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)



/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)

             ENDPGM
