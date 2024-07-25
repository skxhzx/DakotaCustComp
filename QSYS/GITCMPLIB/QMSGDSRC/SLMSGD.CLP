/*------------------------------------------------------------------*/
/*  English Version (Spanish version is SLMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  SLMSGD      Create PIRMSGF Message Descriptions SLpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*   08/23/99  MLB 4.12  Add messages SL16021                       */
/*   01/28/00  DAS 4.13  Add messages SL25201, SL25202, SL25203     */
/*                                    SL25273, SL25274              */
/*   06/12/02  RH  4.16  Add messages SL15201                       */
/*   09/26/02  RH  4.16  Add messages SL26201                       */
/*   12/04/02  RH  4.16  Add messages SL11206                       */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  CRT0001 Creating slots. */

             CHGVAR     VAR(&MSGID) VALUE('CRT0001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Creating slots.') SECLVL('No further +
                          information for this message.') SEV(00)
             ENDDO

/*  CRT0002 Slots created. */

             CHGVAR     VAR(&MSGID) VALUE('CRT0002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots created.') SECLVL('No further +
                          information for this message.') SEV(00) +
                          FMT((*DEC 5))
             ENDDO

/*  CVT0010 Slot number entered incorrectly. */

             CHGVAR     VAR(&MSGID) VALUE('CVT0010')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          &1 was entered incorrectly (invalid +
                          &2).') SECLVL('Cause . . . . . :   Slot +
                          &1 was not entered in the correct format +
                          because an invalid &2 was entered. &N +
                          Recovery  . . . :   Enter the slot using +
                          the following format: &3.') SEV(30) +
                          FMT((*CHAR 12) (*CHAR 15) (*CHAR 23))
             ENDDO

/*  SL11001 Slot display already exists. */

             CHGVAR     VAR(&MSGID) VALUE('SL11001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          display &1 already exists.') +
                          SECLVL('Cause . . . . . :   The slot +
                          display value must be unique. &N +
                          Recovery  . . . :   Enter a unique value +
                          for the slot display.') SEV(30) +
                          FMT((*CHAR 12))
             ENDDO

/*  SL11201 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   Status code +
                          cannot be changed from ''A'', to ''V'', +
                          as there is some quantity still available +
                          in this slot.  &N Recovery  . . . :   +
                          Retain the active status of the slot.') +
                          SEV(30)
             ENDDO

/*  SL11202 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   Status code +
                          cannot be changed from ''A'', to ''Z'', +
                          as there is some quantity still available +
                          in this slot.  &N Recovery  . . . :   +
                          Press F9 to view the slot quantities.') +
                          SEV(30)
             ENDDO

/*  SL11203 When status is changed to 'Active', an item number  */
/*          must be entered.                                    */

             CHGVAR     VAR(&MSGID) VALUE('SL11203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          number must be entered for active slot.') +
                          SECLVL('Cause . . . . . :   Item number +
                          must be entered, for slot status "A" +
                          (Active).  &N Recovery  . . . :   Enter a +
                          valid item number and try your request +
                          again.') SEV(30)
             ENDDO

/*  SL11204 An active Pick slot already exists  for this item in the */
/*          fixed section.                                           */

             CHGVAR     VAR(&MSGID) VALUE('SL11204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('An +
                          active pick slot already exists for this +
                          item in the fixed section.') +
                          SECLVL('Cause . . . . . :   An active +
                          Pick slot &1 already exists for this item +
                          in the fixed section. You cannot have +
                          more than one active picking slot for an +
                          item in the fixed section. &N Recovery  . +
                          . . :   Retain the non active status of +
                          the slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  SL11205 Maximum number of pick slots allowed for item has been   */
/*          reached.                                                 */

             CHGVAR     VAR(&MSGID) VALUE('SL11205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Maximum number of pick slots already +
                          assigned to this item.') SECLVL('Cause +
                          . . . . . :   You have tried to assign an +
                          item to more pick slots than is allowed +
                          for this item.  The maximum number of +
                          pick slots allowed for this item is &1.  &N +
                          Recovery  . . . :   Change the slot to +
                          Pick=N or assign the item to a +
                          non-picking slot. Then try your request +
                          again.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  SL11206 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL11206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   Status code +
                          cannot be changed from ''A'', to ''V'', +
                          use verify programs to verify slot. +
                          &N Recovery  . . . :   +
                          Retain the current status of the slot.') +
                          SEV(30)
             ENDDO

/*  SL11207 Slot inactive. */

             CHGVAR     VAR(&MSGID) VALUE('SL11207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot inactive.') +
                          SECLVL('Cause . . . . . :   Status code +
                          is inactive, select active slot +
                          &N Recovery  . . . :   +
                          Select active slot or change status.') +
                          SEV(30)
             ENDDO

/*  SL11401 Slot can't be deleted because qty <> 0. */

             CHGVAR     VAR(&MSGID) VALUE('SL11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          &1 not deleted.') SECLVL('Cause . . . . . +
                          :   Slot &1 could not be deleted because +
                          there is a quantity attached to it. &N +
                          Recovery  . . . :   Use adjustment +
                          program to reduce quantity(s) to zero and +
                          try again.') SEV(10) FMT((*CHAR 12))
             ENDDO

/*  SL13201 Invalid slot entered.  */

             CHGVAR     VAR(&MSGID) VALUE('SL13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('PIR +
                          slot is not valid') SECLVL('Cause . . . . +
                          . :   Slot ''&1-&2-&3&4'' is not valid. +
                          &N Recovery  . . . :   The first part of +
                          the slot field is the aisle code. It is +
                          alphanumeric and can not be blank. The +
                          second part is the slot location within +
                          the aisle. It is numeric and must be +
                          greater than zero. The third part +
                          identifies the rack level. It is numeric +
                          and must be greater than zero. The last +
                          part is the handstack indicator. It is +
                          alphanumeric and is optional.') SEV(30) +
                          FMT((*CHAR 3) (*DEC 3 0) (*DEC 3 0) +
                          (*CHAR 2))
             ENDDO

/*  SL13202 PIR slot already exists.  */

             CHGVAR     VAR(&MSGID) VALUE('SL13202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          already exists as a &5 slot.') +
                          SECLVL('Cause . . . . . :   Slot +
                          ''&1-&2-&3&4'' already exists as a &5 +
                          slot. &N Recovery  . . . :   Enter a +
                          different slot number to create or press +
                          F12 to cancel.') SEV(30) FMT((*CHAR 3) +
                          (*DEC 3 0) (*DEC 3 0) (*CHAR 2) (*CHAR 5))
             ENDDO

/*  SL13210 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL13210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   Status code +
                          entered is not ''A'', ''V'' or +
                          ''Z''. &N Recovery  . . . :   Enter +
                          ''A'' (Active), ''V'' (Verified) +
                          or ''Z'' (Zeroed).') SEV(30)
             ENDDO

/*  SL14201 Invalid slot entered.  */

             CHGVAR     VAR(&MSGID) VALUE('SL14201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Fixed slot is not valid') +
                          SECLVL('Cause . . . . . :   Slot +
                          ''&1-&2-&3&4'' is not valid. &N Recovery  +
                          . . . :   The first part of the slot +
                          field is the aisle code. It is +
                          alphanumeric and can not be blank. The +
                          second part is the slot location within +
                          the aisle. It is numeric and must be +
                          greater than zero. The third part +
                          identifies the rack level. It is numeric +
                          and must be greater than zero. The last +
                          part is the handstack indicator. It is +
                          alphanumeric and is optional.') SEV(30) +
                          FMT((*CHAR 3) (*DEC 3 0) (*DEC 3 0) +
                          (*CHAR 2))
             ENDDO

/*  SL14202 PIR slot already exists.  */

             CHGVAR     VAR(&MSGID) VALUE('SL14202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          already exists as a &5 slot.') +
                          SECLVL('Cause . . . . . :   Slot +
                          ''&1-&2-&3&4'' already exists as a &5 +
                          slot. &N Recovery  . . . :   Enter a +
                          different slot number to create or press +
                          F12 to cancel.') SEV(30) FMT((*CHAR 3) +
                          (*DEC 3 0) (*DEC 3 0) (*CHAR 2) (*CHAR 5))
             ENDDO

/*  SL14210 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL14210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   Status code +
                          entered is not ''A'', ''V'' or ''Z''. &N +
                          Recovery  . . . :   Enter ''A'' (Active), +
                          ''V'' (Verified) or ''Z'' (Zeroed).') SEV(30)
             ENDDO

/*  SL14211 Invalid status code entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL14211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   When a fixed +
                          slot is reserved for one item the only +
                          valid status is ''A''. &N Recovery  . . . +
                          :   Enter ''A'' (Active) for the status +
                          code.') SEV(30)
             ENDDO

/*  SL15021 Invalid slot type entered. */

             CHGVAR     VAR(&MSGID) VALUE('SL15021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot type entered') +
                          SECLVL('Cause . . . . . :   Slot type +
                          must be a ''F'' or ''P''. &N Recovery  . +
                          . . :   Enter ''F'' for fixed or ''P'' +
                          for PIR.') SEV(30)
             ENDDO


/*  SL15201 Slots verified.                */

             CHGVAR     VAR(&MSGID) VALUE('SL15201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots successfully verified.') +
                          SECLVL('Cause . . . . . :   &1 slots +
                          successfully verified. &N Recovery  . . . +
                          :   Not required.') SEV(10) FMT((*DEC 5 0))
             ENDDO

/*  SL15421 Slot verified. */

             CHGVAR     VAR(&MSGID) VALUE('SL15421')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          verified.') SECLVL('No further +
                          information for this message.') SEV(00) +
                          FMT((*CHAR 50))
             ENDDO

/*  SL15422 Slot can't be verified.   */

             CHGVAR     VAR(&MSGID) VALUE('SL15422')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot can not be verified.') +
                          SECLVL('Cause . . . . . :   The slot +
                          has virtual slots associated with it. +
                          &N Recovery  . . . : Not required.') SEV(10)
             ENDDO

/*  SL16001 No more zero slots.            */

             CHGVAR     VAR(&MSGID) VALUE('SL16001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          more zero slots.') SECLVL('Cause . . +
                          . . . :   There are no more zero slots +
                          for the selected department or aisle.  &N +
                          Recovery  . . . :   Press F12 to cancel +
                          and enter new department or press F3 to +
                          exit.') SEV(30)
             ENDDO


/*  SS11401 Slot status code cannot be deleted. */

             CHGVAR     VAR(&MSGID) VALUE('SS11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          status code not deleted.') SECLVL('Cause +
                          . . . . . :   Status code ''A'', ''I'', +
                          ''V'' or ''Z'' cannot be deleted. &N +
                          Recovery  . . . :   No recovery.  Contact +
                          your DP manager for more information.') +
                          SEV(10)
             ENDDO

/*  SL21201 Cannot enter item number for a verified slot status. */

             CHGVAR     VAR(&MSGID) VALUE('SL21201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot enter item number for a slot +
                          with a status of ''V'' (Verified).') +
                          SECLVL('Cause . . . . . :   You are +
                          trying to enter an item number for a slot +
                          that has a status of ''V''. &N Recovery  +
                          . . . :   Either change the status to +
                          other than ''V'', or leave the item +
                          number blank, and then try your request +
                          again.') SEV(30)
             ENDDO

/*  SL22201 Slots cannot be deleted.                 */

             CHGVAR     VAR(&MSGID) VALUE('SL22201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete selected slots.') +
                          SECLVL('Cause . . . . . :   The group of +
                          slots that you are trying to delete, has +
                          &1 slots that contain items. Slots have +
                          to be empty for delete. &N Recovery  . . +
                          . :   Enter another group of slots and +
                          try your request again.') SEV(30) +
                          FMT((*DEC 5 0))
             ENDDO

/*  SL22202 Slots deleted.                 */

             CHGVAR     VAR(&MSGID) VALUE('SL22202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots successfully deleted.') +
                          SECLVL('Cause . . . . . :   &1 slots +
                          successfully deleted. &N Recovery  . . . +
                          :   Not required.') SEV(10) FMT((*DEC 5 0))
             ENDDO

/*  SL22203 Checking for active slots.     */

             CHGVAR     VAR(&MSGID) VALUE('SL22203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Checking for active slots.  Please +
                          be patient.') SEV(10)
             ENDDO

/*  SL22204 Deletint slots.                */

             CHGVAR     VAR(&MSGID) VALUE('SL22204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Deleting slots.  Please be +
                          patient.') SEV(10)
             ENDDO

/*  SL23201 Invalid status code entered.             */

             CHGVAR     VAR(&MSGID) VALUE('SL23201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid status code entered.') +
                          SECLVL('Cause . . . . . :   Status code +
                          entered is other than ''V'', ''Z'', +
                          ''I''.   &N Recovery  . . . :   Enter a +
                          valid status code and try your request +
                          again.  Valid status codes are +
                          V=Verified, Z=Zero, and I=Inactive.') SEV(30)
             ENDDO


/*  SL23202 Slots status cannot be changed.          */

             CHGVAR     VAR(&MSGID) VALUE('SL23202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          status cannot be changed.') SECLVL('Cause +
                          . . . . . :   The group of slots that you +
                          are trying to change the status of, has +
                          &1 active slots.  Status of active slots +
                          cannot be changed. &N Recovery  . . . :   +
                          Enter another group of slots and try your +
                          request again.') SEV(30) FMT((*DEC 5 0))
             ENDDO

/*  SL23203 Slot status changed.           */

             CHGVAR     VAR(&MSGID) VALUE('SL23203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Status of &2 slots successfully +
                          changed, &1 slots unable to change') +
                          SECLVL('Cause . . . . . :   Status of &2 +
                          slots successfully changed, &1 slots +
                          unable to change. &N Recovery  . . . :   +
                          Not required.') SEV(10) FMT((*DEC 5 0) +
                          (*DEC 5 0))
             ENDDO

/*  SL23204 Checking for active slots.     */

             CHGVAR     VAR(&MSGID) VALUE('SL23204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Checking for active slots.  Please +
                          be patient.') SEV(10)
             ENDDO

/*  SL23205 Changing slot status.          */

             CHGVAR     VAR(&MSGID) VALUE('SL23205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Changing slot status.  Please be +
                          patient.') SEV(10)
             ENDDO

/*  SL23206 Can't change from status code 'A'        */

             CHGVAR     VAR(&MSGID) VALUE('SL23206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Can not change from status A.') +
                          SECLVL('Cause . . . . . :   Status code +
                          entered is other than ''V'', ''Z'', +
                          ''I''.   &N Recovery  . . . :   Enter a +
                          valid status code and try your request +
                          again.  Valid status codes are +
                          V=Verified, Z=Zero, and I=Inactive.') SEV(30)
             ENDDO

/*  LP11022 License not on file. */

             CHGVAR     VAR(&MSGID) VALUE('LP11022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License is not on file.') +
                          SECLVL('Cause . . . . . :   The license +
                          is not found in the file. &N Recovery . . +
                          . . :   Check if warehouse is correct, enter +
                          a correct License.') SEV(30)
             ENDDO

/*  SL24201 Slot designation code changed. */

             CHGVAR     VAR(&MSGID) VALUE('SL24201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Designation code of &2 slots +
                          successfully changed.') SECLVL('Cause . . +
                          . . . :   Designation code of &2 slots +
                          successfully changed.  &N Recovery  . . . +
                          :   Not required.') SEV(10) FMT((*DEC 5 +
                          0) (*DEC 5 0))
             ENDDO

/*  SL24202 Changing slot designation code.*/

             CHGVAR     VAR(&MSGID) VALUE('SL24202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Changing slot designation code.  +
                          Please be patient.') SEV(10)
             ENDDO

/*  SL25201 Not allowed to change item - Non-stock qtys exist. */

             CHGVAR     VAR(&MSGID) VALUE('SL25201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Can +
                          not change item. Slot &1 contains +
                          non-stock quantities.') SECLVL('Cause . . +
                          . . . :   Slot &1 contains a quantity in +
                          the Allocated, Picked, Transfer or +
                          Receive quantity bucket. A slot''s item +
                          number can only be changed if those +
                          quantities are zero. &N Recovery  . . . +
                          :   Close any open transactions to reduce +
                          quantity(s) to zero and try again.') +
                          SEV(10) FMT((*CHAR 12))
             ENDDO

/*  SL25202 Item change completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('SL25202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 in slot &2 successfully changed to +
                          item &3.') SECLVL('Cause . . . . . :   +
                          Item &1 in slot &2 was successfully +
                          changed to item &3. The slot remained the +
                          same. Warehouse quanitites were adjusted +
                          for each item.  &N Recovery  . . . :   No +
                          recovery.  This is an informational +
                          message.') SEV(10) FMT((*CHAR 15) (*CHAR +
                          12) (*CHAR 15))
             ENDDO

/*  SL25203 Item change can not be made - Invalid status code' */

             CHGVAR     VAR(&MSGID) VALUE('SL25203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Change item is not allowed - Invalid +
                          slot status code.') SECLVL('Cause . . . . +
                          . :   Slot &1 has a status of &2. When +
                          changing an item, the status code can not +
                          be ''Z'' or ''V''. &N Recovery  . . . :   +
                          Select another slot or change status code +
                          of slot and try again.') SEV(40) +
                          FMT((*CHAR 12) (*CHAR 2))
             ENDDO

/*  SL25273 Item change could not be made - Slot was deleted. */

             CHGVAR     VAR(&MSGID) VALUE('SL25273')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          change could not be completed - Slot does +
                          not exist.') SECLVL('Cause . . . . . :   +
                          The slot you were trying to change the +
                          item for was deleted before you pressed +
                          Enter to make your adjustment. &N +
                          Recovery  . . . :   The slot must be +
                          recreated before you can make a change to +
                          it.  Press F12 to cancel this change and +
                          determine why the slot was deleted.') SEV(40)
             ENDDO

/*  SL25274 Item change can not be made - record is locked.' */

             CHGVAR     VAR(&MSGID) VALUE('SL25274')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          change could not be completed - Slot is +
                          being used.') SECLVL('Cause . . . . . :   +
                          Another user is already using the slot +
                          you are trying to change the item for and +
                          it can not be shared. &N Recovery  . . . +
                          :   Try again.  If you continue to +
                          receive this message contact you D.P. +
                          manager.') SEV(40)
             ENDDO

/*  SL26201 Slot priority code changed. */

             CHGVAR     VAR(&MSGID) VALUE('SL26201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Priority code of &2 slots +
                          successfully changed.') SECLVL('Cause . . +
                          . . . :   Priority code of &2 slots +
                          successfully changed.  &N Recovery  . . . +
                          :   Not required.') SEV(10) FMT((*DEC 5 +
                          0) (*DEC 5 0))
             ENDDO


             RETURN
             ENDPGM
