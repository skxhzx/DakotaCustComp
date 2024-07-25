/*********************************************************************/
/*                                                                   */
/*  GETUNQMEM   Get an unused or unique member for a workfile.       */
/*              The member will be created or cleared.               */
/*  27 August 1990                                                   */
/*  DAVE SOMMERVILLE                                                 */
/*                                                                   */
/*  Notes                                                            */
/*      - If error due to device names, the following changes can    */
/*        be made.  Take 8 characters starting from position 3 if    */
/*        the device starts with 'Q'.  Otherwise take 8 characters   */
/*        starting from position 2.  The 1st character used must be  */
/*        alpha.                                                     */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    10/15/97  DAS 4.06                                             */
/*      - Changed %SST to use positions 3 through 10.                */
/*                                                                   */
/*    11/04/99  DAS 4.13                                             */
/*      - Changed to initially try using the full job name.          */
/*        If that fails, a 2-digit counter is incremented and        */
/*        inserted into positions 2 & 3 of the job name. This is     */
/*        repeated until a member is found.                          */
/*      - Revised last CLRPFM to check for message CPF3156.          */
/*      - Revised to use ALCOBJ to see if a member is in use         */
/*        instead of relying on CLRPFM.                              */
/*                                                                   */
/*    03/24/02  DAS 4.16                                             */
/*      - Revised last CLRPFM to check for message CPF3203.          */
/*                                                                   */
/*    11/13/14  DAS 6.50                                             */
/*      - Revised to look for error when creating memember.          */
/*        Timing error occured with QZDASOINIT jobs, where the       */
/*        member was created by another job inbetween checking for   */
/*        the member and trying to create it.                        */
/*    02/25/15  MLB 6.50b                                            */
/*      - Fix: Revised MONMSG for ALCOBJ cmd to add CPF1085 Unable   */
/*        to allocate file with 5 sec delay. Then try again.         */
/*                                                                   */
/*********************************************************************/

GETUNQMEM:   PGM        PARM(&CMD &FILE &MEMBER)

/*********************************************************************/
/*                                                                   */
/*  FIELD DECLARATION                                                */
/*                                                                   */
/*********************************************************************/

             DCL        VAR(&CMD)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&FILE)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MEMBER)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&COUNT)   TYPE(*DEC)  LEN(2 0) VALUE(0)
             DCL        VAR(&COUNTA)  TYPE(*CHAR) LEN(2)
             DCL        VAR(&EXIST)   TYPE(*LGL)

/*********************************************************************/
/*                                                                   */
/*  MAIN LINE                                                        */
/*                                                                   */
/*********************************************************************/

/*                                                                   */
/*  GET WORKSTATION ID                                               */
/*                                                                   */
             RTVJOBA    JOB(&JOB)

/*                                                                   */
/*  CREATE MEMBER NAME BY ADDING A COUNTER TO THE JOB NAME           */
/*                                                                   */
TRYAGAIN:

 /* 413A */  IF (&COUNT = 0) DO
 /* 413A */    CHGVAR     VAR(&MEMBER) VALUE(&JOB)
 /* 413A */  ENDDO

 /* 413A */  IF (&COUNT > 0) DO
 /* 413A */    CHGVAR     VAR(&MEMBER) VALUE(%SST(&JOB 1 1) *TCAT +
                            &COUNTA *TCAT %SST(&JOB 4 7))
 /* 413A */  ENDDO

             CHGVAR     VAR(&COUNT) VALUE(&COUNT + 1)
             CHGVAR     VAR(&COUNTA) VALUE(&COUNT)

 /* 413D     CHGVAR     VAR(&MEMBER) VALUE(%SST(&JOB 3 8) *TCAT +  */
 /* 413D                  &COUNTA)                                 */

/*                                                                   */
/*  SEE IF MEMBER EXISTS (1=EXIST)                                   */
/*                                                                   */

             CHGVAR     VAR(&EXIST) VALUE('1')
             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MEMBER)
             MONMSG     MSGID(CPF9815) EXEC(CHGVAR VAR(&EXIST) +
                          VALUE('0'))

/*                                                                   */
/*  IF MEMBER DOES NOT EXIST THEN CREATE IT AND RETURN               */
/*                                                                   */
             IF (*NOT &EXIST) DO
                ADDPFM     FILE(&FILE) MBR(&MEMBER)
                MONMSG     MSGID(CPF7306) EXEC(DO)   /* 650aA */
                  CHGVAR     VAR(&EXIST) VALUE('1')  /* 650aA */
                  GOTO       CMDLBL(EXISTS)          /* 650aA */
                ENDDO                                /* 650aA */
                RETURN
             ENDDO

/*                                                                   */
/*  IF MEMBER DOES EXIST BUT USER WANTS A NEW MEMBER THEN TRY AGAIN  */
/*                                                                   */
 EXISTS: /* 650aA */
             IF (&EXIST *AND (&CMD = '*NEW    ')) DO
                GOTO TRYAGAIN
             ENDDO

/*                                                                   */
/*  IF MEMBER EXISTS AND USER DIDN'T SPECIFY THAT IT HAD TO BE NEW   */
/*     THEN WE ASSUME THAT THE USER IS REUSING A WORK FILE           */
/*                                                                   */
/*  THERFORE, WE TRY TO CLEAR THE MEMBER BEFORE RETURNING. IF THE    */
/*     MEMBER IS ALREADY BEING USED WE NEED TO GET A DIFFERENT       */
/*     MEMBER TO USE.                                                */
/*                                                                   */

 /* 413A */  ALCOBJ     OBJ((&FILE *FILE *EXCL &MEMBER)) WAIT(0)
 /* 413A */  MONMSG     MSGID(CPF1002) EXEC(GOTO CMDLBL(TRYAGAIN))
 /* 650b */  MONMSG     MSGID(CPF1085) EXEC(DO)
 /* 650b */    DLYJOB     DLY(5)  /* Wait to see if file becomes available. */
 /* 650b */    GOTO       CMDLBL(TRYAGAIN)
 /* 650b */  ENDDO

             CLRPFM     FILE(&FILE) MBR(&MEMBER)
 /* 416M */  MONMSG     MSGID(CPF3130 CPF3156 CPF3203) EXEC(GOTO +
                          CMDLBL(TRYAGAIN))

 /* 413A */  DLCOBJ     OBJ((&FILE *FILE *EXCL &MEMBER))

             ENDPGM
