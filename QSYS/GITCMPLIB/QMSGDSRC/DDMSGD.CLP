/*------------------------------------------------------------------*/
/*  English Version (Spanish version is DDMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  DDMSGD      Create PIRMSGF Message Descriptions DDpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  24 April 1996                                                   */
/*  Dave Sommerville                                                */
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

/*  DD11505 Department/Slot types are being selected. */

             CHGVAR     VAR(&MSGID) VALUE('DD11505')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('New +
                          Department/Slot types are being created +
                          from Slot file.')
             ENDDO

/*  DD11506 Deleting existing Department/Slot types */

             CHGVAR     VAR(&MSGID) VALUE('DD11506')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Deleting existing Department/Slot +
                          types.')
             ENDDO

/*  DD11521 No records created. */

             CHGVAR     VAR(&MSGID) VALUE('DD11521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          records were created. Position cursor on +
                          this line and press F1.') SECLVL('Cause . +
                          . . . . :   The probable cause is that no +
                          slots exist for warehouse &1. &N +
                          Recovery  . . . :   Verify that slots +
                          exist for warehouse &1 and then try +
                          again.') SEV(30) FMT((*DEC 3 0))
             ENDDO

/*  DD11522 Records were created. */

             CHGVAR     VAR(&MSGID) VALUE('DD11522')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          Department/Slot types were created for +
                          warehouse &2') SEV(00) FMT((*DEC 7 0) +
                          (*DEC 3))
             ENDDO

/*  DD11523 Unmonitored error occured. */

             CHGVAR     VAR(&MSGID) VALUE('DD11523')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unmonitored error occured (&1).') +
                          SECLVL('Cause . . . . . :   The SQL +
                          selection did not complete because of +
                          error code &1. &N Recovery  . . . :   +
                          Report this to the D.P. manager.') +
                          SEV(30) FMT((*DEC 5 0))
             ENDDO

             RETURN
             ENDPGM
