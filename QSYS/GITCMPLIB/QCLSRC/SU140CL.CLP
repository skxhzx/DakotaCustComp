/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SU140CL   RF Set slot item/qty                                   */
/*  14 July, 1999                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    02/10/05  DAS  5.00                                            */
/*      - Revised to call SU160CL for City Line so RF menu           */
/*        doesn't need to be changed.                                */
/*                                                                   */
/*    02/19/11  MLB  6.40                                            */
/*      - Fix: Revised program to call GETUNQMEM for WORKOPT         */
/*        file because SU140 allows subfile lists to be displayed.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*    01/28/14  MLB  DRY                                             */
/*      - Reamed program object to SU140CLXX to disable access on    */
/*        production server. Per Kelly R. email dated 01/28/14.      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SU140CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(SU140)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ID)     TYPE(*CHAR) LEN(10)   /* 500 A */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (640 A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  Get Client Id */                                       /* 500 A */

             CALL       PGM(GETCLIENT) PARM(&ID)

/*  Define work file to be used for display options.                 (640 A) */
/*    - Get unique member to use.                                    (640 A) */
/*    - Override file to use unique member.                          (640 A) */

             IF (&MEMBER = ' ') DO                                /* (640 A) */
                CALL PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)  /* (640 A) */
                ENDDO                                             /* (640 A) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)    /* (640 A) */

/*  If client is City Line, call SU160CL and get out */    /* 500 A */


             IF         COND(&ID *EQ 'CITYLINE') THEN(DO)
             CALL       PGM(SU160CL)
             GOTO       CMDLBL(SKIPPGM)
             ENDDO

/*  On with the show ... */

             CALL       PGM(&PGM)

SKIPPGM:                                                   /* 500 A */

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)                             /* (640 A) */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)                /* (640 A) */
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310)                /* (640 A) */

             ENDPGM
