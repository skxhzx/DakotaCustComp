/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to IVMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  IVMSGD      Create PIRMSGF Message Descriptions IVpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  30 January 1996                                                 */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  4-26-99  V4.11  RH                                              */
/*    ADDED IV33001 AND IV33002                                     */
/*  5-06-99  V4.11  RH                                              */
/*    ADDED IV50027 AND IV50028 AND IV35421                         */
/*                                                                  */
/*  09/29/99 V4.12  DAS                                             */
/*    ADDED IV21302, IV21303 and IV21304                            */
/*                                                                  */
/*  03/03/00 V4.13  DAS                                             */
/*    ADDED IV50003, IV50004, IV50005                               */
/*  08/30/00 V4.14  RRH                                             */
/*    ADDED IV21202                                                 */
/*  1-27-03  V4.16  RH                                              */
/*    ADDED IV50029                                                 */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*  09/06/06 V5.10C RH                                              */
/*    ADDED IV21203                                                 */
/*  09/07/06 5.10d  RH                                              */
/*    ADDED IV21307                                                 */
/*  12/18/06 5.10f  RH                                              */
/*    ADDED IV33004                                                 */
/*  05/13/08 5.20b  RH                                              */
/*    ADDED IV33006                                                 */
/*  02/09/12 6.40A  LMC                                             */
/*    ADDED IV33007                                                 */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE('*LIBL')
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  IV11005 Slots are being selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Se estan seleccionando los slots. +
                          Tenga paciencia por favor.')
             ENDDO

/*  IV11006 Verifying slots haven't been selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Verificando que no se ha seleccionado +
                          ya los slots.')
             ENDDO

/*  IV11007 Verifying slots can be unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Verificando que los slots pueden ser +
                          deseleccionados.')
             ENDDO

/*  IV11008 Unselectin slots. */

             CHGVAR     VAR(&MSGID) VALUE('IV11008')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Deseleccionando los slots. Tenga +
                          paciencia por favor.')
             ENDDO

/*  IV11021 No records selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('+
                          Ningunos de los slots fueron seleccionados. +
                          Ponga el cursor en esta linea y oprima +
                          F1.') SECLVL('Causa . . . . . :   Ningunos +
                          de los slots correspondieron al criterio +
                          incorporado. &N Recobro . . . :  Incorpore +
                          criterio nuevo e intente otra vez.') SEV(30)
             ENDDO

/*  IV11022 Records were selected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots fueron seleccionados.') SECLVL('Causa +
                          . . . . . :   &1 slots fueron seleccionados +
                          basado en la escala incorporada. &N Recobro +
                          . . . :   Incorpore una escala diferente +
                          para seleccionar mas slots, u oprime F3 +
                          para volver al +
                          menu.') SEV(00) FMT((*DEC 7 0))
             ENDDO

/*  IV11023 Unmonitored error occured. */

             CHGVAR     VAR(&MSGID) VALUE('IV11023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Un error desadvertido ocurrio (&1).') +
                          SECLVL('Causa . . . . . :   La seleccion +
                          de SQL no termino a causa de codigo de +
                          error &1. &N Recobro . . . :   Relatelo al +
                          director de DP.') +
                          SEV(30) FMT((*DEC 5 0))
             ENDDO

/*  IV11024 Slots already exist for scope. */

             CHGVAR     VAR(&MSGID) VALUE('IV11024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          selecciono` ningunos de los slots. &1 +
                          fueron seleccionados antes.') SECLVL('Causa +
                          . . . . . :   &1 slots fueron seleccionados +
                          en el archivo de trabajo de inventario que +
                          caben entre la escala incorporada. Por eso +
                          ningunos slots nuevos fueron seleccionados. +
                          &N Recobro . . . :   Aclare el archivo de +
                          trabajo de inventarion e intente la +
                          seleccion otra vez o incorpore una escala +
                          diferente.') SEV(30) +
                          FMT((*DEC 7 0))
             ENDDO

/*  IV11025 Slots can not be unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Los slots no pueden ser +
                          deseleccionados. Los numeros de las paginas +
                          han sido generados ya.') SECLVL('Causa . . +
                          . . . :   Los numeros de las paginas han +
                          sido generados ya por los slots que intenta +
                          deseleccionar. &N Recobro . . . : Las +
                          paginas deben ser incorporadas, el +
                          inventario cerrado, y el proceso empezado +
                          otra vez.') SEV(30)
             ENDDO

/*  IV11026 Slots were unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots fueron deseleccionados.') +
                          SECLVL('Causa . . . . . :   &1 slots +
                          fueron deseleccionados basado en la escala +
                          incorporada. &N Recobro . . . :   +
                          No hay recobro.') SEV(00) FMT((*DEC 7 0))
             ENDDO

/*  IV11027 No slots unselected. */

             CHGVAR     VAR(&MSGID) VALUE('IV11027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Ningunos de los slots fueron +
                          deseleccionados. Ponga el cursor en esta +
                          linea y oprima F1.') SECLVL('Causa . . . . +
                          . :  Ningunos de los slots correspondieron +
                          al criterio incorporado. &N Recobro . . . +
                          :   Incorpore el criterio nuevo e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  IV12521 sheets printed. */

             CHGVAR     VAR(&MSGID) VALUE('IV12521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          de las hojas del inventario fueron +
                          impresas.') SEV(0) +
                          FMT((*DEC 5 0))
             ENDDO

/*  IV21201 Qty entered without item number. */

             CHGVAR     VAR(&MSGID) VALUE('IV21201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad fue incorporada sin el +
                          numero de producto.') SECLVL('Causa . . . . +
                          . :   La cantidad fue incorporada pero +
                          ningun numero del producto fue incorporado. +
                          &N Recobro . . . :   Incorpore el numero +
                          del producto e intente otra vez.') SEV(30)
             ENDDO

/*  IV21202 Cannot change item, pending qty exists. */

             CHGVAR     VAR(&MSGID) VALUE('IV21202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede cambiar el producto, una +
                          cantidad pendiente existe.') SECLVL('Causa +
                          . . . . . :   Una cantidad existe que es +
                          diferente que la cantidad del inventario. +
                          &N Recobro . . . :   Remueva fisicamente +
                          el producto del slot.') SEV(30)
             ENDDO

/*  IV21203 Cannot count item, pending qty exists. */

             CHGVAR     VAR(&MSGID) VALUE('IV21203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede contar el producto, una +
                          cantidad pendiente existe.') SECLVL('Causa +
                          . . . . . :   Una cantidad existe que es +
                          diferente que la cantidad del inventario. +
                          &N Recobro . . . :   Remueva fisicamente +
                          el producto del slot.') SEV(30)
             ENDDO

/*  IV21301 Item exists in physical location. */

             CHGVAR     VAR(&MSGID) VALUE('IV21301')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El producto existe en una ubicacion +
                          fisica.') SECLVL('Causa . . . . . :   +
                          Este producto existe en el slot fisico o +
                          slot virtual. &N Recobro  . . . : +
                          Incorpore un slot diferente e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  IV21302 Slot is not a physical slot */

             CHGVAR     VAR(&MSGID) VALUE('IV21302')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot &1 no es un slot fisico.') +
                          SECLVL('Causa . . . . . :   El slot &1 es +
                          un slot virtual. Un slot virtual solamente +
                          puede ser creado por un slot fisico. &N +
                          Recobro . . . :   Incorpore un slot fisico +
                          e intente otra vez.') SEV(30) +
                          FMT((*CHAR 12))
             ENDDO

/*  IV21303 Virtual slot not allowed for physical slot */

             CHGVAR     VAR(&MSGID) VALUE('IV21303')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Los slots virtuales no son permitidos +
                          por los slots con un handstack de dos +
                          caracteres.') SECLVL('Causa . . . . . : El +
                          slot fisico, &1, tiene un codigo de +
                          handstack de dos caracteres. Un slot +
                          virtual usa una posicion de codigo de +
                          handstack para hacerlo un slot unico en el +
                          sistema. Por eso, algun slot que usa las +
                          dos posiciones de codigo del handstack no +
                          puede tener un slot virtual que +
                          corresponde. &N Recobro . . . : +
                          Seleccione un slot que no tiene un codigo +
                          de handstack o que solamente usa una +
                          posicion del codigo e intente otra +
                          vez.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IV21304 Virtual slot could not be created. */

             CHGVAR     VAR(&MSGID) VALUE('IV21304')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Un slot virtual no pudo ser creado +
                          por &1.') SECLVL('Causa . . . . . :   Un +
                          slot virtual no pudo ser creado por el slot +
                          fisico &1. Hay dos posibilidades: el slot +
                          fisico ya tiene el numero maximo de slots +
                          virtuales ajuntados a si mismo, o el slot +
                          fisico es un slot de handstack que usa las +
                          dos posiciones del campo de handstack. &N +
                          Recobro  . . . :   Verifique con cero +
                          algunos slots virtuales por el slot fisico +
                          o seleccione un slot diferente para +
                          transferir el producto. Entonces intente +
                          otra vez.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  IV21307 UCI already entered in inventory. */

             CHGVAR     VAR(&MSGID) VALUE('IV21307')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El UCI ya es incorporado en el +
                          inventario.') SECLVL('Causa . . . . . :   +
                          El UCI ya es incorporado en el inventario +
                          &N Recobro  . . . :   Escanda otro slot e +
                          intente otra vez.') SEV(30)
             ENDDO

/*  IV33001 No team defined for date. */

             CHGVAR     VAR(&MSGID) VALUE('IV33001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Ninguno equipo definido por la +
                          fecha.') SECLVL('Causa . . . . . :   +
                          Ninguno equipo es definido con la fecha +
                          incorporada. &N Recobro . . . :   Defina +
                          el equipo o corrijalo e intente otra +
                          vez.') SEV(30)
             ENDDO


/*  IV33002 Slot not in inventory scope. */

             CHGVAR     VAR(&MSGID) VALUE('IV33002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El slot no esta en la escala del +
                          inventario.') SECLVL('Causa . . . . . :   +
                          El slot no es definido en la escala de +
                          inventario. &N Recobro . . . :   Escanda el +
                          slot correcto e intente otra vez.') SEV(30)
             ENDDO

/*  IV33003 Slot already entered in inventory. */

             CHGVAR     VAR(&MSGID) VALUE('IV33003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El slot ya es incorporado en el +
                          inventario.') SECLVL('Causa . . . . . :   +
                          El slot ya es incorporado en el inventario +
                          &N Recobro  . . . :   Escanda otro slot e +
                          intente otra vez.') SEV(30)
             ENDDO

/*  IV33004 Option not set for Add.   */

             CHGVAR     VAR(&MSGID) VALUE('IV33004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede anadir el prod al +
                          slot.') SECLVL('Cause . . . . . :   +
                          No puede anadir el producto al slot. +
                          &N Recovery  . . . :   Markque excepcion +
                          y notifiquele al director.') SEV(30)
             ENDDO


/*  IV33006 Qty entered without item confirmed  */

             CHGVAR     VAR(&MSGID) VALUE('IV33006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad fue introducida sin la +
                          confirmacion de producto.') SECLVL('Causa . +
                          . . . :   La cantidad fue incorporada pero +
                          ninguna confirmacion del producto fue +
                          introducida. &N Recobro . . . : +
                          Introduzca la confirmacion +
                          del producto e intente otra vez.') SEV(30)
             ENDDO

/*  IV33007 COunt print sheet option has not been run.     */

             CHGVAR     VAR(&MSGID) VALUE('IV33007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Print Sheet Option must be run') +
                                      SECLVL('Cause . . . :   +
                          Inventory Control must print sheets before +
                          entry      . &N Recovery  . . . :   Print +
                          Sheets and try again.') SEV(30)
             ENDDO

/*  IV35421 Inventory Exception cleared. */

             CHGVAR     VAR(&MSGID) VALUE('IV35421')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          es aclarado.') SECLVL('No hay mas +
                          informacion de este mensaje.') SEV(00) +
                          FMT((*CHAR 50))
             ENDDO


/*  IV50003 Crete FTP expor file */ /* 413 A */

             CHGVAR     VAR(&MSGID) VALUE('IV50003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cree un archivo exportado de +
                          FTP.') SEV(00)
             ENDDO

/*  IV50004 Move records to history files */ /* 413 A */

             CHGVAR     VAR(&MSGID) VALUE('IV50004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Mueva +
                          las anotaciones a los archivos +
                          historicos.') SEV(00)
             ENDDO

/*  IV50005 Export counts via FTP */ /* 413 A */

             CHGVAR     VAR(&MSGID) VALUE('IV50005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La exportacion cuenta por medio de +
                          FTP.') SEV(00)
             ENDDO

/*  IV50021 Updating slot quantities and item numbers */

             CHGVAR     VAR(&MSGID) VALUE('IV50021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Poniendo al dia cantidades de los +
                          slots y numeros de los productos.') SEV(00)
             ENDDO

/*  IV50022 Updating slot status codes */

             CHGVAR     VAR(&MSGID) VALUE('IV50022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Poniendo al dia los codigos de +
                          estado de los slots.') SEV(00)
             ENDDO

/*  IV50023 Uping slot breakdown quantities */

             CHGVAR     VAR(&MSGID) VALUE('IV50023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Subiendo las cantidades de almacen +
                          de las cantidades del slot.') +
                          SEV(00)
             ENDDO

/*  IV50024 Recalculating warehouse qtys from slot qtys */

             CHGVAR     VAR(&MSGID) VALUE('IV50024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Recalculando las cantidades separadas +
                          de los almacenes.') SEV(00)
             ENDDO

/*  IV50025 Uping warehouse breakdown quantites */

             CHGVAR     VAR(&MSGID) VALUE('IV50025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Subiendo las cantidades seperadas de +
                          los almacenes.') SEV(00)
             ENDDO

/*  IV50026 Can not post, some sheets not entered.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede anunciar, algunas hojas no +
                          son incorporadas.') SECLVL('Causa . . . . . +
                          :   No puede anunciar, alguna hojas no son +
                          incorporadas. &N Recobro . . . :   Use F9 +
                          para ver el estado del inventario.') SEV(30)
             ENDDO

/*  IV50027 Can not post, some slots not entered.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede anunciar, algunos slots no +
                          son incorporados.') SECLVL('Causa . . . . . +
                          :   No puede anunciar, algunos slots no son +
                          incorporados. &N Recobro . . . : Use F9 +
                          para ver el estado del inventario.') SEV(30)
             ENDDO

/*  IV50028 Can not post, inventory exceptions exust.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50028')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede mostrar, excepciones del +
                          inventario existen.') SECLVL('Causa . . . +
                          . . :   No puede mostrar, algunas +
                          excepciones existen. &N Recobro . . . : +
                          Use F9 para ver el estado del +
                          inventario.') SEV(30)
             ENDDO

/*  IV50029 Can not post, Error slots exist.*/

             CHGVAR     VAR(&MSGID) VALUE('IV50029')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede anunciar, slots de inventario +
                          tienen errores.') SECLVL('Causa . . . . . : +
                          No puede mostrar, algunos errores de los +
                          slots existen. &N Recobro . . . : Use F9 +
                          para ver el estado del inventario.') SEV(30)
             ENDDO

/*  IV51021 Updating slots for warehouse/dept/section. */

             CHGVAR     VAR(&MSGID) VALUE('IV51021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Poniendo al dia los slots del almacen +
                          &1, departamento, &2, seccion +
                          &3.') SEV(00) +
                          FMT((*DEC 3) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  IV52021 Updating warehouse counts for warehouse/dept. */

             CHGVAR     VAR(&MSGID) VALUE('IV52021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Poniendo al dia las cuentas del +
                          almacen &1, Departmento &2.') SEV(00) +
                          FMT((*DEC 3) (*CHAR 5))
             ENDDO

/*  INV7978  Next page record is locked. */

             CHGVAR     VAR(&MSGID) VALUE('INV7978')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          proxima anotacion de numero de la hoja esta +
                          cerrada por otro usuario.') SECLVL('Causa +
                          . . . . . :   Otro usuario esta usandola. +
                          &N Recobro . . . Espere hasta el otro +
                          usuario termina e intente otra +
                          vez.') SEV(30)
             ENDDO

             RETURN
             ENDPGM
