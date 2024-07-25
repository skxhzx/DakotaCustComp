/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RN120CL   Customer returns                                       */
/*  11 October 1994                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/23/96  DAS  2.13                                            */
/*      - Added parameter to RN120.                                  */
/*    11/13/01  RH   4.16d                                           */
/*      - Added parameter to RN120CL for quick returns Y/N           */
/*                                                                   */
/*    08/18/08  MLB  5.20                                            */
/*      - Enh: Added client custom code support to pgm.              */
/*                                                                   */
/*    07/28/11  MLB  6.40                                            */
/*      - Fix: Revised program to call GETUNQMEM before calling      */
/*        so that caller gets unique member for WORKOPT file.        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Renzi Foodservice                       */
/*                                                                   */
/*    04/13/12  MLB  RNZ                                             */
/*      - Revised pgm to not allow users access to full returns.     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Farmboy                                 */
/*                                                                   */
/*    04/13/17  RH   FBYa                                            */
/*      - ENH: Add Farmboy to Renzie to check authorization.         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Sofo Foods                              */
/*                                                                   */
/*    04/10/18  MLB  SOF                                             */
/*      - Revised pgm to not allow users access to full returns.     */
/*      - Added SOF to RNZ mod.                                      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 RN120CL:    PGM        PARM(&QUICK) /* Y/N for Quick return */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/* Client ID's                                                       (520 A) */
             DCL        VAR(&CLIENT)    TYPE(*CHAR) LEN(10)       /* (520 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)       /* (520 A) */

/*RNZ A*/    DCL        VAR(&RENZI) TYPE(*CHAR) LEN(10) +
                          VALUE('RENZI')
/*FBY A*/    DCL        VAR(&FBY) TYPE(*CHAR) LEN(10) +
                          VALUE('FARMBOY')
/*SOF A*/    DCL        VAR(&SOFOFOODS) TYPE(*CHAR) LEN(10) +
                          VALUE('SOFOFOODS')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE)   TYPE(*CHAR) LEN(10) VALUE(WORKOPT) +
                                                                  /* (640 A) */
             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)          /* (640 A) */
             DCL        VAR(&QUICK) TYPE(*CHAR) LEN(1)
             DCL        VAR(&NOAUTHRZE) TYPE(*CHAR) LEN(60) +
                          VALUE('   You are not authorized to use +
                          this option.')                          /* (RNZ A) */
             DCL        VAR(&PGMID)      TYPE(*CHAR) LEN(10)      /* (RNZ A) */
             DCL        VAR(&PGMOPT)     TYPE(*CHAR) LEN(20)      /* (RNZ A) */
             DCL        VAR(&PRTN)       TYPE(*CHAR) LEN(8)       /* (RNZ A) */
             DCL        VAR(&PUSR)       TYPE(*CHAR) LEN(10)      /* (RNZ A) */
/*-------------------------------------------------------------------(520 A) */
/*  Retrieve Client ID info.                                         (520 A) */
/*                                                                   (520 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (520 A) */
/*                                                                   (520 A) */
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Check if user is authorized to use this option                   (RNZ A) */

             CHGVAR     VAR(&PGMID) VALUE(RN120CL)                /* (RNZ A) */
             RTVJOBA    USER(&PUSR)                               /* (RNZ A) */
             IF         COND(&CLIENT *EQ &RENZI +
                        *OR  &CLIENT *EQ &FBY +
                        *OR  &CLIENT *EQ &SOFOFOODS)  THEN(DO)    /* (SOF M) */
             IF         COND(&QUICK *NE 'Y')  THEN(DO)            /* (RNZ A) */
               CALL       PGM(CHKLIST) PARM(&PGMID &PGMOPT &PUSR &PRTN) +
                                                                  /* (RNZ A) */
               IF         COND(&CLIENT *EQ &SOFOFOODS)  THEN(DO)  /* (SOF A) */
/*               Do not allow any Sofo user access to full rtns.     (SOF A) */
                 CHGVAR     VAR(&PRTN) VALUE('*NO')               /* (SOF A) */
               ENDDO                                              /* (SOF A) */
               IF         COND(&PRTN *EQ '*NO')  THEN(DO)         /* (RNZ A) */
                 SNDPGMMSG  MSG(&NOAUTHRZE) MSGTYPE(*INFO)        /* (RNZ A) */
                 RETURN                                           /* (RNZ A) */
               ENDDO                                              /* (RNZ A) */
             ENDDO                                                /* (RNZ A) */
             ENDDO                                                /* (RNZ A) */

/*    - Get unique member to use.                                    (640 A) */
                                                                  /* (640 A) */
             CALL       PGM(GETUNQMEM) PARM(*REUSE &FILE &MEMBER) /* (640 A) */

/*  On with the show ... */

             OVRDBF     FILE(&FILE) MBR(&MEMBER) SHARE(*YES)      /* (640 A) */
             CALL       PGM(RN120) PARM('*RETURN ' &QUICK)

/*  Clean up before leaving                                          (640 A) */

             DLTOVR     FILE(&FILE)                               /* (640 A) */
             MONMSG     MSGID(CPF9841)                            /* (640 A) */

             RCLRSC     LVL(*CALLER)
             RMVM       FILE(&FILE) MBR(&MEMBER)                  /* (640 A) */
             MONMSG     MSGID(CPF320A CPF3203 CPF3220 CPF3273 +
                          CPF7301 CPF7310) /* Ignore not removed.    (640 A) */

             ENDPGM
