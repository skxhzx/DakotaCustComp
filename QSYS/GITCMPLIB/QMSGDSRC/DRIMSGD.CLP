/*------------------------------------------------------------------*/
/*  English Version (Spanish version is DRIMSGDSP)                  */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  DRIMSGD     Create PIRMSGF Message Descriptions DRInnnn         */
/*                 where nnnn = Error message id (0001-9999)        */
/*              Dakota realtime interface messages                  */
/*                                                                  */
/*  02 October 2001                                                 */
/*  Dave Sommerville                                                */
/*                                                                  */
/*------------------------------------------------------------------*/
/*  Revisions                                                       */
/*                                                                  */
/*    10/02/01  DAS  4.16                                           */
/*      - Created                                                   */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE('*LIBL')
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  Default option to *ALL */

             IF (&OPT *EQ ' ') THEN(DO)
               CHGVAR     VAR(&OPT) VALUE('*ALL')
             ENDDO

/*  DRI0001 Local errorr */

             CHGVAR     VAR(&MSGID) VALUE('DRI0001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1') +
                          SECLVL('Cause . . . . . :   Local system +
                          returned above message with error code &2 +
                          calling &3/&4. When the error message +
                          starts with "U:" the information +
                          following is +
                          "program(statement)-description". &N +
                          Recovery  . . . :   Correct the situation +
                          that caused the error and try again.') +
                          SEV(30) FMT((*CHAR 60) (*CHAR 10) (*CHAR +
                          10) (*CHAR 10))
             ENDDO

/*  DRI0002 Host error */

             CHGVAR     VAR(&MSGID) VALUE('DRI0002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Host: &1') SECLVL('Cause . . . . . +
                          :   Host system returned above message +
                          with error code &2 calling &3/&4. When +
                          the error message includes "U:" the +
                          information that follows it is +
                          "program(statement)-description". &N +
                          Recovery  . . . :   Correct the situation +
                          that caused the error on the host and try +
                          again.') SEV(30) FMT((*CHAR 60) (*CHAR +
                          10) (*CHAR 10) (*CHAR 10))
             ENDDO

             RETURN
             ENDPGM
