/*------------------------------------------------------------------*/
/*  English Version (Spanish version is FTPMSGDSP)                  */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  FTPMSGD     Create PIRMSGF Message Descriptions FTpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  04 March 1999                                                   */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  09/14/00  DAS 4.14  Add FTP0003 message.                        */
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

/*  FTP0001 FTP unable to log in. */

             CHGVAR     VAR(&MSGID) VALUE('FTP0001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('FTP +
                          unable to log in. Retry FTP for &1') +
                          SECLVL('''Cause . . . . . :   FTP server +
                          rejected log in. &N Recovery  . . . :   +
                          Verify the user id and password in the +
                          FTP options. Retry the FTP export by +
                          going to the FTP menu and taking the +
                          Retry FTP Export option. Enter &1 for the +
                          member to export.') SEV(30) FMT((*CHAR 10))
             ENDDO

/*  FTP0002 FTP export failed.  At least one file not transfered. */

             CHGVAR     VAR(&MSGID) VALUE('FTP0002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('FTP +
                          export failed. At least one file not +
                          transfered. Member &1') SECLVL('Cause . . +
                          . . . :   At least one file was not +
                          exported to FTP server. &N Recovery  . . +
                          . :   From the FTP menu take the option +
                          to View FTP Export Log and view member +
                          &1.  Correct the problem and retry the +
                          export by taking option Retry FTP Export. +
                          Enter &1 for the member to export.') +
                          SEV(30) FMT((*CHAR 10))
             ENDDO

/*  FTP0003 FTP export failed.  View export log. */

             CHGVAR     VAR(&MSGID) VALUE('FTP0003')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('FTP +
                          export failed. View FTP log for member +
                          &1') SECLVL('Cause . . . . . :   At least +
                          one error occured during the FTP export. +
                          &N Recovery  . . . :   View the FTP log +
                          for member &1.  Correct the problem and +
                          retry the export by taking option Retry +
                          FTP Export. Enter &1 for the member to +
                          export.') SEV(30) FMT((*CHAR 10))
             ENDDO

             RETURN
             ENDPGM
