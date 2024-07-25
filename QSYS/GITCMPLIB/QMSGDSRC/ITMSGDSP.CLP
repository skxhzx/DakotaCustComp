/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to ITMSGD                      */
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
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
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
                          MSG('No se permite la incorporacion de +
                          Tie/High por producto &1. Use producto de +
                          base &3.') SECLVL('Causa . . . . . :   +
                          Solamente permite la incorporacion de +
                          Tie/High por tipos de productos que estan +
                          fisicamente en los slots del almacen. Este +
                          error es para reforzar que el producto &1 +
                          de tipo ''&2'' no esta fisicamente en un +
                          slot en el almacen. &N Recobro  . . . +
                          :   Incorpore la opcion de la incorporacion +
                          del producto &3, la base por producto &1.') +
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
                          MSG('La seccion incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   La seccion debe +
                          ser una ''F'' o ''P''. &N Recobro . . . :   +
                          Incorpore ''F'' por fija o ''P'' por PIR.') +
                          SEV(30)
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
                          MSG('El CW incorporado es invalido.') +
                          SECLVL('Causa . . . . . :   El CW debe ser +
                          una ''Y'' o ''N''. &N Recobro . . . :   +
                          Incorpore un ''Y'' si un CW es necesitado +
                          o una ''N'' si no es necesitado.') +
                          SEV(30)
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
                          MSG('Aviso: El cubo no es entre +/- &7% +
                          del cubo calculado por el computador.') +
                          SECLVL('Causa . . . . . :   El valor de +
                          cubo incorporado (&5) no es entre +/- &7% +
                          (&8) del cubo calculado por las dimensiones +
                          incorporadas (&1 * &2 * &3 / &6 = &4). &N +
                          Recobro . . . :   Puede oprimir F20 para +
                          aceptar el aviso sin cambio, incorporar un +
                          valor nuevo o usar la tecla de Salir campo +
                          para borrar el valor de cubo y tiene el +
                          computador lo calcula.') SEV(00) +
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
                          MSG('No encontro` ninguno ejemplo +
                          correspondiente.') SECLVL('Causa . . . . . +
                          :   No encontro` ejemplo para corresponder +
                          al Tie/High incorporado. &N Recobro . . . +
                          :   Cambie el valor del Tie e intente el +
                          mandato otra vez.') SEV(10)
             ENDDO

/*  IT11202 Item number must be entered.            */

             CHGVAR     VAR(&MSGID) VALUE('IT11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          numero de producto de caja llena no puede +
                          ser blanco.') SECLVL('Causa . . . . . :   +
                          El numero de producto de caja llena debe +
                          ser incorporado, si es roto, la opcion de +
                          producto de la caja es ''Y''. &N Recobro  +
                          . . :   Incorpore un numero valido del +
                          producto e intente otra vez.') SEV(30)
             ENDDO

/*  IT11203 Item number must be valid.            */

             CHGVAR     VAR(&MSGID) VALUE('IT11203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          numero de producto de caja llena es +
                          invalido.') SECLVL('Causa . . . . . :   El +
                          numero de producto de caja llena no existe +
                          en el archivo. &N Recobro  . . . :   +
                          Incorpore un numero valido del producto e +
                          intente otra vez.') SEV(30)
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
                          hay cantidad disponible de este producto.') +
                          SECLVL('Causa . . . . . :   La cantidad no +
                          es disponible por &1. &N Recobro  . . . +
                          :   Incorpore un numero de producto valido +
                          que tiene una cantidad +
                          disponible.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  IT11205 Full case item cannot be = Broken case item number. */

             CHGVAR     VAR(&MSGID) VALUE('IT11205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          numero de producto de caja llena no puede +
                          ser igual al producto de caja rota.') +
                          SECLVL('Causa . . . . . :   El numero del +
                          producto de caja llena es igual al producto +
                          ser cambiado. &N Recobro . . . :  Incorpore +
                          un numero valido del producto que es +
                          diferente que el producto ser cambiado, e +
                          intente otra vez.') SEV(30) +
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
                          MSG('El producto de caja rota deber estar +
                          en la seccion fija.') SECLVL('Causa . . . . +
                          . :   El reaprovisionamiento no pude ser +
                          hecho por un producto de PIR y por eso, el +
                          producto de caja rota debe estar en la +
                          seccion fija. &N Recobro . . . :   Cambie +
                          la seccion a fija por este tipo de producto +
                          e intente otra vez.') SEV(30)
             ENDDO

/*  IT11207 If mfg date flag= 'Y', then date sensitive flagmust= 'Y' */

             CHGVAR     VAR(&MSGID) VALUE('IT11207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          producto con fecha manufactura debe ser +
                          definido como fecha sensitiva.') +
                          SECLVL('Causa . . . . . :   La bandera de +
                          la fecha de manufactura es fija a ''Y'' +
                          pero la bandera de la fecha sensitiva es +
                          fija a ''N''. &N Recobro . . . :   Cambie +
                          la bandera de la fecha sensitiva e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  IT11208 If mfg date flag= 'Y', then Mfg shelf life must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11208')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          producto con fecha manufactura debe tener +
                          dias de entrepano.') SECLVL('Causa . . . . +
                          . :   La bandera de fecha manufactura es +
                          fija a ''Y'' pero dias de entrepano es 0. +
                          &N Recobro . . . :   Incorpore un numero +
                          mas grande que 0 por dias de entrepano e +
                          intente otra vez.') SEV(30)
             ENDDO

/*  IT11209 If mfg date flag= 'Y', then Dist days must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11209')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          producto con una fecha manufactura debe +
                          tener dias distributivos para vender.') +
                          SECLVL('Causa . . . . . :   La bandera de +
                          manufactura es fija a ''Y'', pero dias +
                          distributivos para vender es 0. &N Recobro +
                          . . . :   Incorpore un numero mas grande +
                          que 0 por dias distributivos para vender e +
                          intente otra vez.') SEV(30)
             ENDDO

/*  IT11210 If mfg date flag= 'Y', then User days must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11210')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          producto con fecha manufactura debe tener +
                          dias distributivas para vender.') +
                          SECLVL('Causa . . . . . :   La bandera de +
                          fecha manufactura es fija a ''Y'' pero dias +
                          usados para vender es 0. &N Recobro . . . +
                          :   Incorpore un numero mas grande que 0 +
                          por dias usados para vender, e intente otra +
                          vez.') SEV(30)
             ENDDO

/*  IT11211 If substitute item entered, quantity must be > 0 */

             CHGVAR     VAR(&MSGID) VALUE('IT11211')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          cantidad debe ser mas grande que 0.') +
                          SECLVL('Causa . . . . .:  El producto +
                          substitutivo fue incorporado y la cantidad +
                          es 0. &N Recobro . . . :   Incorpore un +
                          numero mas grande que 0 por la cantidad +
                          e intente otra vez.') SEV(30)
             ENDDO

/*  IT11212 Max variance is 75%, special variance is 99%.   */

             CHGVAR     VAR(&MSGID) VALUE('IT11212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          porcentaje maximo que se permite es 75%, +
                          variacion especial es 99%.') SECLVL('Causa +
                          . . . . . :   La variacion minima es 75% +
                          la variacion especial es 99%. +
                          &N Recobro  . . . :   Incorpore un numero +
                          menos que 75.1, o igual a 99, e intente +
                          otra vez.') SEV(30)
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
                          MSG('Ruta invalida por el producto.') +
                          SECLVL('Causa . . . . .:  El producto +
                          escandido no es por esta ruta. &N Recobro  +
                          . . . :   Ponga el producto a un lado para +
                          investigar adelante y escanda otro producto +
                          para continuar.') SEV(30)
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
                          MSG('Paleta invalida por producto.') +
                          SECLVL('Causa . . . . . :  El producto +
                          escandido no pertenece en esta paleta. &N +
                          Recobro  . . . :   Ponga este producto a un +
                          lado para investigar adelante y escande +
                          producto para continuar.') SEV(30)
             ENDDO

/*  IT11215 Item scan not allowed-Total qty=Scanned qty.             */

             CHGVAR     VAR(&MSGID) VALUE('IT11215')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No se +
                          permite escandir producto .') SECLVL('Causa +
                          . . . . . :   La cantidad escandida es +
                          igual a la cantidad total. &N Recobro . . . +
                          :   Oprima F20 para terminar esta +
                          paleta.') SEV(30)
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
                          MSG('Paleta terminada.') SECLVL('Causa . +
                          . . . .:  Paleta verificada ya. &N +
                          Recobro  . . . :   Verifique otra +
                          paleta.') SEV(30)
             ENDDO

/*  IT11217 Item already scanned.                                    */

             CHGVAR     VAR(&MSGID) VALUE('IT11217')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('+
                          producto escandido ya.') SECLVL('Causa . . +
                          . . . :   Producto escandido anties. &N +
                          Recobro . . . Escande otro +
                          producto.') SEV(30)
             ENDDO

/*  IT11218 If # of out days > 0, then item must be date sensitive */

             CHGVAR     VAR(&MSGID) VALUE('IT11218')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          producto con numero de dias debe ser fecha +
                          sensitiva.') SECLVL('Causa . . . . . :   +
                          La bandera de fecha sensitiva es fija a +
                          ''N'' pero el numero de dias es 0. &N +
                          Recobro  . . . :   Fije la bandera de fecha +
                          sensitiva a ''Y'' e intente otra +
                          vez.') SEV(30)
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
                          MSG('Un producto alias necesita normal, +
                          caja rota, o mismo slot caja rota por un +
                          producto de base.') SECLVL('Causa . . . . . +
                          :   Esta tratando de incorporar un producto +
                          alias pero el producto de base no es +
                          normal, caja rota, o producto de mismo slot +
                          caja rota. &N Recobro . . . :   Incorpore +
                          el numero correcto del producto e intente +
                          otra vez.') SEV(30)
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
                          MSG('Un producto de contracto debe tener +
                          producto normal por el numero del producto +
                          de base.') SECLVL('Causa . . . . . :   Esta +
                          tratando de incorporar un producto de +
                          contracto pero el producto de base no es un +
                          producto normal. &N Recobro . . . :  +
                          Incorpore el numero correcto del producto +
                          por producto de base e intente otra +
                          vez.') SEV(30)
             ENDDO

/*  IT12A03 Same slot brk item must have std for it's base item.     */

             CHGVAR     VAR(&MSGID) VALUE('IT12A03')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          producto del mismo slot roto debe tener un +
                          producto normal por el numero de producto +
                          de base.') SECLVL('Causa . . . . . :   Esta +
                          tratando de incorporar un producto del +
                          mismo slot roto pero el producto de base +
                          no es un producto normal. &N Recobro . . . +
                          :   Incorpore el numero de producto +
                          correcto e intente otra vez.') SEV(30)
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
                          MSG('Producto de caja rota no debe ser +
                          incorporado.') SECLVL('Causa . . . . . :   +
                          Esta tratando de incorporar un producto de +
                          caja rota. &N Recobro . . . :   Incorpore +
                          el numero correcto del producto e intente +
                          otra vez.') SEV(30)
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
                          MSG('Producto de caja rota debe ser +
                          incorporado.') SECLVL('Causa . . . . . :   +
                          Un producto de caja rota no fue +
                          incorprorado. &N Recobro . . . :   +
                          Incorpore el numero correcto del producto +
                          e intente otra vez.') SEV(30)
             ENDDO

/*  IT12001 Items does not have Link record.                */

             CHGVAR     VAR(&MSGID) VALUE('IT12001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no tiene anotacion de eslabon.') +
                          SECLVL('Causa . . . . . :   El producto no +
                          tiene una anotacion de eslabon que se une +
                          al producto de base. Los productos de Alias+
                          , Contracto, Caja rota y Mismo slot roto +
                          deben tener una anotacion de eslabon que se +
                          une al producto de base. &N Recobro . . . +
                          :   Establezca contacto con el director de +
                          DP e intente otra vez despues de la +
                          adicion a la anotacion.') SEV(30)
             ENDDO

/*  IT12002 Items does not have pick slot.                  */

             CHGVAR     VAR(&MSGID) VALUE('IT12002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no tiene pick slot.') +
                          SECLVL('Causa . . . . . :   El producto +
                          no tiene un pick slot asignado. Productos +
                          en la seccion fija deben tener un pick slot +
                          asignado. &N Recobro . . . :   Asigne un +
                          pick slot e intente otra vez.') SEV(30)
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
                          MSG('No puede copiar un producto de caja +
                          rota si el producto de caja llena no +
                          existe.') SECLVL('Causa . . . . . :   El +
                          producto no puede ser copiado si el +
                          producto corresponidiente de la caja llena +
                          no existe. &N Recobro . . . :   Oprima F12 +
                          para cancelar, o intente otro +
                          producto.') SEV(30)
             ENDDO

/*  IT11421 Item can't be deleted because qty <> 0. */

             CHGVAR     VAR(&MSGID) VALUE('IT11421')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no borrado.') SECLVL('Causa . +
                          . . . . :   El producto &1 no puede ser +
                          borrado porque hay una cantidad adjuntada a +
                          el. &N Recobro . . . :   Use el programa de +
                          ajuste para reducir la cantidad a 0 e +
                          intente otra vez.') SEV(10) FMT((*CHAR 15))
             ENDDO

/*  IT11422 Item can't be deleted because other item is dependent on it. */

             CHGVAR     VAR(&MSGID) VALUE('IT11422')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no borrado.') SECLVL('Causa . +
                          . . . . :   El producto &1 no puede ser +
                          borrado porque un producto de caja rota +
                          &2 es dependiente. &N Recobro . . . :   +
                          Primero, borre el producto de caja rota e +
                          intente otra vez.') SEV(10) FMT((*CHAR 15) +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Ya +
                          esta usando la anotacion de producto.') +
                          SECLVL('Causa . . . . . :   Otro usuario +
                          esta usando la anotacion del producto. &N +
                          Recobro . . . :   Espere hasta el otro +
                          usuario termina e intente otra vez.') SEV(30)
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
                          MSG('El ajustamiento no puede ser hecho.') +
                          SECLVL('Causa . . . . . :   Otro usuario ya +
                          esta usando la anotacion del slot. &N +
                          Recobro . . . :   Espere hasta el otro +
                          usuario termina e intente otra +
                          vez.') SEV(30)
             ENDDO

/*  IT12212 Item is not a PIR item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no es defenido como un producto de +
                          PIR.') SECLVL('Causa . . . . . :   El slot +
                          que quiere ajustar es un slot de PIR pero +
                          el producto incorporado es definido como +
                          fijo. &N Recobro . . . :   Incorpore un +
                          slot que es definido como PIR u oprima F12 +
                          y seleccione un slot fijo.') SEV(30)
             ENDDO

/*  IT12213 Item is not a Fixed item. */

             CHGVAR     VAR(&MSGID) VALUE('IT12213')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no es definido como producto +
                          fijo.') SECLVL('Causa . . . . . :   El slot +
                          que quiere ajustar es un slot fijo pero el +
                          producto incorporado es definido como PIR. +
                          &N Recobro  . . . :   Incorpore un producto +
                          que es definido como fijo, u oprima F12 +
                          para seleccionar un slot de PIR.') SEV(30)
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
                          MSG('El slot fijo es reservado por el +
                          producto &1.') SECLVL('Causa . . . . . :   +
                          El slot que intente ajustar es un slot fijo +
                          y es reservado por producto &1. &N Recobro +
                          . . . :   Incorpore &1 como el numero del +
                          producto u oprime F12 y seleccionar un slot +
                          diferente.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot no puede ser ajustado-No hay +
                          producto.') SECLVL('Causa . . . . . :   El +
                          slot que intente ajustar no contiene ningun +
                          producto. Solamente los slots que contienen +
                          un producto pueden ser ajustados. &N +
                          Recobro . . . :   Use el mantenimiento del +
                          producto o mantenimiento del slot para +
                          anadir un producto al slot.') SEV(30)
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
                          MSG('La cantidad despues de ajuste no puede +
                          ser negativo.') SECLVL('Causa . . . . . :   +
                          Despues del ajuste, la cantidad del slot +
                          seria menos que 0. Sin embargo, las +
                          cantidades negativas de los slots no son +
                          permitidas. &N Recobro  . . . :   Incorpore +
                          un ajuste que no cambiara` la cantidad +
                          menos que 0.') SEV(30)
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
                          MSG('Aviso: La cantidad de slot fue +
                          cambiada antes de un ajuste pudo ser +
                          hecho.') SECLVL('Causa . . . . . :   La +
                          cantidad actual del slot que esta ajustando +
                          cambio` antes de oprimio` ENTER para hacer +
                          el ajuste. &N Recobro  . . . :   Oprima F20 +
                          para aceptar el aviso y hacer el ajuste, u +
                          oprima F12 para cancelar.') +
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
                          MSG('La cantidad despues del ajuste excede +
                          la cantidad disponible (&2) por el producto +
                          de base &1.') SECLVL('Causa . . . . . :  +
                          Despues de hace un ajuste, la cantidad en +
                          el almacen seria menos que 0 por el +
                          producto de base. Sin embargo, no permite +
                          que hay cantidades negativas en el almacen. +
                          Recobro . . . :   Incorpore el ajuste que +
                          no excederia la cantidad disponible (&2) +
                          por el producto.') SEV(30) FMT((*CHAR +
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
                          MSG('El ajuste no pudo ser terminado - el +
                          slot no existe.') SECLVL('Cause . . . . . +
                          :   El slot que estaba ajustando fue +
                          borrado antes de oprimio` ENTER para hacer +
                          el ajuste. &N Recovery  . . . :   El slot +
                          debe ser recreado antes de que pueda +
                          ajustarlo. Oprima F12 para cancelar este +
                          ajuste y derterminar la razon porque el +
                          slot fue borrado.') SEV(40)
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
                          MSG('El ajuste no pudo ser terminado - el +
                          slot esta en uso.') SECLVL('Causa . . . +
                          . . :   Otro usuario ya esta usando el slot +
                          que esta ajustando y no puede ser +
                          compartido. &N Recobro  . . . :   Intente +
                          otra vez.  Si continua recibir este mensaje +
                          establezca contacto con el director +
                          de DP.') SEV(40)
             ENDDO

/*  IT12275 Not enough warehouse qty available.             */

             CHGVAR     VAR(&MSGID) VALUE('IT12275')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay suficiente cantidad disponible por el +
                          ajuste.') SECLVL('Causa . . . . . :   La +
                          cantidad disponible del almacen es 0.  +
                          Alguna cantidad puede ser asignado al +
                          producto de contracto. &N Recobro . . . :   +
                          Si la cantidad es asignada al inventario +
                          del producto de contracto, entonces vaya al +
                          inventario del producto de contracto y +
                          ajuste la cantidad del producto de +
                          contracto.') SEV(40)
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
                          MSG('No se permite el cambio de producto +
                          &1. Use el producto de base &3 en lugar.') +
                          SECLVL('Causa . . . . . :   El producto &1 +
                          es un producto de tipo ''&2''. Los cambios +
                          solamente pueden ser hechos por tipos de +
                          productos '' '' y ''B'', que existen +
                          fisicamente en los slots en el almacen. Los +
                          slots que son exhibidos contienen producto +
                          &3, el producto de base de &1. Este error +
                          es para reforzar que producto &1 del tipo +
                          ''&2'' no existe fisicamente en el slot en +
                          el almacen. &N Recobro . . . :   Trabaje +
                          con los slots de producto &3, el producto +
                          de base de &1, y entonces tome la opcion de +
                          cambio.') SEV(30) FMT((*CHAR 15) (*CHAR +
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
                          MSG('F6=Crear no es permitido por producto +
                          &1. Use el producto de base &3 en lugar.') +
                          SECLVL('Causa . . . . . :   El producto &1 +
                          es un producto de ''&2'' tipo. F6=Crear +
                          solamente puede ser usado por los productos +
                          de tipos '' '' y ''B'', que existen +
                          fisicamente en los slots en el almacen. Los +
                          slots que son exhibidos contienen el +
                          producto &3, el producto de base &1. Este +
                          error es para reforzar que el producto &1 +
                          de tipo ''&2'' no existe fisicamente en el +
                          almacen. &N Recobro . . . :   Trabaje con +
                          los slots de producto &3, el producto de +
                          base de &1, y entonces tome la opcion de +
                          cambio.') SEV(30) FMT((*CHAR 15) (*CHAR +
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
                          MSG('El departamento, seccion, y area de +
                          designacion no son validos.') SECLVL('Causa +
                          . . . . . :   El slot &1 es definido por el +
                          departamento &2, de seccion &3 y area de +
                          designacion &4 que no corresponden al +
                          departmento &5, seccion &6 and area &7 +
                          definido por este producto. &N Recovery . . +
                          . :   Incorpore un slot que corresponde al +
                          criterio +
                          arriba.') SEV(30) FMT((*CHAR 12) (*CHAR +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          estado del slot no puede ser blanco, V=+
                          Verificado, o Z=Nada.') SECLVL('Causa . . . +
                          . . :   El estado del slot debe ser +
                          cambiado a A=Activo, cuando un producto es +
                          puesto en el slot. &N Recobro . . . :   +
                          Incorpore ''A'' por el estado del slot e +
                          intente otra vez.') SEV(30)
             ENDDO

/*  IT13203 Slot must be a verified slot to place item in it. */

             CHGVAR     VAR(&MSGID) VALUE('IT13203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot seleccionado no es un slot verificado.'+
                          ) SECLVL('Causa . . . . . :   El slot +
                          seleccionado debe ser un slot verificado +
                          para poner un producto en el. El slot &1 +
                          seleccionado es &2. &N Recobro . . . :   +
                          Seleccione otro slot e intente otra vez.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot &1 no existe.') SECLVL('Causa . . . . +
                          . :   El slot incorporado debe existir para +
                          poner un producto en el.  &N Recobro  . . . +
                          :   Seleccione otro slot e intente otra +
                          vez.') SEV(30) FMT((*CHAR 12))
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
                          slot ya existe por este producto en la +
                          seccion fija.') SECLVL('Causa . . . . . :   +
                          El pick slot &1 ya existe por el producto +
                          en la seccion fija.  &N Recobro . . . :   +
                          Seleccione otro slot e intente otra +
                          vez.') SEV(30) FMT((*CHAR 12))
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Un +
                          pick slot activo ya existe por este +
                          producto en la seccion fija.') +
                          SECLVL('Causa . . . . . :   Un pick slot +
                          activo &1 ya existe por este producto en +
                          la seccion fija. No puede tener mas que +
                          un pick slot activo por un producto en la +
                          seccion fija. &N Recobro . . . :   Retenga +
                          el estado no activo del +
                          slot.') SEV(30) FMT((*CHAR 12))
             ENDDO


/*  IT13207 Warning, no record exists for tie/high definition. */

             CHGVAR     VAR(&MSGID) VALUE('IT13207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          definicion de Tie/High no existe, F20 para +
                          aceptar.') SECLVL('Causa . . . . . :   La +
                          definicion de Tie/High no existe por el +
                          producto &1 en el slot &2. &N Recobro . . . +
                          :   Use F20 para aceptar sin la definicion +
                          o F21 para crear la definicion.') +
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
                          MSG('La transaccion de reaprovisionamiento +
                          no puede ser cancelada.') SECLVL('Causa . +
                          . . . . :   Cancelar esta &B transaccion de +
                          reaprovisionamiento al slot &B &2 dejaria +
                          una cantidad disponible negativa &B. Hay +
                          pedidos &B en el proceso actual que estan +
                          esperando &B el producto de este +
                          reaprovisionamiento &B de estar en el slot. +
                          &N Recobro  . . . :   Escanda el slot de +
                          Hasta &B &2 para terminar esta transaccion +
                          &B. Si despues de terminar esta transaccion +
                          &B el slot de Desde &B &1 o el slot de +
                          Hasta &2 necesitan el ajustamiento &B, use +
                          la transferencia del slot o ajustamiento de +
                          &B para hacer las corecciones &B que son +
                          necesarias.') SEV(30) FMT((*CHAR 12) +
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
                          MSG('El almacen falta cantidad necesitada +
                          para transferir.') SECLVL('Causa . . . . . +
                          :   La cantidad disponible del almacen &B +
                          es 0. Alguna cantidad &B puede ser asignada +
                          para reducir el producto &B. &N Recobro . . +
                          . :   Cambie la cantidad en &B de la +
                          transferencia al valor original o una +
                          cantidad mas grande &B e intente otra +
                          vez.') SEV(40)
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
                          MSG('No puede reponer, la cantidad es +
                          pendiente.') SECLVL('Causa . . . . . :   +
                          No puede reponer la cantidad del inventario +
                          porque una cantidad es pendiente. +
                          Recobro . . . :   Use la opcion de aumentar +
                          /reducir o cierre las transacciones e +
                          intente +
                          otra vez.') SEV(40)
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
                          MSG('El tipo de unidad de medicion +
                          incorporado es invalido.') SECLVL('Causa . +
                          . . . . :   El tipo de unidad de medicion +
                          incorporado no es valido. &N Recobro . . . +
                          :   Incorpore un valor valido e intente +
                          otra vez. Los valores validos son: ''N'' +
                          por Normal, ''1'' por la caida 1 y ''2'' +
                          por la caida 2.') SEV(30)
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
                          MSG('Tipo de slot preferido no es valido.') +
                          SECLVL('Causa . . . . . :   El tipo de slot +
                          preferido no es valido. &N Recobro . . . +
                          :   Incorpore un valor valido e intente +
                          otra vez. Los valores validos son ''Y'' por +
                          Si, ''N'' o blanco por +
                          No.') SEV(30)
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
                          &2 transferido con buen exito de slot &3 +
                          al slot &4.') SECLVL('Causa . . . . . :   +
                          &1 &2 transferido de slot &3 al slot &4. +
                          &N Recobro . . . :   No hay recobro. +
                          Este es un mensaje de informacion.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot de Desde no puede ser igual al slot de +
                          Hasta.') SECLVL('Causa . . . . . :   El +
                          numero del slot de Hasta incorporado es +
                          igual al numero del slot de Desde. &N +
                          Recobro . . . :   Seleccione otro slot para +
                          transferir el producto e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  IT15203 To slot contains a different item. */

             CHGVAR     VAR(&MSGID) VALUE('IT15203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot de Hasta contiene un producto +
                          diferente.') SECLVL('Causa . . . . . :   El +
                          numbero del slot de Hasta contiene un +
                          numero diferente del producto. &N Recobro . +
                          . . :  Seleccione otro slot para transferir +
                          el producto e intente otra vez.') +
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
                          MSG('El slot virtual no pudo ser creado por +
                          &1.') SECLVL('Causa . . . . . :   Un slot +
                          virtual no pudo ser creado por el slot +
                          fisico &1. El slot fisico ya tiene el +
                          numero maximo de slots virtuales, o el +
                          slot fisico es un slot de Handstack que usa +
                          las dos posiciones en el campo de +
                          handstack. &N Recobro . . . : Verifique con +
                          0 algunos slots virtuales por el slot +
                          fisico o seleccione un slot diferente para +
                          transferir el producto. Entonces, intente +
                          otra vez.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto debe ser un producto de +
                          contracto.') SECLVL('Causa . . . . . :   +
                          El numero del producto incorporado no es +
                          un producto de contracto. &N Recobro . . . +
                          :   Seleccione un producto de contracto. +
                          Si esta ajustando el inventario de un +
                          producto no de contracto, entonces use el +
                          programa del ajuste del inventario +
                          regular. ') SEV(30)
             ENDDO

/*  IT25201 Date sensitive item exists with different date. */

             CHGVAR     VAR(&MSGID) VALUE('IT25201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot de Hasta contiene un producto con una +
                          fecha diferente.') SECLVL('Causa . . . . . +
                          :   El numero del slot de Hasta incorporado +
                          contiene este producto de fecha sensitiva +
                          con fecha diferente. &N Recobro . . . :   +
                          Seleccione otro slot para transferir el +
                          producto e intente otra vez.') +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot de hasta contiene un producto con una +
                          fecha diferente, F20 para aceptar.') +
                          SECLVL('Causa . . . . . :   El numero del +
                          slot de hasta contiene este producto con +
                          una fecha sensitiva con una fecha diferente.+
                           &N Recobro . . . :   Use F20 para aceptar, +
                          la fecha mas grande sera incorporado en el +
                          slot.') SEV(30)
             ENDDO

/*  IT25203 Slot and item department do not match.             */

             CHGVAR     VAR(&MSGID) VALUE('IT25203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot y el departamento del producto no +
                          corresponen.') SECLVL('Causa . . . . . :   +
                          El slot esta en un departamento diferente +
                          que el producto. &N Recobro . . . :   Este +
                          seguro que el producto tiene el +
                          departamento correcto e intente otra +
                          vez.') SEV(30)
             ENDDO

/*  IT25204 Qty entered is > Qty available in FROM slot.       */

             CHGVAR     VAR(&MSGID) VALUE('IT25204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          cantidad incorporada es mas grande que la +
                          cantidad disponible en el slot.') +
                          SECLVL('Causa . . . . . :   La cantidad +
                          incorporada es mas grande que la cantidad +
                          disponible en el slot de Desde. &N Recobro +
                          . . . :   Incorpore una cantidad menos que +
                          o igual a la cantidad disponible e intente +
                          otra vez.') SEV(30)
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
                          MSG('Aviso: El numero del producto cambio +
                          F20 para aceptar.') SECLVL('Causa . . . . . +
                          El numero del producto es cambiado. +
                          &N Recobro  . . . :   Use F20 para aceptar +
                          el aviso. Este producto sera transferido al +
                          slot con este numero de producto +
                          nuevo.') SEV(30)
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
                          MSG('El numero de pick slots despues de la +
                          transferencia (&1) excede el numero +
                          permitido (&2).') SECLVL('Cause . . . . . +
                          :   Despues de la transferencia, el numero +
                          de pick slots seria mas grande que el +
                          numero permitido por este producto. &N +
                          Recobro . . . :   Cambie el numero +
                          permitido o transfiera al slot de +
                          exceso.') SEV(30) FMT((*DEC +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot y seccion del producto no corresponden.+
                          ') SECLVL('Causa . . . . . :   El slot esta +
                          en una seccion diferente que el producto. +
                          &N Recobro . . . :   Este seguro que el +
                          producto tiene la seccion correcta e +
                          intente otra vez.') SEV(30)
             ENDDO

/*  IT25208 Invalid item type, use base item.               */

             CHGVAR     VAR(&MSGID) VALUE('IT25208')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          tipo de producto es invalido, use producto +
                          de base.') SECLVL('Causa . . . . . :   El +
                          producto es de tipo alias o contracto. Use +
                          el producto de base eslabon para transferir +
                          la cantidad. &N Recobro  . . . :   Busque +
                          el producto de base e intente otra +
                          vez.') SEV(30)
             ENDDO

/*  IT25209 Invalid quantity, check base/break quantity.    */

             CHGVAR     VAR(&MSGID) VALUE('IT25209')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          cantidad no es un multiple de la cantidad +
                          de base.') SECLVL('Causa . . . . . :   La +
                          cantidad de transferencia no es un multiple +
                          de la cantidad rota del producto. +
                          &N Recobro  . . . :   Busque el producto de +
                          base e intente otra +
                          vez.') SEV(30)
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
                          MSG('Licencia incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   La licencia +
                          incorporada (&1) no corresponde a la +
                          pedida (&2). &N Recobro  . . . :   +
                          Incorpore la licencia pedida por +
                          confirmacion.') SEV(30) FMT((*CHAR 15 0) +
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
                          MSG('Las designaciones de producto y slot +
                          no corresponden, F20 para aceptar.') +
                          SECLVL('Causa . . . . . :   El codigo de +
                          designacion del producto (&1) no +
                          corresponde a lo del slot (&2). &N Recobro +
                          . . . :   Use F20 para aceptar o incorpore +
                          un numero diferente del slot.') SEV(10) +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot no es un pick slot o no esta en la +
                          seccion fija.') SECLVL('Causa . . . . . +
                          :   El numero de slot incorporado/ +
                          escandido no es un pick slot o no esta en +
                          la seccion fija. &N Recobro . . . :  +
                          Incorpore un pick slot en la seccion fija +
                          e intente otra vez.') SEV(30)
             ENDDO

/*  IT27003 Slot dept/sect not same as item.  */

             CHGVAR     VAR(&MSGID) VALUE('IT27003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          departamento/seccion de slot no es igual +
                          al producto.') SECLVL('Causa . . . . . :   +
                          El numero del &B slot escandido/incorporado +
                          &2 &B no esta en el mismo departamento/ +
                          seccion &B &3/&5 como el producto &1/&4. +
                          &N Recobro . . . :   Incorpore/ escanda un +
                          slot &B que esta en el mismo departamento/+
                          seccion como el &B producto e intente otra +
                          vez.') SEV(30) FMT((*CHAR 5) +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          designacion del slot no es igual al +
                          producto: (&1).') SECLVL('Causa . . . . . +
                          :   El numero del slot &B escandido/ +
                          incorporado no tiene la misma designacion +
                          &B (&3) como el product (&1).  &N Recobro +
                          . . . :   Incorpore/Escanda un slot &B que +
                          tiene la misma designacion como el &B +
                          producto. Entonces intente otra +
                          vez.') SEV(30) FMT((*CHAR +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('EL +
                          slot no es un slot de reaprovisionamiento +
                          o no esta en la seccion fija.') +
                          SECLVL('Causa . . . . . :   El numero del +
                          slot incorporado/escandido no es un slot de +
                          reaprovisionamiento, o no esta en la +
                          seccion fija. &N Recobro . . . :   Escanda/+
                          incorpore un slot de reaprovisionamiento en +
                          la seccion fija e intente otra vez.') SEV(30)
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
                          MSG('Un reaprovisionamiento potencial no +
                          fue encontrado por este slot.') +
                          SECLVL('Causa . . . . . :   El numero de +
                          slot incorporado/escandido no esta en el +
                          archivo de reaprovisionaminto potencial. +
                          &N Recobro . . . :   Utilice el +
                          reaprovisionamiento potencial e +
                          intente otra vez.') SEV(30)
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
                          MSG('Slot invalido.') SECLVL('Causa . . . +
                          . . :   El numero de slot incorporado/ +
                          escanidod es diferente que el slot de +
                          reaprovisionamiento &1. &N Recobro  . . +
                          . :   Consiga el reaprovisionamiento del +
                          slot &1 y  escanda/incorpore el +
                          slot &1.') SEV(30) FMT((*CHAR 12))
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
                          MSG('Slot invalido.') SECLVL('Causa . . . +
                          . . :   El numero de slot incorporado/ +
                          escandido es diferente que el slot de +
                          guardar &1. &N Recovery  . . . :   Guarde +
                          el reaprovisionamiento en slot &1 y escanda/+
                          incorpore slot &1.') SEV(30) FMT((*CHAR 12))
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
                          MSG('La cantidad incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   La cantidad +
                          nueva incorporada es mas grande que &1. &N +
                          Recobro . . . :   Incorpore una cantidad +
                          que es mas grande que o igual +
                          a &1.') SEV(30) FMT((*DEC 7) (*DEC +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Los +
                          dos no pueden ser "Y"(si).') SECLVL('Causa +
                          . . . . . :   Las opciones del producto y +
                          la cantidad son fijas a "Y" por si. &N +
                          Recobro . . . :   Fije una de las opciones +
                          a "N" por no e intente otra vez.') SEV(30)
             ENDDO

/*  IT28005 Only one of the options can be "N" (Yes).        */

             CHGVAR     VAR(&MSGID) VALUE('IT28005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Las +
                          dos no pueden ser "N"(no).') SECLVL('Causa +
                          . . . . . :   Las opciones del producto y +
                          la cantidad son fijas a "N" por no. &N +
                          Recobro . . . :   Fije una de las opciones +
                          a "Y" por si e intente otra vez.') SEV(30)
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
                          hay mas reaprovisionamientos.') +
                          SECLVL('Causa . . . . . :   No hay mas +
                          reaprovisionamientos por el departamento +
                          seleccionado. &N Recobro . . . :   Oprima +
                          F12 para cancelar e incorpore departamento +
                          nuevo, u oprima F3 para salir.') SEV(30)
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
                          MSG('Slot invalido.') SECLVL('Causa . . . +
                          . . :   El numero de slot escandido/+
                          incorporado es diferente que el slot de +
                          reaprovisionamiento &1.  &N Recobro  . . +
                          . :   Consiga el reaprovisionamiento del +
                          slot &1 y escanda/incorpore el slot +
                          &1.') SEV(30) FMT((*CHAR 12))
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
                          MSG('Slot invalido.') SECLVL('Causa . . . +
                          . . :   El numero de slot escandido/+
                          incorporado es diferente que el slot de +
                          guardar &1.  &N Recobro  . . . :   Guarde +
                          el reaprovisionamiento en el slot &1 y +
                          escanda/incorpore el slot +
                          &1.') SEV(30) FMT((*CHAR 12))
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
                          MSG('La cantidad incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   La cantidad +
                          nueva incorporada &2 es mas que &1. &N +
                          Recobro . . . :   Incorpora una cantidad +
                          que es menos que o igual a +
                          &1.') SEV(30) FMT((*DEC 7) (*DEC +
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

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Las +
                          dos no pueden ser "Y".') SECLVL('Causa . . +
                          . . . :   Las opciones de producto y +
                          cantidad son fijas a "Y" por si. &N Recobro +
                          . . . :   Fije una de las opciones a "N" +
                          por "no" e intente otra vez.') SEV(30)
             ENDDO

/*  IT29005 Only one of the options can be "N" (Yes).        */

             CHGVAR     VAR(&MSGID) VALUE('IT29005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Las +
                          dos no pueden ser "N"(no).') SECLVL('Causa +
                          . . . . . :   Las opciones de producto y +
                          cantidad son fijas a "N" por No. &N Recobro +
                          . . . :   Fije una de las opciones a "Y" +
                          por "si" e intente otra vez.') SEV(30)
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
                          hay mas let-downs.') SECLVL('Causa . . . . +
                          . :   No hay mas let-downs por el almacen +
                          seleccionado. &N Recobro  . . . :   Oprima +
                          F12 para cancelar e incorporar un almacen +
                          nuevo u oprima F3 para salir.') SEV(30)
             ENDDO

/*  IT31201 Must enter Base slot      */

             CHGVAR     VAR(&MSGID) VALUE('IT31201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                         puede incorporar un slot virtual.') +
                         SECLVL('Causa . . . . . :   No puede +
                         incorporar un slot virtual. &N Recobro . . . +
                         :   Incorpore el slot de base por el slot +
                         virtual.') SEV(30)
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
                          hay cantidad rota definida por el producto +
                          de base.') SECLVL('Causa . . . . . :   El +
                          producto de base por caja rota o mismo slot +
                          de cantidad caida no tiene una cantidad de +
                          caida definida. &N Recobro . . . :  Corrija +
                          la cantidad caida del producto de base e +
                          intente otra vez.') SEV(30)
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
                          MSG('El reaprovisionamiento potencial no +
                          pudo ser terminado - almacen invalido +
                          incorporado.') SECLVL('Causa . . . . . :  +
                          El numero incorporado &1 del almacen es +
                          invalido. &N Recobro . . . :   Seleccione +
                          otro almacen e intente otra vez.') +
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
                          MSG('Los dias a expirar no puede ser 0 +
                          cuando la opcion de productos expirados +
                          anteriores incluidos es N.') SECLVL('Causa +
                          . . . . . :   No puede seleccionar 0 dias +
                          para expirar si excluida productos +
                          expirados anteriores. &N Recobro . . . :   +
                          Incorpore "Y" para incluir productos +
                          expirados anteriores o incorpore un numero +
                          mas grande que 0 por dias para expirar.') +
                          SEV(30)
             ENDDO



             RETURN
             ENDPGM
