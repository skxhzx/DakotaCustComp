/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO200CL   RF Receiving                                           */
/*  03 December, 1996                                                */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  SK110CL - 1.00                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/30/01  DAS  4.15                                            */
/*      - Added parameter to call program PO200 for the number of    */
/*        lines the RF display has, 8 or 16.                         */
/*                                                                   */
/*    06/13/01  DAS  4.15A                                           */
/*      - Removed above change. Getting lines from dataarea.         */
/*                                                                   */
/*    04/15/03  MLB  4.17                                            */
/*      - Enh: Added support for WORKOPT file to program.            */
/*                                                                   */
/*                                                                   */
/*    07/11/18  RH   7.20                                            */
/*      - Added client custom code support to program.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Greco & Sons                            */
/*                                                                   */
/*    07117/18  RH   GRC                                             */
/*      - Add user authorization check like PO110CL                  */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO200CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (720 A) */

             DCL        VAR(&GRECO) TYPE(*CHAR) LEN(10) +
                          VALUE('GRECO     ')                     /* (GRC A) */

             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(PO200)
 /* 415A */  DCL        VAR(&LINES) TYPE(*CHAR) LEN(2) VALUE('08')
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (GRC A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)          /* (720 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (720 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)             /* (417) */
             DCL        VAR(&PGMID)  TYPE(*CHAR) LEN(10)          /* (GRC A) */
             DCL        VAR(&PGMOPT) TYPE(*CHAR) LEN(20)          /* (GRC A) */
             DCL        VAR(&PRTN)   TYPE(*CHAR) LEN(8)           /* (GRC A) */
             DCL        VAR(&PUSR)   TYPE(*CHAR) LEN(10)          /* (GRC A) */
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (720 A) */

/*  Check if user is authorized to use this option                   (GRC A) */

             IF         COND(&CLIENT *EQ &GRECO +
                                                  ) THEN(DO)      /* (GRC A) */
               CHGVAR     VAR(&PGMID) VALUE(PO200CL)              /* (GRC A) */
               CHGVAR     VAR(&PGMOPT) VALUE('*ALL')              /* (GRC A) */
               RTVJOBA    USER(&PUSR)                             /* (GRC A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN)
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (GRC A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (GRC A) */
                 RETURN                                           /* (GRC A) */
               ENDDO                                              /* (GRC A) */
             ENDDO                                                /* (GRC A) */


/*  Define work file to be used for display options.                    (417) */
/*    - Get unique member to use.                                       (417) */
/*    - Override file to use unique member.                             (417) */

             IF (&MEMBER = ' ') DO                                   /* (417) */
              CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER) /* (417) */
             ENDDO                                                   /* (417) */

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)       /* (417) */

/*  On with the show ... */

             CALL       PGM(&PGM)                      /* 415aM */
         /*  CALL       PGM(&PGM) PARM(&LINES)            415aD */

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

/*  Clean up before leaving                                             (417) */

             DLTOVR     FILE(WORKOPT)                                /* (417) */
             RCLRSC     LVL(*CALLER)                                 /* (417) */
             CLRPFM     FILE(WORKOPT) MBR(&MEMBER)                   /* (417) */

             ENDPGM
