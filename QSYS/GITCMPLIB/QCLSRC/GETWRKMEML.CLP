/*-------------------------------------------------------------------*/
/*                                                                   */
/*  GETWRKMEML  Get logical work file member for batch job.          */
/*              The member is the name of the work station.          */
/*  25 May,  1995                                                    */
/*  Dave Sommerville                                                 */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    04/10/15  MLB  7.00                                            */
/*      - Revised to look for error when creating memember.          */
/*        Timing error occured with QZDASOINIT jobs, where the       */
/*        member was created by another job inbetween checking for   */
/*        the member and trying to create it.                        */
/*      - Copied mod from GETUNQMEM.                                 */
/*    04/10/15  MLB  7.00a                                           */
/*      - Fix: Revised MONMSG for ALCOBJ cmd to add CPF1085 Unable   */
/*        to allocate file with 5 sec delay. Then try again.         */
/*      - Copied mod from GETUNQMEM.                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*    &CMD                                                           */
/*             *REUSE  - Make sure member exists but don't clear it. */
/*    &FILE    Work file name.                                       */
/*    &MEMBER  Member name.                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/

GETWRKMEML:  PGM        PARM(&CMD &LOGICAL &PHYSICAL &MEMBER)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)      TYPE(*CHAR) LEN(8)
             DCL        VAR(&EXIST)    TYPE(*LGL)
             DCL        VAR(&LOGICAL)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&PHYSICAL) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  See if member exists (1=EXIST). */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(&LOGICAL) OBJTYPE(*FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*  If member does not exist then create it and return. */

             IF (*NOT &EXIST) DO
TRYAGAIN:                                                         /* (700 A) */
             ADDLFM     FILE(&LOGICAL) MBR(&MEMBER) +
                          DTAMBRS((*CURRENT/&PHYSICAL (&MEMBER)))
               MONMSG     MSGID(CPF7306) EXEC(DO)                 /* (700 A) */
                 CHGVAR     VAR(&EXIST) VALUE('1')                /* (700 A) */
               ENDDO                                              /* (700 A) */
               MONMSG     MSGID(CPF3204) EXEC(DO)                 /* (700aA) */
                 DLYJOB     DLY(5)  /* Wait to see if file becomes available. */
                 GOTO       CMDLBL(TRYAGAIN)                      /* (700aA) */
               ENDDO                                              /* (700aA) */
                RETURN
             ENDDO

             ENDPGM
