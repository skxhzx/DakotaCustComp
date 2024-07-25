/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CU700HCL  Call all history cleanup programs                      */
/*  12 January 2012                                                  */
/*  Lynn McMahon                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    01/12/12  LMC  6.40                                            */
/*      - Created. copied from CU700CL                               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions:                                         */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CU700CL:    PGM        PARM(&CMD &WHSE &DATEIN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10)
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

/* Get Client ID */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information. */

             RTVJOBA    USER(&USER) TYPE(&TYPE)


/*  Remove exported item adjustments */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Adjustments: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(IT750HCL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Adjustments: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove exported customer returns */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Returns: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(OR760HCL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Returns: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove exported PO's */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin PO: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(PO750HCL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End PO: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

/*  Remove route records */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Route: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(RT750HCL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Route: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)


/*  Remove misc labels & transactions */

             CHGVAR     VAR(&DATE) VALUE(&DATEIN)

             CHGVAR     VAR(&MSG) VALUE('** Begin Misc: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)

             CALL       PGM(PT780HCL) PARM(&CMD &WHSE &DATE)

             CHGVAR     VAR(&MSG) VALUE('End Misc: ' *CAT &CMD +
                          *BCAT '/' *CAT &WHSE *CAT '/' *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME)


/*  Start LICLOGH Cleanup   */
Liclogh:
             CHGVAR     VAR(&MSG) VALUE('** Begin LICLOGH cleanup: ' +
                          *CAT &CMD *BCAT '/' *CAT &WHSE *CAT '/' +
                          *CAT &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE))

             CALL       PGM(LL750HCL) PARM(&CMD &WHSE &DATEIN)


             CHGVAR     VAR(&MSG) VALUE('End LICLOGH cleanup: ' *CAT +
                          &CMD *BCAT '/' *CAT &WHSE *CAT '/' *CAT +
                          &DATE)
             SNDPGMMSG  MSG(&MSG) TOPGMQ(*SAME (* *NONE *NONE))


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
