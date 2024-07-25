/*-------------------------------------------------------------------*/
/*                                                                   */
/*  MS700CL   Call Miscellaneous cleanup programs                    */
/*  16 January 2012                                                  */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/16/12  LMC  6.40                                            */
/*      - Created. Cleans up RTEUNDO,CWEXCP and VSLEXCP              */
/*                                                                   */
/*    02/18/12  LMC  6.40A                                           */
/*      - Fix: Remove the unnecessary chgvar on &date                */
/*                                                                   */
/*    02/07/13  LMC  6.50a                                           */
/*      - Enh: Add cleanup for RTETRCK                               */
/*                                                                   */
/*    07/26/13  JCJ  6.50b                                           */
/*      - Enh: Add cleanup for DDLOG                                 */
/*                                                                   */
/*    09/09/14  LMC  6.50C                                           */
/*      - Enh: Add cleanup for PGMTRCK                               */
/*                                                                   */
/*    06/16/15  NLK  7.00a                                           */
/*      - Enh: Add cleanup for GloRteLog MS757CL                     */
/*                                       (was pgm MS756 from USF)    */
/*                                                                   */
/*    01/26/16  LMC  7.00b                                           */
/*      - Enh: Add cleanup for PIRTRAND - status 'X'                 */
/*    03/26/19  LMC  7.30a                                           */
/*      - Enh: Add cleanup for HACCPLOG                              */
/*      - Enh: Add cleanup for PIRTRAND - status 'B'                 */
/*      - Enh: Add cleanup for PIRTRAND - BEGDAY/ENDDAY              */
/*    08/21/19  LMC  7.30b                                           */
/*      - Enh: Add cleanup for BFCDEBUG                              */
/*    02/26/20  LMC  7.40a                                           */
/*      - Enh: Add cleanup for UPCLOGD                               */
/*    06/15/21  LMC  7.50a                                           */
/*      - Enh: Add cleanup for PLTLCNS                               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*    --/--/--  ---  ---                                             */
/*      - desc                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 MS700CL:    PGM        PARM(&CMD)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (640cA) */


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (640cA) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (640cA) */
             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATE)       TYPE(*CHAR) LEN(8)
             DCL        VAR(&DATEIN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/* Get Client ID */                                               /* (640cA) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (640cA) */


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)


/*  Remove RTEUNDO */

  /*          CHGVAR     VAR(&DATE) VALUE(&DATEIN)  640aD */

             CHGVAR     VAR(&MSG) VALUE('** Begin RTEUNDO ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS750CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End RETUNDO:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)


/*  Remove CWEXCP */

  /*          CHGVAR     VAR(&DATE) VALUE(&DATEIN)  640aD */

             CHGVAR     VAR(&MSG) VALUE('** Begin CWEXCP ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS751CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End CWEXCP:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove VSLEXCP */

  /*          CHGVAR     VAR(&DATE) VALUE(&DATEIN)  640aD */

             CHGVAR     VAR(&MSG) VALUE('** Begin VSLEXCP ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS752CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End VSLEXCP:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove ITMEXCP */

  /*          CHGVAR     VAR(&DATE) VALUE(&DATEIN)  640aD */

             CHGVAR     VAR(&MSG) VALUE('** Begin ITMEXCP ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS753CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End ITMEXCP:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove RTETRCK 6.50a */


             CHGVAR     VAR(&MSG) VALUE('** Begin RTETRCK ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS754CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End RTETRCK:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove DDLOG   6.50b */


             CHGVAR     VAR(&MSG) VALUE('** Begin DDLOG   ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS755CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End DDLOG:  ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove PGMTRCK 6.50c */


             CHGVAR     VAR(&MSG) VALUE('** Begin PGMTRCK ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS756CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End PGMTRCK:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove GloRteLog 7.00a */


             CHGVAR     VAR(&MSG) VALUE('** Begin GloRteLog')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS757CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End GloRteLog:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove PIRTRAND status X */


             CHGVAR     VAR(&MSG) VALUE('** Begin PIRTRAND ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS758CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End PIRTRAND:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove HACCPLOG   7.30a */


             CHGVAR     VAR(&MSG) VALUE('** Begin HACCPLOG')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(HA755CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End HACCPLOG')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove PIRTRAND status B */


             CHGVAR     VAR(&MSG) VALUE('** Begin PIRTRAND ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS759CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End PIRTRAND:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)


/*  Remove PIRTRAND BEGDAY/ENDDAY  */


             CHGVAR     VAR(&MSG) VALUE('** Begin PIRTRAND ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS760CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End PIRTRAND:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove BFCDEBUG   7.30b */


             CHGVAR     VAR(&MSG) VALUE('** Begin BFCDEBUG')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS761CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End BFCDEBUG')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove UPCLOGD  7.40a          */


             CHGVAR     VAR(&MSG) VALUE('** Begin UPCLOGD ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS762CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End UPCLOGD:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove PLTLCNS  7.50a          */


             CHGVAR     VAR(&MSG) VALUE('** Begin PLTLCNS ')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(MS763CL) PARM(&CMD)

             CHGVAR     VAR(&MSG) VALUE('End PLTLCNS:')
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Receive any messages and pass them on  */

 GETOUT:
 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))
             IF         COND(&TYPE = '0') THEN(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) TOUSR(&USER) MSGTYPE(*COMP)
                ENDDO
             ELSE       CMD(DO)
                SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                            MSGDTA(&MSGDTA) MSGTYPE(*COMP)
                ENDDO
             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
