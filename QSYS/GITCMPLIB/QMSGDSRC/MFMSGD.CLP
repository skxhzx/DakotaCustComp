/*------------------------------------------------------------------*/
/*  English Version (Spanish version is MFMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  MFMSGD      Create PIRMSGF Message Descriptions TKpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  19 September 2007                                               */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  09/17/07  DAS 5.10  Created                                     */
/*  09/24/07  LMC 5.10a Add msg's MF11001.                          */
/*  09/25/07  LMC 5.10b Add msg's MF12001.                          */
/*  10/08/07  LMC 5.10c Add msg's MF13201.                          */
/*  10/08/07  LMC 5.10d Add msg's MF13202.                          */
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


/*  MF11001 message description      */

             CHGVAR     VAR(&MSGID) VALUE('MF11001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          Delete Not Allowed.') SECLVL('Code +
                          Decipher Definition records exist.') +
                          SEV(30) FMT((*CHAR 50))
             ENDDO

/*  MF12001 message description      */

             CHGVAR     VAR(&MSGID) VALUE('MF12001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Option 12 is valid on non default +
                          definitions only') SEV(30) FMT((*CHAR 50))
             ENDDO
/*  MF13201 message description      */

             CHGVAR     VAR(&MSGID) VALUE('MF13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Mfr +
                          Item/Dakota Item already exists for def# +
                          &1') SEV(30) FMT((*CHAR 2))
             ENDDO
/*  MF13202 message description      */

             CHGVAR     VAR(&MSGID) VALUE('MF13202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Mfr +
                          Item already exists for def# +
                          &1') SEV(30) FMT((*CHAR 2))
             ENDDO
             RETURN
             ENDPGM
