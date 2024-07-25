/*------------------------------------------------------------------*/
/*  English Version (Spanish version is WLMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/********************************************************************/
/*                                                                  */
/*  WLMSGF      Create WLMSGF Message Descriptions WLpppnn          */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*  17 October 1997                                                 */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  10/04/00  DAS 4.14  Added message WL11222, WL11223, WL11224.    */
/*                                                                  */
/********************************************************************/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')


/*  WL11221 Starting slot number must be odd. */

             CHGVAR     VAR(&MSGID) VALUE('WL11221')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Starting Slot Number must be an odd +
                          number.') SECLVL('Cause . . . . . :   The +
                          value you entered is an even number but +
                          the slot creation program assumes that +
                          the first slot created will be on the +
                          left and will be an odd number. &N +
                          Recovery  . . . :   Enter a value that is +
                          an odd number.') SEV(30)
             ENDDO

/*  WL11222 Only 99 rack positions can be defined. */

             CHGVAR     VAR(&MSGID) VALUE('WL11222')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Only +
                          999 rack positions can be defined.') +
                          SECLVL('Cause . . . . . :   You are +
                          trying to add a new rack position but the +
                          maximum (999) rack positions have already +
                          been defined. &N Recovery  . . . :   +
                          Create a new aisle for the rack positions +
                          over 999.') SEV(30)
             ENDDO

/*  WL11223 Rack would cause slot location overflow. */

             CHGVAR     VAR(&MSGID) VALUE('WL11223')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Rack +
                          would cause slot location to overflow.') +
                          SECLVL('Cause . . . . . :   The next slot +
                          location to be utilized by a new rack +
                          would be &1. The maximum slot location is +
                          999. &N Recovery  . . . :   Either start +
                          a new aisle or try reducing the side +
                          increment value, which is currently &2.') +
                          SEV(30) FMT((*DEC 5) (*DEC 3))
             ENDDO

/*  WL11224 Number of racks on one side cause slot location overflow */

             CHGVAR     VAR(&MSGID) VALUE('WL11224')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Number of racks on one side cause +
                          slot location overflow.') SECLVL('Cause . +
                          . . . . :   The highest slot location to +
                          be created based on the number of racks +
                          on one side would be &1. The maximum slot +
                          location is 999. &N Recovery  . . . :   +
                          Either reduce the number of racks on one +
                          side or try reducing the side increment, +
                          which is &2.') SEV(30) FMT((*DEC 5) (*DEC 3))
             ENDDO

             RETURN
             ENDPGM
