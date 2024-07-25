/*------------------------------------------------------------------*/
/*                                                                  */
/*  ITMSGD      Create PIRMSGF Message Descriptions ITpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*  01/20/99  RH  4.10  Add IT11211 message.                        */
/*  06/15/99  HNK 4.11  Add IT16001 message.                        */
/*  06/18/99  HNK 4.11  Add IT12275 message.                        */
/*  06/21/99  HNK 4.11  Add IT12A01,IT12A02,IT12A03,IT12A04,IT12A05 */
/*  07/26/99  HNK 4.12  Add IT12001,IT12002.                        */
/*  08/05/99  RH  4.12  Add IT11212 message.                        */
/*  09/17/99  RH  4.12  Add IT13001 message.                        */
/*  09/20/99  RH  4.12  Add IT25202 message.                        */
/*  09/27/99  DAS 4.12  Add IT15204 message.                        */
/*  11/24/99  DAS 4.12  Add IT11001 message.                        */
/*  11/24/99  DAS 4.12  Revised IT13001 message.                    */
/*  01/26/00  DAS 4.13  Add IT26001 message.                        */
/*  01/31/00  MLB 4.13  Add IT12218 message.                        */
/*  02/09/00  HNK 4.13  Add IT25203 message.                        */
/*  02/24/00  MLB 4.13  Add IT13208 message.                        */
/*  02/28/00  DAS 4.13  Add IT13002 message.                        */
/*  03/20/00  MLB 4.14  Add IT13209 message.                        */
/*  03/27/00  HNK 4.13  Add IT25204 message.                        */
/*  03/29/00  HNK 4.13  Add IT25205 message.                        */
/*  08/01/00  RRH 4.14  Add IT25206 message.                        */
/*  08/02/00  RRH 4.14  Add IT25207 message.                        */
/*  10/06/00  MLB 4.14  Add IT27003 message.                        */
/*                      Add IT27004 message.                        */
/*  08/02/01  RH  4.15  Add IT13210 message.                        */
/*  10/12/01  HNK 4.16  Add IT11213,IT11214,IT11215,IT11216.        */
/*  10/19/01  HNK 4.16  Add IT11217.                                */
/*  10/17/02  RH  4.16c Add IT25208, IT25209                        */
/*  12/17/02  RH  4.16d Add IT31201                                 */
/*  04/01/03  RH  4.17a Add IT11218                                 */
/*  11/30/03  DAS 4.17b Add IT25210                                 */
/*  04/20/05  RH  5.00a Add IT11219                                 */
/*  11/13/08  RH  5.20a Add IT11220                                 */
/*  04/24/09  RH  5.20b Add IT13211                                 */
/*  06/02/09  RH  5.20c Add IT90001 (was missing from prev version) */
/*  03/18/15  RH  6.50A Add IT35202                                 */
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

/*  IT11001 Tie/High entry not allowed */

             CHGVAR     VAR(&MSGID) VALUE('IT11001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Tie/High entry not allowed for item +
                          &1. Use base item &3.') SECLVL('Cause . . +
                          . . . : Item &1 is type ''&2''. Tie/High +
                          entry is only allowed for item types '' +
                          '' and ''B'', which reside physically in +
                          slots within the warehouse. This error is +
                          to reinforce that item &1, type ''&2'' +
                          does not physically reside in a slot +
                          within the warehouse. &N Recovery  . . . +
                          :   Enter the Tie/High entry option next +
                          to item &3, the base for item &1.') +
                          SEV(30) FMT((*CHAR 15) (*CHAR 1) (*CHAR 15))
             ENDDO

/*  IT11021 Invalid section entered. */

             CHGVAR     VAR(&MSGID) VALUE('IT11021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid section entered') +
                          SECLVL('Cause . . . . . :   Section +
                          must be a ''F'' or ''P''. &N Recovery  . +
                          . . :   Enter ''F'' for fixed or ''P'' +
                          for PIR.') SEV(30)
             ENDDO

/*  IT11022 Invalid catch weight. */

             CHGVAR     VAR(&MSGID) VALUE('IT11022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid catch weight entered.') +
                          SECLVL('Cause . . . . . :   Catch weight +
                          must be a ''Y'' or ''N''. &N Recovery  . +
                          . . :   Enter a ''Y'' if a catch weight +
                          is needed or an ''N'' if it is not +
                          needed.') SEV(30)
             ENDDO

/*  IT11023 Warning: Cube is not with +/- range. */

             CHGVAR     VAR(&MSGID) VALUE('IT11023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Cube is not within +/- &7% +
                          of computer calculated cube.') +
                          SECLVL('Cause . . . . . :   The cube +
                          value entered (&5) is not within +/- &7% +
                          (&8) of the calculated cube for the +
                          dimensions entered (&1 * &2 * &3 / &6 = +
                          &4). &N Recovery  . . . :   You may press +
                          F20 to accept the warning with no change, +
                          enter a new value or use the Field Exit +
                          key to erase the cube value and have the +
                          computer calculate it for you.') SEV(00) +
                          FMT((*DEC 5 2) (*DEC 5 2) (*DEC 5 2) +
                          (*DEC 7 3) (*DEC 7 3) (*DEC 9 2) (*DEC 3 +
                          1) (*DEC 7 4))
             ENDDO

/*  IT11201 Matching pattern not found.             */

             CHGVAR     VAR(&MSGID) VALUE('IT11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Matching pattern not found.') +
                          SECLVL('Cause . . . . . :   Pattern to +
                          match the entered tie-high not found. &N +
                          Recovery  . . . :   Change the tie value +
                          and try the command again.') SEV(10)
             ENDDO

/*  IT11202 Item number must be entered.            */

             CHGVAR     VAR(&MSGID) VALUE('IT11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Full +
                          case item number cannot be blank.') +
                          SECLVL('Cause . . . . . :   Full case +
                          item number must be entered, if broken +
                          case item option is ''Y''. &N Recovery  . +
                          . . :   Enter a valid item number and try +
                          your request again.') SEV(30)
             ENDDO

/*  IT11203 Item number must be valid.            */

             CHGVAR     VAR(&MSGID) VALUE('IT11203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Full +
                          case item number entered is invalid.') +
                          SECLVL('Cause . . . . . :   Full case +
                          item number does not exist in the item +
                          file. &N Recovery  . . . :   Enter a +
                          valid item number and try your request +
                          again.') SEV(30)
             ENDDO

/*  IT11204 Item must have quantity.            */

             CHGVAR     VAR(&MSGID) VALUE('IT11204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          quantity available for this item.') +
                          SECLVL('Cause . . . . . :   Quantity is +
                          not available for &1. &N Recovery  . . . +
                          :   Enter a valid item number that has +
                          quantity available.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  IT11205 Full case item cannot be = Broken case item number. */

             CHGVAR     VAR(&MSGID) VALUE('IT11205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Full +
                          case item number cannot be same as the +
                          broken case item.') SECLVL('Cause . . . . +
                          . :   Full case item number &1 is same as +
                          the item being edited. &N Recovery  . . . +
                          :   Enter a valid item number that is +
                          different than the item being edited, and +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 15))
             ENDDO

/*  IT11206 Broken case item must be in fixed section.          */

             CHGVAR     VAR(&MSGID) VALUE('IT11206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Broken case item must be in fixed +
                          section.') SECLVL('Cause . . . . . :   +
                          Replenishment cannot be done for a PIR +
                          item and hence the broken case item must +
                          be in fixed section. &N Recovery  . . . +
                          :   Change the section to fixed for this +
                          item type and try your request again.') +
                          SEV(30)
             ENDDO

/*  IT11207 If mfg date flag= 'Y', then date sensitive flagmust= 'Y' */

             CHGVAR     VAR(&MSGID) VALUE('IT11207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          with manufacturing date must be defined +
                          as date sensitive.') SECLVL('Cause . . . +
                          . . :   Manufacturing date falg is set to +
                          ''Y'' but date sensitive flag is ''N''. +
                          &N Recovery  . . . :   Change the date +
                          sensitive flag to ''Y'' and try your +
                          request again.') SEV(30)
             ENDDO

/*  IT11208 If mfg date flag= 'Y', then Mfg shelf life must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11208')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          with manufacturing date must have shelf +
                          life days.') SECLVL('Cause . . . . . :   +
                          Manufacturing date falg is set to +
                          ''Y'' but shelf life days is zero. &N +
                          Recovery  . . . :   Enter a number +
                          greater than zero for shelf life days +
                          and, try your request again.') SEV(30)
             ENDDO

/*  IT11209 If mfg date flag= 'Y', then Dist days must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11209')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          with manufacturing date must have +
                          distributor days to sell.') SECLVL('Cause +
                          . . . . . :   Manufacturing date falg is +
                          set to ''Y'' but distributor +
                          days to sell is zero. &N Recovery  . . . +
                          :   Enter a number greater than zero for +
                          distributor days to sell and, try your +
                          request again.') SEV(30)
             ENDDO

/*  IT11210 If mfg date flag= 'Y', then User days must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          with manufacturing date must have +
                          distributor days to sell.') SECLVL('Cause +
                          . . . . . :   Manufacturing date falg is +
                          set to ''Y'' but user +
                          days to sell is zero. &N Recovery  . . . +
                          :   Enter a number greater than zero for +
                          user days to sell and, try your +
                          request again.') SEV(30)
             ENDDO

/*  IT11211 If substitute item entered, quantity must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Quant+
                          ity must be greater than zero.') +
                          SECLVL('Cause . . . . .:  The substitute +
                          item was entered and the quantity field +
                          is zero. &N Recovery  . . . +
                          :   Enter a number greater than zero for +
                          quantity, try your request again.') SEV(30)
             ENDDO

/*  IT11212 Max variance is 75%, special variance is 99%.   */

             CHGVAR     VAR(&MSGID) VALUE('IT11212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Max +
                          % allowed is 75%, special variance +
                          is 99%.') SECLVL('Cause +
                          . . . . . :   Manimum variance % is 75%, +
                          special variance is 99%. +
                          &N Recovery  . . . +
                          :   Enter a number less than 75.1 or +
                          equal to 99 and, try your +
                          request again.') SEV(30)
             ENDDO

/*  IT11213 Invalid route for item.                                 */

             CHGVAR     VAR(&MSGID) VALUE('IT11213')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid route for item.') +
                          SECLVL('Cause . . . . .:  The scanned +
                          item is not for this route. &N Recovery  +
                          . . . :   Set this item aside for further +
                          investigation and scan another item to +
                          continue.') SEV(30)
             ENDDO

/*  IT11214 Invalid pallet for item.                                 */

             CHGVAR     VAR(&MSGID) VALUE('IT11214')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid pallet for item.') +
                          SECLVL('Cause . . . . .:  The scanned +
                          item does not belong on this pallet. &N +
                          Recovery  . . . :   Set this item aside +
                          for further investigation and scan +
                          another item to continue.') SEV(30)
             ENDDO

/*  IT11215 Item scan not allowed-Total qty=Scanned qty.             */

             CHGVAR     VAR(&MSGID) VALUE('IT11215')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          scan not allowed.') SECLVL('Cause . . . . +
                          .:  Scanned quantity is equal to total +
                          quantity. &N Recovery  . . . :   Press +
                          F20 to complete this pallet.') SEV(30)
             ENDDO

/*  IT11216 Pallet completed. Checking not allowed.                  */

             CHGVAR     VAR(&MSGID) VALUE('IT11216')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Pallet completed.') SECLVL('Cause . +
                          . . . .:  Pallet already checked. &N +
                          Recovery  . . . :   Check another +
                          pallet.') SEV(30)
             ENDDO

/*  IT11217 Item already scanned.                                    */

             CHGVAR     VAR(&MSGID) VALUE('IT11217')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          already scanned.') SECLVL('Cause . . . . +
                          .:  Item previously scanned. &N Recovery  +
                          . . . :   Scan another item.') SEV(30)
             ENDDO

/*  IT11218 If # of out days > 0, then item must be date sensitive */

             CHGVAR     VAR(&MSGID) VALUE('IT11218')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          with # of days out must be date +
                          sensitive.') SECLVL('Cause . . . . . :   +
                          Date sensitive flag is set to +
                          ''N'' but # of days out is not zero. &N +
                          Recovery  . . . :   Set the date +
                          sensitive flag to Y +
                          and, try your request again.') SEV(30)
             ENDDO

/*  IT11219 Item dept not live.  */

             CHGVAR     VAR(&MSGID) VALUE('IT11219')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          dept not live.') +
                          SECLVL('Cause . . . . . :   +
                          Item department is not live +
                          at this time. &N +
                          Recovery  . . . :   Try different +
                          item.') SEV(30)
             ENDDO



/*  IT11220 Adjustment can not be deleted, created by Dakota. */

             CHGVAR     VAR(&MSGID) VALUE('IT11220')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Adjustment code can not be deleted,  +
                          created by Dakota.') SECLVL('Cause . . . . +
                          :   The adjustment code was created by +
                          Dakota. &N Recovery  . . . :   Contact +
                          BFC to delete code.') SEV(30)
             ENDDO
/*  IT12A01 Alias item needs ' ', B or S for base item.         */

             CHGVAR     VAR(&MSGID) VALUE('IT12A01')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Alias item need std, broken case or +
                          same slot broken case for base item.') +
                          SECLVL('Cause . . . . . :   You are +
                          trying to enter an alias item but the +
                          base item is not std, broken case or same +
                          slot broken caseitem. &N Recovery  . . . +
                          :   Enter the correct item number for +
                          base item and try your request again.') +
                          SEV(30)
             ENDDO

/*  IT12A02 Contract item must have std for it's base item.     */

             CHGVAR     VAR(&MSGID) VALUE('IT12A02')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Contract item must have std item for +
                          base item number.') SECLVL('''Cause . . . +
                          . . :   You are trying to enter a +
                          contract item but the base item is not a +
                          std item. &N Recovery  . . . :   Enter +
                          the correct item number for base item and +
                          try your request again.') SEV(30)
             ENDDO

/*  IT12A03 Same slot brk item must have std for it's base item.     */

             CHGVAR     VAR(&MSGID) VALUE('IT12A03')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Same +
                          slot breakdown item must have std item +
                          for base item number.') SECLVL('Cause . . +
                          . . . :   You are trying to enter a same +
                          slot breakdown item but the base item is +
                          not a std item. &N Recovery  . . . :   +
                          Enter the correct item number for base +
                          item and try your request again.') SEV(30)
             ENDDO

/*  IT12A04 Broken case item should not be entered.                */

             CHGVAR     VAR(&MSGID) VALUE('IT12A04')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Broken case item should not be +
                          entered.') SECLVL('Cause . . . . . :   +
                          You are trying to enter a broken case +
                          item. &N Recovery  . . . :   Enter the +
                          correct item number item and try your +
                          request again.') SEV(30)
             ENDDO

/*  IT12A05 Broken case item must be entered.                */

             CHGVAR     VAR(&MSGID) VALUE('IT12A05')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Broken case item must be entered.') +
                          SECLVL('Cause . . . . . :   Broken case +
                          item number not entered. &N Recovery  . . +
                          . :   Enter the correct item number item +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT12001 Items does not have Link record.                */

             CHGVAR     VAR(&MSGID) VALUE('IT12001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          does not have link record.') +
                          SECLVL('Cause . . . . . :   Item does not +
                          have a link record that ties to it''s +
                          base item.  Alias, Contract, Broken case +
                          and same slot breakdown item must have +
                          link record that ties this item to it''s +
                          base item. &N Recovery  . . . :   Contact +
                          your DP manager and try your request +
                          again after the record is added.') SEV(30)
             ENDDO

/*  IT12002 Items does not have pick slot.                  */

             CHGVAR     VAR(&MSGID) VALUE('IT12002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          does not have pick slot.') SECLVL('Cause +
                          . . . . . :   Item does not have pick +
                          slot assigned. Items in fixed section +
                          must have pick slot assigned to it. &N +
                          Recovery  . . . :   Assign a pick slot +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT11301 Broken case item cannot be copied, if full case     */
/*          item does not exist.                                */

             CHGVAR     VAR(&MSGID) VALUE('IT11301')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Broken case item cannot be  copied, +
                          if full case item does not exist.') +
                          SECLVL('Cause . . . . . :   Broken case +
                          item cannot be copied, if the +
                          corresponding full case item does not +
                          exist. &N Recovery  . . . :   Press F12 +
                          to cancel your request, and try other +
                          item.') SEV(30)
             ENDDO

/*  IT11421 Item can't be deleted because qty <> 0. */

             CHGVAR     VAR(&MSGID) VALUE('IT11421')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 not deleted.') SECLVL('Cause . . . . . +
                          :   Item &1 could not be deleted because +
                          there is a quantity attached to it. &N +
                          Recovery  . . . :   Use adjustment +
                          program to reduce quantity(s) to zero and +
                          try again.') SEV(10) FMT((*CHAR 15))
             ENDDO

/*  IT11422 Item can't be deleted because other item is dependent on it. */

             CHGVAR     VAR(&MSGID) VALUE('IT11422')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          &1 not deleted.') SECLVL('Cause . . . . . +
                          :   Item &1 could not be deleted because +
                          a broken case item &2 is dependent on it. +
                          &N Recovery  . . . :   Delete the broken +
                          case item first, and then try your +
                          request again.') SEV(10) FMT((*CHAR 15) +
                          (*CHAR 15))
             ENDDO

/*  IT12210  Item record in use. */

             CHGVAR     VAR(&MSGID) VALUE('IT12210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          record already in use.') SECLVL('Cause . +
                          . . . . :   The item master record is +
                          being used by another user. &N Recovery  +
                          . . . :   Wait until the item is not +
                          being used and try again.') SEV(30)
             ENDDO

/*  IT12211 Adjustment could not be made. Slot record in use. */

             CHGVAR     VAR(&MSGID) VALUE('IT12211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Adjustment could not be made. Slot +
                          already in use.') SECLVL('Cause . . . . . +
                          :   The slot master record is in use by +
                          another user. &N Recovery  . . . :   Wait +
                          until the slot is not being used and try +
                          again.') SEV(30)
             ENDDO

/*  IT12212 Item is not a PIR item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          is not defined as a PIR item.') +
                          SECLVL('Cause . . . . . :   The slot +
                          being adjusted is a PIR slot but the item +
                          entered is defined as Fixed. &N Recovery  +
                          . . . :   Enter an item that is defined +
                          as PIR or press F12 and select a Fixed +
                          slot.') SEV(30)
             ENDDO

/*  IT12213 Item is not a Fixed item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12213')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          is not defined as a Fixed item.') +
                          SECLVL('Cause . . . . . :   The slot +
                          being adjusted is a Fixed slot but the +
                          item entered is defined as PIR. &N +
                          Recovery  . . . :   Enter an item that is +
                          defined as Fixed or press F12 and select +
                          a PIR slot.') SEV(30)
             ENDDO

/*  IT12214 Item is not a Fixed item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12214')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Fixed slot is reserved for item +
                          &1.') SECLVL('Cause . . . . . :   The +
                          slot being adjusted is a Fixed slot and +
                          is reserved for item &1. &N Recovery  . . +
                          . :   Enter &1 as the item number or +
                          press F12 and select a different slot.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  IT12215 Slot can not be adjusted - No item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12215')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          can not be adjusted - No Item.') +
                          SECLVL('Cause . . . . . :   The slot you +
                          are trying to adjust does not contain an +
                          item. Only slots that contain an item can +
                          be adjusted. &N Recovery  . . . :   Use +
                          item maintenance or slot maintenance to +
                          add an item to the slot.') SEV(30)
             ENDDO

/*  IT12216 Adjsuted quantity can't be negative. */

             CHGVAR     VAR(&MSGID) VALUE('IT12216')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity after adjustment can not be +
                          negative.') SECLVL('Cause . . . . . :   +
                          After your adjustment is made the slot +
                          quantity would be less than zero.  +
                          However, negative slot quantities are not +
                          allowed. &N Recovery  . . . :   Enter an +
                          adjustment that would not change the slot +
                          quantity to less than zero.') SEV(30)
             ENDDO

/*  IT12217 Warning: Slot quanity changed. */

             CHGVAR     VAR(&MSGID) VALUE('IT12217')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Slot quanitity changed +
                          before adjustment could be made.') +
                          SECLVL('Cause . . . . . :   The current +
                          quantity for the slot you are adjusting +
                          changed before you pressed Enter to make +
                          your adjustment. &N Recovery  . . . :   +
                          Press F20 to accept the warning and make +
                          the adjustment or press F12 to cancel.') +
                          SEV(10)
             ENDDO

/*  IT12218 Qty after adjustment exceeds avail qty for Base item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12218')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Quantity after adjustment exceeds +
                          available quantity (&2) for Base item +
                          &1.') SECLVL('Cause . . . . . :   After +
                          your adjustment is made the warehouse +
                          quantity would be less than zero for the +
                          Base item.  However, negative warehouse +
                          quantities are not allowed. &N Recovery  +
                          . . . :   Enter an adjustment that would +
                          not exceed the available quantity (&2) +
                          for the Base item.') SEV(30) FMT((*CHAR +
                          15) (*DEC 7 0))
             ENDDO

/*  IT12273 Adjustment could not be made - Slot was deleted. */

             CHGVAR     VAR(&MSGID) VALUE('IT12273')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Adjustment could not be completed - +
                          Slot does not exist.') SECLVL('Cause . . +
                          . . . :   The slot you were adjusting was +
                          deleted before you pressed Enter to make +
                          your adjustment. &N Recovery  . . . :   +
                          The slot must be recreated before you can +
                          make an adjustment to it.  Press F12 to +
                          cancel this adjustement and determine why +
                          the slot was deleted.') SEV(40)
             ENDDO

/*  IT12274 Adjustment can not be made - record is locked.' */

             CHGVAR     VAR(&MSGID) VALUE('IT12274')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Adjustment could not be completed - +
                          Slot is being used.') SECLVL('Cause . . . +
                          . . :   Another user is already using the +
                          slot you are adjusting and it can not be +
                          shared. &N Recovery  . . . :   Try +
                          again.  If you continue to receive this +
                          message contact you D.P. manager.') SEV(40)
             ENDDO

/*  IT12275 Not enough warehouse qty available.             */

             CHGVAR     VAR(&MSGID) VALUE('IT12275')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Not +
                          enough warehouse quantity available for +
                          adjustment.') SECLVL('Cause . . . . . :   +
                          Available warehouse quantity is zero.  +
                          Some quantity may be allocated to +
                          contract item. &N Recovery  . . . :   If +
                          the quantity is allocated to contract +
                          item, then go to contract item inventory +
                          adjustment and adjust the contract item +
                          quantity.') SEV(40)
             ENDDO

/*  IT13001 Can't adjust item type. */

             CHGVAR     VAR(&MSGID) VALUE('IT13001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Change not allowed for item &1. Use +
                          base item &3 instead.') SECLVL('Cause . . +
                          . . . : Item &1 is a type ''&2'' item. +
                          Changes can only be made for item types +
                          '' '' and ''B'', which physically reside +
                          in slots within the warehouse. The slots +
                          that are displayed contain item &3, the +
                          base item for &1. This error is to +
                          reinforce that item &1, type ''&2'', does +
                          not physically reside in a slot within +
                          the warehouse.  &N Recovery  . . . :   +
                          Work with slots for item &3, the base +
                          item for &1, and then take the change +
                          option.') SEV(30) FMT((*CHAR 15) (*CHAR +
                          1) (*CHAR 15))
             ENDDO

/*  IT13002 Can't add slot for item type. */

             CHGVAR     VAR(&MSGID) VALUE('IT13002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('F6=Create not allowed for item &1. +
                          Use base item &3 instead.') SECLVL('Cause +
                          . . . . . : Item &1 is a type ''&2'' +
                          item. F6=Create can only be used for item +
                          types '' '' and ''B'', which physically +
                          reside in slots within the warehouse. The +
                          slots that are displayed contain item &3, +
                          the base item for &1. This error is to +
                          reinforce that item &1, type ''&2'', does +
                          not physically reside in a slot within +
                          the warehouse.  &N Recovery  . . . :   +
                          Work with slots for item &3, the base +
                          item for &1, and then take the change +
                          option.') SEV(30) FMT((*CHAR 15) (*CHAR +
                          1) (*CHAR 15))
             ENDDO

/*  IT13201 Slot dept/sec/desg not the same as item dept/sec/desg. */

             CHGVAR     VAR(&MSGID) VALUE('IT13201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Department, section and designation +
                          area are not valid.') SECLVL('Cause . . . +
                          . . :   The slot &1 is defined for +
                          department &2, section &3 and designation +
                          area &4 which does not match with the +
                          department &5, section &6 and area &7 +
                          defined for this item. &N Recovery  . . . +
                          :   Enter a slot that matches the above +
                          criteria.') SEV(30) FMT((*CHAR 12) (*CHAR +
                          5) (*CHAR 1) (*CHAR 5) (*CHAR 5) (*CHAR +
                          1) (*CHAR 5))
             ENDDO

/*  IT13202 Slot cannot be verified or zero. */

             CHGVAR     VAR(&MSGID) VALUE('IT13202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          status cannot be blank, V=verified, or +
                          Z=zero.') SECLVL('Cause . . . . . :   The +
                          slot status must be changed to A = +
                          Active, when an item is placed in this +
                          slot. &N Recovery  . . . :   Enter ''A'' +
                          for slot status and try again.') SEV(30)
             ENDDO

/*  IT13203 Slot must be a verified slot to place item in it. */

             CHGVAR     VAR(&MSGID) VALUE('IT13203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          slot you have selected is not a verified +
                          slot.') SECLVL('Cause . . . . . :   The +
                          slot selected must be a verified slot to +
                          place item in it. The slot &1 selected is +
                          &2. &N Recovery  . . . :   Select another +
                          slot and try your request again.') +
                          SEV(30) FMT((*CHAR 12) (*CHAR 30))
             ENDDO

/*  IT13204 Slot does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('IT13204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('The +
                          slot &1 does not exist.') SECLVL('Cause . +
                          . . . . :   The slot entered must exist +
                          to place item in it.  &N Recovery  . . . +
                          :   Select another slot and try your +
                          request again.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT13205 Pick slot already exists  for this item in the */
/*          fixed section.                                 */

             CHGVAR     VAR(&MSGID) VALUE('IT13205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Pick +
                          slot already exists for this item in the +
                          fixed section.') SECLVL('Cause . . . . . +
                          :   Pick slot &1 already exists for this +
                          item in the fixed section.  &N Recovery  +
                          . . . :   Select another slot and try +
                          your request again.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT13206 An active Pick slot already exists  for this item in the */
/*          fixed section.                                           */

             CHGVAR     VAR(&MSGID) VALUE('IT13206')
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


/*  IT13207 Warning, no record exists for tie/high definition. */

             CHGVAR     VAR(&MSGID) VALUE('IT13207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          Tie/High definition exists, F20 to +
                          accept.') SECLVL('Cause . . . . . :   No +
                          Tie/High definition exists for item &1 slot +
                          &2 &N Recovery  . . . :   Use F20 to   +
                          accept without definition or F21 to  +
                          create definition.') +
                          SEV(30) FMT((*CHAR 15) (*CHAR 12))
             ENDDO

/*  IT13208 Warning, no record exists for tie/high definition. */

             CHGVAR     VAR(&MSGID) VALUE('IT13208')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Replenishment tran. cannot be +
                          cancelled.') SECLVL('Cause . . . . . :   +
                          Cancelling this &B replenishment +
                          transaction to slot &B &2 would leave a +
                          negative &B available quantity. There are +
                          orders &B currently in process that are +
                          expect- &B ing the product from this +
                          replenish- &B ment to be in the slot. &N +
                          Recovery  . . . :   Scan the To Slot &B +
                          &2 to complete this trans- &B action.  If +
                          after completing this &B transaction +
                          either the From Slot &B &1 or To Slot &2 +
                          need &B adjustment use slot transfer or +
                          slot &B adjustment to make the necessary +
                          &B corrections.') SEV(30) FMT((*CHAR 12) +
                          (*CHAR 12))
             ENDDO

/*  IT13209 Warehouse short qty needed for transfer.        */

             CHGVAR     VAR(&MSGID) VALUE('IT13209')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warehouse short qty needed for +
                          transfer.') SECLVL('Cause . . . . . :   +
                          Available ware- &B house quantity is +
                          zero.  Some quan- &B tity may be +
                          allocated to contract &B item. &N +
                          Recovery  . . . :   Change quantity on &B +
                          the transfer back to the original &B +
                          value or a larger quantity and try &B +
                          your request again.') SEV(40)
             ENDDO

/*  IT13210 Can not replace, quantity pending.              */

             CHGVAR     VAR(&MSGID) VALUE('IT13210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Can not replace, quantity +
                          pending.') SECLVL('Cause . . . . . :   +
                          Can not replace the stock quantity, +
                          a quantity is pending. +
                          Recovery  . . . :   Use option to increase +
                          /decrease or close the open transactions +
                          and try +
                          your request again.') SEV(40)
             ENDDO


/*  IT13211 Qty and Catch wt must be same sign. */

             CHGVAR     VAR(&MSGID) VALUE('IT13211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Qty +
                          and weight must both be positive or neg+
                          ative.') SECLVL('Cause . . . . . :   The +
                          qty and weight are not both positive +
                          or negative (''+'' or ''-''). +
                          &N Recovery  . . . :   Enter ''-'' +
                          or ''+'' value and try again.') SEV(30)
             ENDDO

/*  IT14001 Invalid unit of measure type. */

             CHGVAR     VAR(&MSGID) VALUE('IT14001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid unit of measure type +
                          entered.') SECLVL('Cause . . . . . :   +
                          The unit of measure type entered is not +
                          valid. &N Recovery  . . . :   Enter a +
                          valid value and try your request again.  +
                          The valid values are: ''N'' for Normal, +
                          ''1'' for Breakdown 1 and ''2'' for +
                          Breakdown 2.') SEV(30)
             ENDDO

/*  IT14002 Invalid preferred slot type. */

             CHGVAR     VAR(&MSGID) VALUE('IT14002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid preferred slot type +
                          entered.') SECLVL('Cause . . . . . :   +
                          The preferred slot type entered is not +
                          valid. &N Recovery  . . . :   Enter a +
                          valid value and try your request again.  +
                          The valid values are: ''Y'' for Yes, +
                          ''N'' or a blank for No.') SEV(30)
             ENDDO

/*  IT15201 Transfer completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('IT15201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          &2 successfully transfered from slot &3 +
                          to slot &4.') SECLVL('Cause . . . . . :   +
                          &1 &2 transfered from slot &3 to slot +
                          &4.  &N Recovery  . . . :   No recovery.  +
                          This is an informational message.') +
                          SEV(10) FMT((*CHAR 10) (*CHAR 15) (*CHAR +
                          12) (*CHAR 12))
             ENDDO

/*  IT15202 From and To slot cannot be same. */

             CHGVAR     VAR(&MSGID) VALUE('IT15202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('From +
                          and To slot cannot be same.') +
                          SECLVL('Cause . . . . . :   The To slot +
                          number you have entered is the same as +
                          the From slot.  &N Recovery  . . . :   +
                          Select a different slot to transfer the +
                          item, and try your request again.') SEV(30)
             ENDDO

/*  IT15203 To slot contains a different item. */

             CHGVAR     VAR(&MSGID) VALUE('IT15203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('To +
                          slot contains a different item.') +
                          SECLVL('Cause . . . . . :   The To slot +
                          number you have entered contains a +
                          different item number.  &N Recovery  . . +
                          . :   Select a different slot to transfer +
                          the item, and try your request again.') +
                          SEV(30)
             ENDDO

/*  IT15204 Virtual slot could not be created. */

             CHGVAR     VAR(&MSGID) VALUE('IT15204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Virtual slot could not be created +
                          for &1.') SECLVL('Cause . . . . . :   A +
                          Virtual slot could not be created for +
                          physical slot &1. Either the physical +
                          slot already has the maximum virtual +
                          slots attached to it or the physical slot +
                          is a handstack slot which uses both +
                          positions of the handstack field.  &N +
                          Recovery  . . . :   Zero verify any +
                          virtual slots for the physical slot or +
                          select a different slot to transfer the +
                          item to. Then, try your request again.') +
                          SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT16001 Item must be a contract item.      */

             CHGVAR     VAR(&MSGID) VALUE('IT16001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          must be a contract item.') SECLVL('Cause +
                          . . . . . :   The item number you have +
                          entered is not a contract item.  &N +
                          Recovery  . . . :   Select a contract +
                          item , and try your request again.  If +
                          you are adjusting inventory on a +
                          non-contract item, then use regular +
                          inventory adjustment program ') SEV(30)
             ENDDO

/*  IT25201 Date sensitive item exists with different date. */

             CHGVAR     VAR(&MSGID) VALUE('IT25201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('To +
                          slot contains item with different date.') +
                          SECLVL('Cause . . . . . :   The To slot num+
                          ber you entered contains this date sensitive+
                          item with a different date.  &N Recovery  . +
                          . . :   Select a different slot to transfer +
                          the item, and try your request again.') +
                          SEV(30)
             ENDDO

/*  IT25202 Warning: Date sensitive item exists with different date. */

             CHGVAR     VAR(&MSGID) VALUE('IT25202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('To +
                          slot contains item with different date, +
                          F20 to accept.') +
                          SECLVL('Cause . . . . . :   The To slot num+
                          ber you entered contains this date sensitive+
                          item with a different date.  &N Recovery  . +
                          . . :   Use F20 to accept, the greater date +
                          will be entered in the slot.') +
                          SEV(30)
             ENDDO

/*  IT25203 Slot and item department do not match.             */

             CHGVAR     VAR(&MSGID) VALUE('IT25203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          and item department do not match.') +
                          SECLVL('Cause . . . . . :   The slot is +
                          in different department than item.  &N +
                          Recovery  . . . :   Make sure that the +
                          item has the right department and try +
                          your request again.') SEV(30)
             ENDDO

/*  IT25204 Qty entered is > Qty available in FROM slot.       */

             CHGVAR     VAR(&MSGID) VALUE('IT25204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Qty +
                          entered is greater than available slot +
                          qty.') SECLVL('Cause . . . . . :   The +
                          quantity entered is greater than +
                          available quantity in From slot.  &N +
                          Recovery  . . . :   Enter quantity less +
                          than or equal to the available slot +
                          quantity and try your request again.') +
                          SEV(30)
             ENDDO

/*  IT25205 Warning: Item number changed.                            */

             CHGVAR     VAR(&MSGID) VALUE('IT25205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Item number changed. F20 to +
                          accept.') SECLVL('Cause . . . . . :   The +
                          item number of the product is changed.  +
                          &N Recovery  . . . :   Use F20 to accept +
                          the warning.  The product will be +
                          transferred to the slot with this new +
                          item number.') SEV(30)
             ENDDO

/*  IT25206 Number of pick slots exceeds number allowed. */

             CHGVAR     VAR(&MSGID) VALUE('IT25206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Number of pick slots after transfer +
                          (&1) exceeds number allowed (&2.') +
                          SECLVL('Cause . . . . . :   After +
                          your transfer, the number of pick slots +
                          qould be greater than the number allowed +
                          for this item.  &N Recovery  +
                          . . . :   Change number allowed or transfer +
                          to a overflow slot.') SEV(30) FMT((*DEC +
                          5 0) (*DEC 5 0))
             ENDDO

/*  IT25207 Slot and item section do not match.             */

             CHGVAR     VAR(&MSGID) VALUE('IT25207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          and item section do not match.') +
                          SECLVL('Cause . . . . . :   The slot is +
                          in different section than item.  &N +
                          Recovery  . . . :   Make sure that the +
                          item has the right section and try +
                          your request again.') SEV(30)
             ENDDO

/*  IT25208 Invalid item type, use base item.               */

             CHGVAR     VAR(&MSGID) VALUE('IT25208')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Inval+
                          id item type, use base item.') +
                          SECLVL('Cause . . . . . :   Item is type +
                          Alias or contract.  Use the linked base +
                          item to transfer quantity.+
                          &N Recovery  . . . :   Look up +
                          the base item and try your request +
                          again.') SEV(30)
             ENDDO

/*  IT25209 Invalid quantity, check base/break quantity.    */

             CHGVAR     VAR(&MSGID) VALUE('IT25209')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Qty +
                          not multiple of base quantity.') +
                          SECLVL('Cause . . . . . :   Transfer +
                          quantity is not a multiple of the base +
                          item/breakdown quantity.+
                          &N Recovery  . . . :   Look up +
                          the base item and try your request +
                          again.') SEV(30)
             ENDDO

/*  IT25210  Invalid license entered. */

             CHGVAR     VAR(&MSGID) VALUE('IT25210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid license entered') +
                          SECLVL('Cause . . . . . :   The license +
                          entered (&1) does not match the one +
                          requested (&2). &N Recovery  . . . :   +
                          Enter the requested license for +
                          confirmation.') SEV(30) FMT((*CHAR 15 0) +
                          (*CHAR 15 0))
             ENDDO


/*  IT26001 Warning: Item desig different than Slot desig. */

             CHGVAR     VAR(&MSGID) VALUE('IT26001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Item/Slot desig don''t match, F20 to +
                          accept.') SECLVL('Cause . . . . . :   +
                          Item designation code (&1) does not match +
                          slot designation code (&2).  &N Recovery  +
                          . . . :   Use F20 to accept or enter a +
                          different slot number.') SEV(10) +
                          FMT((*CHAR 5) (*CHAR 5))
             ENDDO

/*  IT27001 Slot must be a pick slot and in the fixed section.  */

             CHGVAR     VAR(&MSGID) VALUE('IT27001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          not a pick slot or not in the fixed +
                          section.') SECLVL('Cause . . . . . :   +
                          The slot number you have entered/scanned +
                          is not a pick slot or is not in the fixed +
                          section.  &N Recovery  . . . :   Enter a +
                          pick slot in the fixed section and try +
                          your request again.') SEV(30)
             ENDDO

/*  IT27003 Slot dept/sect not same as item.  */

             CHGVAR     VAR(&MSGID) VALUE('IT27003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          dept/sect not same as item: &1/&4.') +
                          SECLVL('Cause . . . . . :   The slot +
                          number you &B have entered/scanned &2 &B +
                          is not in the same dept/sect &B &3/&5 as +
                          the item &1/&4.  &N Recovery  . . . :   +
                          Enter/scan a slot &B that is in the same +
                          dept/sect as the &B item. Then try your +
                          request again.') SEV(30) FMT((*CHAR 5) +
                          (*CHAR 12) (*CHAR 5) (*CHAR 1) (*CHAR 1))
             ENDDO

/*  IT27004 Slot designation not same as item.  */

             CHGVAR     VAR(&MSGID) VALUE('IT27004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          designation not same as item: (&1).') +
                          SECLVL('Cause . . . . . :   The slot +
                          number you &B have entered/scanned &2 &B +
                          does not have the same designation &B +
                          (&3) as the item (&1).  &N Recovery  . . +
                          . :   Enter/scan a slot &B that has the +
                          same designation as the &B item. Then try +
                          your request again.') SEV(30) FMT((*CHAR +
                          5) (*CHAR 12) (*CHAR 5))
             ENDDO

/*  IT27101 Slot must be a repl slot and in the fixed section.  */

             CHGVAR     VAR(&MSGID) VALUE('IT27101')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          not a replenishment slot or not in the +
                          fixed section.') SECLVL('Cause . . . . . +
                          :   The slot number you have +
                          entered/scanned is not a replenishment +
                          slot or is not in the fixed section.  &N +
                          Recovery  . . . :   Enter/scan a +
                          replenishment slot in the fixed section +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT27002 Potential replenishment not found for this slot.    */

             CHGVAR     VAR(&MSGID) VALUE('IT27002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Potential replenishment not found +
                          for this slot.') SECLVL('Cause . . . . . +
                          :   The slot number you have +
                          entered/scanned is not in the potential +
                          replenishment file.  &N Recovery  . . . +
                          :   Run the potential replenishment and +
                          try your request again.') SEV(30)
             ENDDO

/*  IT28001 Scanned slot is invalid.(From slot)  */

             CHGVAR     VAR(&MSGID) VALUE('IT28001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot.') SECLVL('Cause . . . +
                          . . :   The slot number you have +
                          entered/scanned is different from the +
                          replenishment slot &1.  &N Recovery  . . +
                          . :   Get replenishment from &1 slot and +
                          enter/scan &1 slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT28002 Scanned slot is invalid.(To slot)  */

             CHGVAR     VAR(&MSGID) VALUE('IT28002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot.') SECLVL('Cause . . . +
                          . . :   The slot number you have +
                          entered/scanned is different from the +
                          put-away slot &1.  &N Recovery  . . . :   +
                          Put the replenishment in &1 slot and +
                          enter/scan &1 slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT28003 Quantity entered cannot be > system assigned qty */

             CHGVAR     VAR(&MSGID) VALUE('IT28003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid qty entered.') SECLVL('Cause +
                          . . . . . :   New quantity entered &2 is +
                          greater than &1.  &N Recovery  . . . :   +
                          Enter the quantity that is less than or +
                          equal to &1.') SEV(30) FMT((*DEC 7) (*DEC +
                          7 0))
             ENDDO

/*  IT28004 Only one of the options can be "Y" (Yes).        */

             CHGVAR     VAR(&MSGID) VALUE('IT28004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Both +
                          cannot be "Y".') SECLVL('Cause . . . . . +
                          :   Item and quantity options both are +
                          set to "Y" for yes.  &N Recovery  . . . +
                          :   Make one of the options "N" for "No" +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT28005 Only one of the options can be "N" (Yes).        */

             CHGVAR     VAR(&MSGID) VALUE('IT28005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Both +
                          cannot be "N".') SECLVL('Cause . . . . . +
                          :   Item and quantity options both are +
                          set to "N" for NO.  &N Recovery  . . . +
                          :   Make one of the options "Y" for "YES" +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT28006 No more replenishments.        */

             CHGVAR     VAR(&MSGID) VALUE('IT28006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          more replenishments.') SECLVL('Cause . . +
                          . . . :   There is no more replenishments +
                          for the selected department.  &N +
                          Recovery  . . . :   Press F12 to cancel +
                          and enter new department or press F3 to +
                          exit.') SEV(30)
             ENDDO

/*  IT29001 Scanned slot is invalid.(From slot)  */

             CHGVAR     VAR(&MSGID) VALUE('IT29001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot.') SECLVL('Cause . . . +
                          . . :   The slot number you have +
                          entered/scanned is different from the +
                          replenishment slot &1.  &N Recovery  . . +
                          . :   Get replenishment from &1 slot and +
                          enter/scan &1 slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT29002 Scanned slot is invalid.(To slot)  */

             CHGVAR     VAR(&MSGID) VALUE('IT29002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid slot.') SECLVL('Cause . . . +
                          . . :   The slot number you have +
                          entered/scanned is different from the +
                          put-away slot &1.  &N Recovery  . . . :   +
                          Put the replenishment in &1 slot and +
                          enter/scan &1 slot.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IT29003 Quantity entered cannot be > system assigned qty */

             CHGVAR     VAR(&MSGID) VALUE('IT29003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid qty entered.') SECLVL('Cause +
                          . . . . . :   New quantity entered &2 is +
                          greater than &1.  &N Recovery  . . . :   +
                          Enter the quantity that is less than or +
                          equal to &1.') SEV(30) FMT((*DEC 7) (*DEC +
                          7 0))
             ENDDO

/*  IT29004 Only one of the options can be "Y" (Yes).        */

             CHGVAR     VAR(&MSGID) VALUE('IT29004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Both +
                          cannot be "Y".') SECLVL('Cause . . . . . +
                          :   Item and quantity options both are +
                          set to "Y" for yes.  &N Recovery  . . . +
                          :   Make one of the options "N" for "No" +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT29005 Only one of the options can be "N" (Yes).        */

             CHGVAR     VAR(&MSGID) VALUE('IT29005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Both +
                          cannot be "N".') SECLVL('Cause . . . . . +
                          :   Item and quantity options both are +
                          set to "N" for NO.  &N Recovery  . . . +
                          :   Make one of the options "Y" for "YES" +
                          and try your request again.') SEV(30)
             ENDDO

/*  IT29006 No more let-downs.        */

             CHGVAR     VAR(&MSGID) VALUE('IT29006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          more let-downs.') SECLVL('Cause . . . . . +
                          :   There are no more let-downs for the +
                          selected warehouse.  &N Recovery  . . . +
                          :   Press F12 to cancel and enter new +
                          warehouse or press F3 to exit.') SEV(30)
             ENDDO

/*  IT31201 Must enter Base slot      */

             CHGVAR     VAR(&MSGID) VALUE('IT31201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Can +
                         not enter virtual slot.') SECLVL('Cause . . . +
                         :   Cannot enter virtual slot. +
                         &N Recovery  . . . +
                         :   Enter the base slot for the virtual +
                         slot.') SEV(30)
             ENDDO

/*  IT35201 No break quantity defined for base item.        */

             CHGVAR     VAR(&MSGID) VALUE('IT35201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          brk qty defined for base item.') +
                          SECLVL('Cause . . . . . :   The base item +
                          for broken case or same slot breakdown +
                          item does not have a breakdown quantity +
                          defined.  &N Recovery  . . . :   Correct +
                          the base item breakdown qty and try +
                          your request again.') SEV(30)
             ENDDO



/*  IT35202 Warning: To slot status different than from status */

             CHGVAR     VAR(&MSGID) VALUE('IT35202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('From/To slot status don''t match, F20 +
                          to accept.') SECLVL('Cause . . . . . :   +
                          From slot status (&1) does not match +
                          To slot status (&2).  &N Recovery  +
                          . . . :   Use F20 to accept or enter a +
                          different slot number.') SEV(10) +
                          FMT((*CHAR 2) (*CHAR 2))
             ENDDO
/*  IT38001 Potential replenishment could not be completed. */
/*          - Invalid warehouse # entered.                  */

             CHGVAR     VAR(&MSGID) VALUE('IT38001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Potential Replenishment could not be +
                          completed - Invalid warehouse entered.') +
                          SECLVL('Cause . . . . . :  Invalid +
                          warehouse number &1 was entered.  &N +
                          Recovery  . . . :   Select another +
                          warehouse and try your request again.') +
                          SEV(40) FMT((*CHAR 3))
             ENDDO

/*  IT39001 Value for days invalid for include prev. exp items = No. */

             CHGVAR     VAR(&MSGID) VALUE('IT39001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Expire within days cannot be 0 when  +
                          Include previous expired items option is N') +
                          SECLVL('Cause . . . . . +
                          :   Cannot select 0 expire within days if +
                          you exclude previous expired items. +
                          &N Recovery  . . . :   Enter a ''Y'' to  +
                          include previous expired items or enter +
                          a number greater than 0 for expire within +
                          days.') SEV(30)
             ENDDO

/*  IT90001 Item must be a SLOT item, type ' ', 'B' or 'R' */

             CHGVAR     VAR(&MSGID) VALUE('IT90001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Item +
                          must be a slot item.') SECLVL('Cause +
                          . . . . . :   The item number you have +
                          entered is not a slot item.  &N +
                          Recovery  . . . :   Select a slot +
                          item , and try your request again.  +
                          A slot item is type '' '' ''B'' or +
                          ''R'' ') SEV(30)
             ENDDO




             RETURN
             ENDPGM
