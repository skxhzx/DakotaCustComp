/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TE112CL   Task Entry                                             */
/*  03 January, 1996                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/02/00  DAS  4.13                                            */
/*      - Added logic to get uniuqe member for WORKOPT.             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TE112CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(TE112)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)  /* 413 A */

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define work file to be used for display options.  */   /* 413 A */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)



/*  On with the show ... */

             CALL       PGM(&PGM)

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)              /* 413 A */
             RCLRSC     LVL(*CALLER)
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER) /* 413 A */

             ENDPGM
