/*------------------------------------------------------------------*/
/*  English Version (Spanish version is PLMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  PLMSGD      Create PIRMSGF Message Descriptions PLpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  02 MAY, 1996                                                    */
/*  Hemant Kapadia                                                  */
/*  12/16/98  RH  4.10  Add TH11202 message.                       */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  PL11201 Cannot build a pattern.          */

             CHGVAR     VAR(&MSGID) VALUE('PL11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot build a pattern for this tie +
                          value.') SECLVL('Cause . . . . . :   The +
                          tie value is very large to build a +
                          pattern in a 10 x 10 pallet grid. &N +
                          Recovery  . . . :   Select another +
                          package and try your request again.') SEV(30)
             ENDDO

/*  TH11201 Pattern not found for tie.              */

             CHGVAR     VAR(&MSGID) VALUE('TH11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Pattern not found for selected tie +
                          (&1).') SECLVL('Cause . . . . . :   +
                          Pattern to match the selected tie not +
                          found. &N Recovery  . . . :   Select +
                          another tie value and try the command +
                          again.') SEV(30) FMT((*DEC 3 0))
             ENDDO

/*  TH11202 Pattern can not be displayed for tie.              */

             CHGVAR     VAR(&MSGID) VALUE('TH11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Pattern cannot be displayed for tie +
                          (&1).') SECLVL('Cause . . . . . :   +
                          Pattern to match the selected tie cannot +
                          be displayed. &N Recovery  . . . :   +
                          None.') SEV(30) FMT((*DEC 3 0))
             ENDDO


             RETURN
             ENDPGM
