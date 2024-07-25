/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to PIRMSGD                     */
/********************************************************************/
/*                                                                  */
/*  PIRMSGF     Create PIRMSGF Message Descriptions PIRnnnn         */
/*              Standard messages for PIR                          */
/*  14 February 1991                                                */
/*  Dave Sommerville                                                */
/*  12/20/98  RH  4.10  Add PIR2101 message.                       */
/*  10/05/99  MLB 4.13  Add PIR1021 message.                       */
/*  12/08/99  MLB 4.13  Add PIR0123 message.                        */
/*  12/28/99  MLB 4.13  Add PIR0124 message.                        */
/*  04/12/00  MLB 4.14  Add PIR9907 message.                        */
/*  07/06/00  MLB 4.14  Add PIR1051 message.                        */
/*  04/18/01  DAS 4.15  Add PIR7983 message.                        */
/*  07/31/01  MLB 4.16  Add PIR1052 message.                        */
/*  04/25/02  MLB 4.16  Add PIR1053 message.                        */
/*  04/26/02  MLB 4.16  Add PIR1054 message.                        */
/*  04/28/02  MLB 4.16  Add PIR1055 message.                        */
/*  04/28/02  MLB 4.16  Add PIR1056 message.                        */
/*  07/25/02  MLB 4.16  Add PIR9908 message.                        */
/*  11/26/02  MLB 4.16  Add PIR1057 message.                        */
/*  11/26/02  MLB 4.16  Add PIR1058 message.                        */
/*  11/26/02  MLB 4.16  Add PIR1059 message.                        */
/*  12/04/02  MLB 4.16  Add PIR2007 message.                        */
/*  01/16/03  RH  4.17  Add PIR4001 message.                        */
/*  10/14/03  RH  4.17b Add PIR4001 message.                        */
/*  02/11/04  RH  4.17c Add PIR9909 message.                        */
/*  08/19/04  MLB 4.17d Add PIR1060 message.                        */
/*                      Add PIR1061 message.                        */
/*  11/17/04  RH  5.00a Add PIR0206 message.                        */
/*  11/28/05  JJ  5.00b Add PIR1011 message.                        */
/*  12/21/05  JJ  5.00c Add PIR1012 message.                        */
/*  12/23/05  JJ  5.00d Add PIR1013 message.                        */
/*  01/02/06  JJ  5.00e Add PIR1014 message.                        */
/*  02/23/06  JJ  5.00f Add PIR1015 message.                        */
/*  03/10/06  JJ  5.00g Add PIR1016 message.                        */
/*  04/03/06  JJ  5.00h Add PIR1017 message.                        */
/*                      Add PIR1018 message.                        */
/*  04/12/06  JJ  5.00i Add PIR1019 message.                        */
/*  04/19/06  DAS 5.00j Add PIR1062 message.                        */
/*                      Add PIR1063 message.                        */
/*                      Add PIR1064 message.                        */
/*  05/05/06  JJ  5.00k Add PIR1020 message.                        */
/*                      Add PIR1022 message.                        */
/*                      Add PIR1023 message.                        */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*                                                                  */
/*  07/10/06  MLB 5.10  Add PIR0751 message.                        */
/*  09/11/06  RAH 5.10  Add PIR9910 message.                        */
/*  09/14/06  RAH 5.10  Add PIR9911 message.                        */
/*                      Add PIR9912 message.                        */
/*  09/27/06  RAH 5.10  Add PIR9999 generic message.                */
/*  10/19/06  MLB 5.10  Add msg's PIR0125 - PIR0138.                */
/*  01/27/07  MLB 5.10a Add msg's PIR0141 - PIR0142.                */
/*  03/21/07  TJ  5.10B Add msg's PIR0143.                          */
/*  08/10/07  JCJ 5.10c Add msg's PIR0144.                          */
/*  08/10/07  JCJ 5.10c Add msg's PIR0145.                          */
/*  09/05/07  JCJ 5.10d Add msg's PIR0146.                          */
/*  09/07/07  LMC 5.10e Add msg's PIR0147.                          */
/*  09/21/07  DAS 5.10f Add msg's PIR0148.                          */
/*  01/09/18  MLB 7.10  Add msg PIR1393                             */
/*                                                                  */
/********************************************************************/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  PIR0001 Option under construction */

             CHGVAR     VAR(&MSGID) VALUE('PIR0001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Se  +
                          esta mejorando la opcion seleccionada y no +
                          es disponible.') SECLVL('Causa . . . . +
                          . :   Se esta mejorando la opcion +
                          seleccionada y no es disponible ahora. +
                          &N Recobro  . . . :   Establezca contacto +
                          con el director de DP para recibir mas +
                          instrucciones.') SEV(0) +
                          FMT((*CHAR 6))
             ENDDO

/*  PIR0101 Program not found */

             CHGVAR     VAR(&MSGID) VALUE('PIR0101')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El programa &1 no fue encontrado por +
                          la opcion &2.') SECLVL('Causa . . . . . :   +
                          La opcion &2 llama al programa &1, lo que +
                          no fue encontrado. &N Recobro . . . :   +
                          Establezca contacto con el director de DP +
                          para recibir mas instrucciones.') SEV(30) +
                          FMT((*CHAR 10) (*CHAR 6))
             ENDDO

/*  PIR0102 Program not found.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0102')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El programa &1 no fue encontrado por +
                          F&2.') SECLVL('Causa . . . . . :   F&2 +
                          llama al programa &1 que no fue encontrado. +
                          &N Recobro  . . . . :   Establezca contacto +
                          con el director de DP para recibir mas +
                          instrucciones.') SEV(30) +
                          FMT((*CHAR 10) (*CHAR 6))
             ENDDO

/*  PIR0103 Program not found. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0103')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El programa &1 no fue encontrado +
                          cuando realizando la subrutina &2.') +
                          SECLVL('Causa . . . . . :   La subrutina +
                          &2 llama al programa &1 lo que no fue +
                          encontrado. &N Recobro . . . :  Establezca +
                          contacto con el director de DP para recibir +
                          mas instrucciones.') SEV(30) FMT((*CHAR 10) +
                          (*CHAR 6))
             ENDDO

/*  PIR0104 Invalid key pressed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0104')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Se +
                          ha oprimido una tecla invalida.') +
                          SECLVL('Causa . . . . . :   La tecla de +
                          funcion oprimida no es valida por la +
                          exhibicion actual. &N Recobro  . . . :   +
                          Examine al fondo de la exhibicion por las +
                          leclas de funciones validas por esta +
                          exhibicion.') +
                          SEV(30)
             ENDDO

/*  PIR0105 No more help. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0105')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('&1') SECLVL('Causa . . . . . :   +
                          No hay mas ayuda por este mensaje.') +
                          SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR0106 Invalid cursor position. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0106')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La posicion de cursor es invalida por +
                          "Moverse arriba."') SECLVL('Causa . . . . : +
                          . :   El cursor no esta en la anotacion +
                          mostrada. &N Recobro . . . :   Mueve el +
                          cursor a la anotacion que quiere colocar a +
                          la cabeza de la exhibicion e intente la +
                          operacion otra vez.') SEV(30)
             ENDDO

/*  PIR0107 Invalid value for "Position to". */

             CHGVAR     VAR(&MSGID) VALUE('PIR0107')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El valor incorporado por "Colocar a" +
                          no es valido.') SECLVL('Causa . . . . . :  +
                          El valor incorporado por "Colocar a" no es +
                          valido. &N Recobro . . . . :   Incorpore un +
                          valor valido.') SEV(30)
             ENDDO

/*  PIR0108 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0108')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion &1 no es valida.') +
                          SECLVL('Causa . . . . . :   La opcion +
                          incorporada no es valida por la exhibicion +
                          que esta usando. &N Recobro . . . :   +
                          Examine la cabeza de la exhibicion para ver +
                          las opciones validas de esta +
                          exhibicion.') SEV(30) +
                          FMT((*CHAR 2))
             ENDDO

/*  PIR0109 Number can not be less than zero. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0109')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          no puede ser menos que 0.') +
                          SECLVL('Causa . . . . . :   El valor +
                          incorporado por &1 es negativo. &N Recobro +
                          . . . :   Incorpore un valor que es menos +
                          que o igual a 0.') SEV(30) +
                          FMT((*CHAR 40))
             ENDDO

/*  PIR0110 Number must be greater than zero. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0110')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser mas grande que 0.') +
                          SECLVL('Cause . . . . . :   El valor +
                          incorporado por &1 es 0 o negativo. &N +
                          Recobro  . . . :   Incorpore un valor que +
                          es mayor que 0.') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0111 Error occured when calling receiving label program. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0111')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Un error ocurrio tratando de llamar +
                          al programa &2.') SECLVL('Causa . . . . . +
                          :   Un error ocurrio cuando se trato de +
                          llamar el programa &1 el programa &2. &N +
                          Recobro . . . Establezca contacto con el +
                          director de DP.') SEV(30) +
                          FMT((*CHAR 30) (*CHAR 10))
             ENDDO

/*  PIR0112 Valid range for field is ... */

             CHGVAR     VAR(&MSGID) VALUE('PIR0112')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La escala valida de &1 es &2 a &3.') +
                          SECLVL('Causa . . . . . :   El valor +
                          incorporado de &1 no esta en la escala de +
                          &2 a &3. &N Recobro  . . . :   Incorpore un +
                          valor que esta en la escala de &2 a &3.') +
                          SEV(30) FMT((*CHAR 30) (*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR0113 Field 1 must be greater than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0113')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser mas grande que o igual a &2.') +
                          SECLVL('Causa . . . . . :   El valor +
                          incorporado de &1 (&3) debe ser mas grande +
                          que o igual al valor incorporado de &2 +
                          (&4). &N Recobro  . . . :   Incorpore un +
                          valor que es mas grande que &2.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*DEC 3) (*DEC 3))
             ENDDO

/*  PIR0114 Invalid character used in quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0114')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Un caracter invalido (''&1'') usado en +
                          la cantidad.') SECLVL('Causa . . . . . :   +
                          El caracter ''&1'' en la posicion &2 es +
                          invalido por la cantidad. &N Recobro . . . +
                          :   Los caracteres validos por las +
                          cantidades son entre 0 y 9, y tambien entre +
                          ''.'' y ''-'' si los negativos son +
                          permitidos.') SEV(30) FMT((*CHAR 1) +
                          (*DEC 3))
             ENDDO

/*  PIR0115 Too many decimal points entered in quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0115')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Hay +
                          demasiados puntos decimales incorporados +
                          en la cantidad.') SECLVL('Causa . . . . . +
                          :   Se incorporo` mas que dos puntos +
                          decimales en la cantidad. &N Recobro . . . +
                          :   Reincorpore la cantidad con un maximo +
                          de dos puntos decimales.') SEV(30)
             ENDDO

/*  PIR0116 Quantity is too large. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0116')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad incorporada es demasiada +
                          grande.') SECLVL('Causa . . . . . :   +
                          Algunas de las cantidades individuales que +
                          se incorporo` son mas que 9.999.999. &N +
                          Recobro . . . . :   Este seguro que cada +
                          cantidad incorporada no es mas grande que +
                          9.999.999.') SEV(30)
             ENDDO

/*  PIR0117 Quantity could not be allocated in full. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0117')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad no pudo ser asignada +
                          completamente.') SECLVL('''Causa . . . . . +
                          :   La cantidad asignada (&1) fue mas +
                          grande que la cantidad disponible (&2). &N +
                          Recobro  . . . :   La cantidad real que fue +
                          asignada es &3. Si este no es satisfactorio +
                          necesitara` hacer ajustamientos para +
                          aumentar la cantidad +
                          disponible.') SEV(30) FMT((*CHAR 10) +
                          (*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR0118 Quantity could not be allocated in full. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0117')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad no pudo ser asignada +
                          completamente.') SECLVL('''Causa . . . . . +
                          :   La cantidad asignada (&1) fue mas +
                          grande que la cantidad disponible (&2). &N +
                          Recobro  . . . :   La cantidad real que fue +
                          asignada es &3. Si este no es satisfactorio +
                          necesitara` aumentar la cantidad +
                          disponible.') SEV(30) FMT((*CHAR 10) +
                          (*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR0119 Field 1 must be greater than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0119')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser mas grande o igual a &2.') +
                          SECLVL('Causa . . . . . :   El valor +
                          incorporado por &1 (&3) debe ser mas grande +
                          que o igual al valor incorporado &2 (&4). +
                          &N Recobro  . . . . :   Incorpore un valor +
                          que es mas grande que &2.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*DEC 9) (*DEC 9))
             ENDDO

/*  PIR0120 Value entered without option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0120')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El valor fue incorporado sin opcion.') +
                          SECLVL('Causa . . . . . :   Se ha +
                          incorporado un valor sin incorporando una +
                          opcion para operar el valor. &N +
                          Recobro . . . :   Incorpore una opcion +
                          valida o borre el valor.') SEV(30)
             ENDDO

/*  PIR0122 Invalid value entered for aisle. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0122')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Un valor invalido incorporado por el +
                          pasillo.') SECLVL('Causa . . . . . :  El +
                          pasillo &1 no existe. &N Recobro . . . . :  +
                           Incorpore un nombre valido del pasillo e +
                          intente otra +
                          vez.') SEV(30) FMT((*CHAR 4))
             ENDDO

/*  PIR0123 Replenishment quantity is not a multiple of pick quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0123')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad de reaprovisionamiento +
                          (&1) no es un multiple de la cantidad de +
                          escoger (&2).') SECLVL('Causa . . . . . +
                          :   La cantidad de reaprovisionamiento (&1) +
                          no es un multiple de la cantidad de escoger +
                          (&2). Hay (&3 &4) en cada unidad llena que +
                          es escogido. &N Recobro . . . :   Incorpore +
                          una cantidad de reaprovisionamiento que es +
                          un multiple de (&5) escogido multiplicado +
                          por (&3 &4) en cada unidad llena. Si hay +
                          menos que una unidad llena escogida, +
                          tendras que hacer un ajustamiento del slot +
                          despues de la transaccion ha sido cerrada +
                          para corregir la cantidad en +
                          el slot.') SEV(30) FMT((*DEC 5) (*DEC 5) +
                          (*DEC 5) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  PIR0124 Day abbreviation not valid.                                */

             CHGVAR     VAR(&MSGID) VALUE('PIR0124')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          dia (&1) para computar los promedios no es +
                          una abreviacion valida .') SECLVL('Causa . +
                          . . . . :   La abrevacion (&1) de dia +
                          incorporada no es valida. &N Recobro . . . +
                          :   Incorpore alguna del siguiente por una +
                          abrevacion valida: SUN, MON, TUE, WED, THU, +
                          FRI o SAT.  Entonces intente otra +
                          vez.') SEV(30) FMT((*CHAR 3))
             ENDDO

/*  PIR0125 *Warning* Item File not found. Item Update not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0125')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* No encontro archivo del producto: &1. +
                          No proceso la actualizacion de la importacion del +
                          producto.') SECLVL('Causa . . . . . :   El archivo +
                          de semaforo fue encontrado del archivo: &1 pero el +
                          archivo con la data de importacion esta perdido. &N +
                          Recobro . . . : Verifique que los procesos del HOST +
                          estan creando el archivo de data correctamente. El +
                          nombre del archivo del semaforo debe corresponder +
                          al nombre de archivo de importacion sin prefijo S. +
                          Reiniciar el proceso del HOST para crear el archivo +
                          de actualizacion de producto y verifique mensajes +
                          despues de que archivo ha sido creados. Use mandato +
                          WRKLNK para verificar que los archivos existen en +
                          el directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0126 *Warning* P/O Hdr file not found. P/O Update not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0126')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* Archivo de Hdr del P/O : &1 no fue +
                          encontrado. Actualizacion del P/O no procesado.') +
                          SECLVL('Causa . . . . . :   El archivo de semaforo +
                          no fue encontrado del archivo: &1 pero el archivo +
                          de Hdr del P/O con la data de importacion esta +
                          perdida. &N Recobro . . . : Verifique que procesos +
                          de HOST estan creando archvivo de data correctamente +
                          El nombre de archivo del archivo de semaforo debe +
                          corresponder al nombre de archivo de Hdr del P/O +
                          sin prefijo S. Reinciar el proceso de HOST para +
                          creare archivo de actualizacion de P/O y verifique +
                          mensajes despues de que le archivo ha sido creados. +
                          Use mandato WRKLNK para verificar que los archivos +
                          hay en directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0127 *Warning* P/O Dtl file not found. P/O Update not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0127')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* archivo de P/O Dtl: &1 no fue  +
                          encontrado. No proceso la actual. de P/O.') +
                          SECLVL('Causa . . . . . :   El archivo de +
                          semaforo fue encontrado de: &1 pero el archivo de +
                          detalle de P/O con la data de importacion esta  +
                          perdida. &N Recobro . . . : Verifique que los +
                          procesos del HOST estan creando el archivo de +
                          data. El nombre de archivo del archivo de semaforo +
                          debe corresponder al archivo de detalle de +
                          importacion de P/O sin prefijo S. Reiniciar el +
                          proceso de HOST para crear el archivo de importacion +
                          de actualizacion de P/O.  Verifique que los archivos +
                          han sido creados. Use WRKLNK para verificar que los +
                          archivos hay en el directorio correcto.') SEV(30) +
                          FMT((*CHAR 128))
             ENDDO

/*  PIR0128 *Warning* Customer Order Hdr not found. Cust. Ord not processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0128')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* No encontro archivo de : &1 +
                          pedido de cliente. No proceso pedidos de cliente +
                          importados.') SECLVL('Causa . . . . . : El archivo +
                          de semaforo no fue encontrado del archivo: &1 +
                          pero el archivo de pedido de cliente con la data +
                          importada esta perdido. &N Recobro . . . : +
                          Verifique que los procesos del HOST estan creando +
                          el archivo de data correctamente. El nombre del +
                          archivo del arhivo de semaforo debe corresponder +
                          al archivo de pedido de cliente sin el prejifo S. +
                          Reintente proceso del HOST para crear el archivo +
                          de pedidos de cliente y verifique los mensajes +
                          despues de el archivo ha sido creado. Use mandato +
                          WRKLNK para verificar que los archivos existen en +
                          el directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0129 *Warning* Customer Order Dtl not found. Cust. Ord not processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0129')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* No encontro archivo de detalle de +
                          cliente: &1. No proceso pedidos de cliente +
                          importados.') SECLVL('Causa . . . . . : El archivo +
                          de semaforo fue encontrado del archivo: &1 pero +
                          el archivo de detalles del pedido de cliente con la +
                          data importada esta perdida. &N Recobro . . . : +
                          Verifique que los procesos del HOST estan creando +
                          el archivo de data correctamente. El nombre del +
                          archivo de semaforo debe corresponder al archivo +
                          de detalles de pedidos de clientes sin el prefijo +
                          S. Reintente los procesos del HOST para crear los +
                          archivos importados de pedidos de cliente y +
                          verifique los mensajes despues de crear el archivo. +
                          Use cmd WRKLNK para verificar que los archivos hay +
                          en el directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0130 *Warning* Item Misc File not found. Item Update cancelled. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0130')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('*Aviso* No +
                          encontro archivo de Producto Misc: &1. No +
                          proceso la actualizacion de producto importado +
                          .') SECLVL('Causa . . . . . :   El archivo de +
                          semaforo fue encontrado del archivo: &1 pero el +
                          archivo del producto con la data importada esta +
                          perdida. &N Recobro . . . : Verifique que los +
                          procesos del HOST estan creando el archivo de data +
                          correctamente. El nombre del archivo de semaforo +
                          debe corresponder al nombre de archivo de producto +
                          importado sin prefijo S. Reintente procesos de HOST +
                          para crear el archivo de actualizacion de producto +
                          importado y verifique mensajes despues de crear el +
                          archivo. Use cmd WRKLNK para verificar que archivos +
                          hay en directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0131 P/O Hdr Misc file not found. P/O Update Cancelled.               */

             CHGVAR     VAR(&MSGID) VALUE('PIR0131')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('*Aviso* No +
                          encontro archivo de Hdr Misc: &1. No proceso la +
                          actualizacion de P/O importado.') +
                          SECLVL('Causa . . . . . :   El archivo de semaforo +
                          fue encontrado del archivo: &1 pero el archivo de +
                          P/O Hdr Misc con la data importada esta perdida. +
                          &N Recobro . . . : Verifique que los procesos de +
                          HOST estan creando el archivo de data correcta+
                          mente. El nombre de archivo del archivo de semaforo +
                          debe corresponder al nombre de archivo de P/O Hdr +
                          Misc sin el prefijo S. Reintente el proceso de HOST +
                          para crear el archivo de importar la actual. de P/O +
                          y verifique mensajes despues de crear el archivo. +
                          Use el mandato WRKLNK para verificar que los +
                          archivos estan en el directorio +
                          correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0132 P/O Dtl Misc file not found. P/O Update Cancelled.               */

             CHGVAR     VAR(&MSGID) VALUE('PIR0132')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('*Aviso* No +
                          encontro el archivo de P/O Dtl Misc: &1. No +
                          proceso la actualizacion de P/O importado +
                          .') SECLVL('Causa . . . . . :   El archivo de +
                          semaforo fue encontrado del archivo: &1 pero el +
                          el archivo de P/O Detail Misc con la data importada +
                          esta perdida. &N Recobro . . . : Verifique que los +
                          procesos del HOST estan creando el archivo de +
                          data correctamente. El nombre de archivo de archivo +
                          de semaforo debe corresponder al archivo Import P/O +
                          Detail Misc file name minus S prefix. +
                          Reintente el proceso de HOST para crear el archivo +
                          de actual. de P/O y verifique los mensajes despues +
                          de el archivo ha sido creado. Use cmd WRKLNK para +
                          verificar que los archivos existen en el +
                          directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0133 Cust Order Hdr Misc file not found. Customer Orders Cancelled.   */

             CHGVAR     VAR(&MSGID) VALUE('PIR0133')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* No encontro el archivo de pedido de +
                          Hdr Misc: &1. No proceso los pedidos importados de +
                          clientes.') +
                          SECLVL('Causa . . . . . :   El archivo de semaforo +
                          fue encontrado de archivo: &1 pero el archivo de +
                          pedido de cliente Hdr Misc. con el data importada +
                          esta perdida. &N Recobro . . . Verifique que los +
                          procesos de HOST estan creando el archivo de data +
                          correctamente. El nombre de archivo del archivo de +
                          semaforo debe corresponder al nombre de archivo de +
                          pedido de cliente Hdr Misc sin el prefijo S. +
                          Reintente los procesos de HOST para crear archivo +
                          de pedidos de clientes y verifique los mensajes +
                          despues de el archvio ha sido creado. Use cmd +
                          WRKLNK parra verificar que los archivos existen en +
                          directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0134 Cust Order Dtl Misc file not found. Customer Orders Cancelled.   */

             CHGVAR     VAR(&MSGID) VALUE('PIR0134')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Aviso* No encontro el archivo de pedidos de +
                          cliente de Dtl Misc: &1. No proceso los pedidos +
                          importados de cliente.') +
                          SECLVL('Causa . . . . . :   El archivo de semaforo +
                          fue encontroado de: &1 pero el archivo de +
                          pedidos importados de cliente con la data +
                          importada esta perdida. &N Recobro . . . : +
                          Verifique que los procesos de HOST estan creando +
                          el archivo de data correctamente. El nombre de +
                          archivo de semaforo debe corresponder al archivo de +
                          pedido de clientes de Dtl Misc sino el prefijo S. +
                          Reintente los procesos del HOST para crear archivos +
                          de pedidos importados de clientes y verifique los +
                          mensajes despues de crear el archivo. Use mandato +
                          WRKLNK para verificar que los archivos hay en el +
                          directorio correcto.') SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0135 Error copying files. Import Item Update not processed.           */

             CHGVAR     VAR(&MSGID) VALUE('PIR0135')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copiando archivos de: &1. Actual. de +
                          producto importado no fue procesado.') +
                          SECLVL('Causa . . . . . :   Error ocurrio durante +
                          el proceso de copiar los archivos del directorio +
                          de importacion a los  archivos de data importada. +
                          &N Recovery . . . : Busca mensajes anteriores en +
                          las coletas de mensaje IMPITEM y   +
                          IMPITEMERR para encontrar mas detalles. El +
                          archivo de semaforo renombrado a Err_&1. El +
                          archivo de Semaforo y archivo de data no fue +
                          borrado del directorio. El archivo de Semaforo y +
                          archivo de data importada tienen que estar borrado +
                          a mano. Use el mandato WRKLNK para borrar los +
                          archivos. Corrija los errores e intente otra  +
                          vez.') SEV(30) FMT((*CHAR +
                          128))
             ENDDO

/*  PIR0136 Error copying files. Import P/O Update not processed.            */

             CHGVAR     VAR(&MSGID) VALUE('PIR0136')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copiando archivos de: &1. P/O de +
                          importacion no fue encontrado.')  SECLVL('Causa +
                          . . . . . :   Un error ocurrio mientras copiando +
                          los archivos del directorio de importacion a los +
                          archivos de data importada. &N Recobro  . . . : +
                          Busques mansajes anteriores en las coletas de +
                          mensaje IMPPO e IMPPOERR para encontrar mas +
                          detalles. El archivo de semaforo fue renombrado a +
                          Err_&1. El archivo de semaforo y el archivo de data +
                          importado no fueron borrados del diccionario. El +
                          archivo de semaforo y el archvio de data importada +
                          necesitaran ser borrados manualmente. Use cmd +
                          WRKLNK para borrar los archivos. Corrija errores e +
                          intente otra vez.') +
                          SEV(30) FMT((*CHAR 128))
             ENDDO

/*  PIR0137 Error copying files. Import Customer Orders not processed.        */

             CHGVAR     VAR(&MSGID) VALUE('PIR0137')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copiando los archivos de: &1. No +
                          proceso los pedidos de importacion de cliente.') +
                          SECLVL('Causa . . . . . :   Un error ocurrio +
                          mientras cpiando los archivos del directorio de +
                          importaction al archivos de data importada. &N +
                          Recobro . . . : Busque mensajes enteriores en las +
                          coletas de mensajes IMPORD e IMPORDERR para +
                          encontrar mas detalles. El archivo de semforo fue +
                          renombrado a Err_&1. El archivo de semaforo y el +
                          archivo de data importada no fueron borrados del +
                          directorio. El archivo de semaforo y el archivo de +
                          data importada necesitaran ser borrados manualmente +
                          Use cmd WRKLNK para borrar los archivos. Corrija +
                          errores e intente otra +
                          vez.') SEV(30) FMT((*CHAR +
                          128))
             ENDDO

/*  PIR0138 Error deleting files. Manual cleanup required.                    */

             CHGVAR     VAR(&MSGID) VALUE('PIR0138')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error borrando archivos de : &1. Requiere +
                          limpia.') SECLVL('Causa . . . . +
                          . :   Un error ocurrio mientras borrando los +
                          archivos de directorio de importacion. &N Recobro +
                          . . . : Busque mensajes anteriores en las coletas +
                          de mensajes para encontrar mas detalles. El +
                          archivo &1 debe ser borrado manualmente. Use +
                          cmd WRKLNK para borrar el archivo. Corrija +
                          errores e intente otra +
                          vez.') SEV(30) FMT((*CHAR 128))
             ENDDO

/* TRANSLATE */
/*  PIR0141 *Warning* Slot StuffIt3 File not found. Slot Upd not Processed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0141')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('*Warning* Slot file: &1 not found. +
                          Import Slot StuffIt3 Update not processed.') +
                          SECLVL('Cause . . . . . :   The semaphore +
                          file was found for file: &1 but the Slot +
                          file with the import data is missing. &N +
                          Recovery . . . : Verify Host processes +
                          are properly creating data file. File +
                          name from semaphore file must match +
                          Import Slot StuffIt3 file name minus S prefix. +
                          Re-run Host process to create Import Slot +
                          StuffIt3 Update file and check messages after file +
                          has been created. Use cmd WRKLNK to +
                          verify files exist in correct +
                          directory.') SEV(30) FMT((*CHAR 128))
             ENDDO

/* TRANSLATE */
/*  PIR0142 Error copying files. Import Slot StuffIt3 Update not processed.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0142')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Error copying files for: &1. Import +
                          Slot StuffIt3 Update not processed.') +
                          SECLVL('Cause . . . . . :   An error +
                          occured while copying files from import +
                          directory to import data files. &N +
                          Recovery . . . : Check for previous +
                          messages in message queues IMPSTUF and +
                          IMPSTUFERR for additional details. +
                          Semaphore file renamed to Err_&1. +
                          Semaphore file and import data file not +
                          deleted from directory. Semaphore file +
                          and import data file will need to be +
                          deleted manually. Use cmd WRKLNK to +
                          delete files. Correct errors and then try +
                          your request again.') SEV(30) FMT((*CHAR +
                          128))
             ENDDO

/* TRANSLATE */
/*  PIR0143 Item Must Be Repack Item Type 'R'             */

             CHGVAR     VAR(&MSGID) VALUE('PIR0143')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must be Repack Item.') +
                          SECLVL('Cause . . . . . :   &1 must be Item +
                          Type R Repack. +
                          &N Recovery  . . . :   Enter a Repack +
                          Item or press F12 to cancel.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/* TRANSLATE */
/*  PIR0144 uci must be flagged as in stock               */

             CHGVAR     VAR(&MSGID) VALUE('PIR0144')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          must in stock.') +
                          SECLVL('Cause . . . . . :   &1 sock code is +
                          " " or "N". +
                          &N Recovery  . . . :   Change the stock +
                          flag to "Y".') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/* TRANSLATE */
/*  PIR0145 uci number is invalid                         */

             CHGVAR     VAR(&MSGID) VALUE('PIR0145')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          in not found.') +
                          SECLVL('Cause . . . . . :   &1 not found +
                          in the UCI file. +
                          &N Recovery  . . . :   Add uci number +
                          using the UCI Maintenance program.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/* TRANSLATE */
/*  PIR0146 license number already entered                */

             CHGVAR     VAR(&MSGID) VALUE('PIR0146')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 already assigned to +
                          transaction &2.') SECLVL('Cause . . . . . +
                          :   License &1 was previously assigned to +
                          transaction &2. &N Recovery  . . . :   +
                          Scan a different license number not +
                          assigned to a transaction.') SEV(30) +
                          FMT((*CHAR 15) (*CHAR 7))
             ENDDO

/* TRANSLATE */
/*  PIR0147 Unload seq of zero is not valid            */

             CHGVAR     VAR(&MSGID) VALUE('PIR0147')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Unload sequence zero is invalid') +
                          SECLVL('Enter an unload sequence greater +
                          than zero.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 7))
             ENDDO

/* TRANSLATE */
/*  PIR0148  User not athorized to use option/function */

             CHGVAR     VAR(&MSGID) VALUE('PIR0148')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('User +
                          &1 is not authorized to use &2.') +
                          SECLVL('Cause . . . . . :   User &1 has +
                          not been given the authority to use &2. +
                          &N Recovery  . . . :   Contact the IT +
                          manager for further assistance.') SEV(30) +
                          FMT((*CHAR 10) (*CHAR 30))
             ENDDO

/*  PIR0201 Value can not be blank for create operation.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0201')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser incorporado por la operacion de +
                          crear.') SECLVL('Causa . . . . . :   &1 no +
                          puede ser blanco o menos que cero por una +
                          operacion de crear. &N Recobro . . . : +
                          Incorpore un valor de &1 u oprima F12 para +
                          cancelar.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0202 Value can not already exist for a create operation.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR0202')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          existe ya.') SECLVL('Causa . . . . . +
                          :   &1 existe ya. &N Recobro . . . +
                          :   Incorpore un valor por &1 que ya no +
                          existe u oprima F12 para cancelar.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0203 Value can not be blank.                       */

             CHGVAR     VAR(&MSGID) VALUE('PIR0203')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser incorporado.') SECLVL('Causa . . . +
                          . . :   &1 no puede ser blanco. &N Recobro +
                          . . . . :   Incorpore un valor por &1 u +
                          oprima F12 para +
                          cancelar.') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0204 Can only enter one value.                     */

             CHGVAR     VAR(&MSGID) VALUE('PIR0204')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Solo +
                          un valor puede ser incorporado.') +
                          SECLVL('Causa . . . . . :   Mas que un +
                          valor fue incorporado. &N Recobro . . . :   +
                          Incorpore solamente un valor.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0205 Must enter at least one value.                */

             CHGVAR     VAR(&MSGID) VALUE('PIR0205')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Debe +
                          incorporar por lo menos un valor.') +
                          SECLVL('Causa . . . . . :   Ninguno valor +
                          fue incorporado. &N Recobro . . . . :   +
                          Incorpore por lo menos un valor.') +
                          SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0206 Value can not be ...                          */

             CHGVAR     VAR(&MSGID) VALUE('PIR0206')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Valor +
                          no puede ser &1.') SECLVL('Causa . . . +
                          . :   Valor no puede ser &1. &N Recobro  . +
                          . . :   Incorpore un valor que no es &1 u +
                          oprima F12 para cancelar.') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR0750 Records removed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0750')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 y +
                          &2 fueron +
                          removidos.') SEV(00) FMT((*DEC 5 0) +
                          (*CHAR 45))
             ENDDO

/*  PIR0751 Records removed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR0751')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 y +
                          &2 fueron +
                          removidos.') SEV(00) FMT((*DEC 7 0) +
                          (*CHAR 46))
             ENDDO

/*  PIR1001 Invalid value entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1001')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El valor incorporado por &1 es +
                          invalido.') SECLVL('Causa . . . . . :   +
                          El valor incorporado por &1 no es valido. +
                          &N Recobro . . . . :   Incorpore un valor +
                          nuevo que es valido u oprima F4 si hay una +
                          lista de valores validos disponible +
                          y seleccionar uno.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1002 Invalid date entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La fecha incorporada es invalida.') +
                          SECLVL('Causa . . . . . :    ''&1'' no es +
                          una fecha valida. &N Recobro . . . :   +
                          Incorpore una fecha nueva en el formato de +
                          MMDDAA o el sistema puede crear una fecha +
                          por la incorporacion de 30D (30 dias de +
                          hoy), 1W (una semana de hoy), o 1M (un mes +
                          de hoy).') SEV(30) +
                          FMT((*CHAR 6))
             ENDDO

/*  PIR1003 Invalid time entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1003')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hora incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   ''&1 &2 no +
                          es una hora valida. &N Recobro . . . :   +
                          Incorpore una hora nueva en el formato de +
                          HHMM A/P donde A/P significa +
                          Am/Pm.') SEV(30) FMT((*CHAR 4) +
                          (*CHAR 1))
             ENDDO
/*  PIR1004 Receving label program has not been defined. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1004')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El programa de recibir rotulos no ha +
                          sido definido.') SECLVL('Causa . . . . . :  +
                          Un programa no ha sido definido para +
                          imprimir los rotulos de recepcion. &N +
                          Recobro . . . :   Puede continuar +
                          procesando sin los rotulos de impresion, o +
                          establezca contacto con el director de DP +
                          para definir el rotulo de recepcion usando +
                          el menu de administracion.') SEV(00)
             ENDDO

/*  PIR1005 Value for field must be Y or N.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1005')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El valor por el campo &1 debe ser +
                          ''Y'' o ''N''.') SECLVL('Causa . . . . . +
                          :   El valor incorporado por &1 no es +
                          valido. &N Recobro . . . :   Incorpore una +
                          ''Y o una +
                          ''N''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1006 Value for jobq not valid for view report option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1006')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El valor de jobq no es valido por +
                          Ver la opcion de informe.') SECLVL('Causa . +
                          . . . . :   No pudo poner el inforeme en +
                          jobq si quiere ver el informe. &N Recobro +
                          . . . :   Incorpore una ''N'' por la opcion +
                          de jobq.') SEV(30)
             ENDDO

/*  PIR1007 Invalid date entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1007')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La fecha incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   ''&1'' no es +
                          una fecha valida. &N Recobro . . . . :   +
                          Incorpore una fecha nueva en el formato +
                          de MDDYY.') SEV(30) +
                          FMT((*CHAR 6))
             ENDDO

/*  PIR1008 Date cannot be blank.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1008')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          fecha es requerida.') SECLVL('Causa . . . +
                          . . :   La fecha incorporada es blanca o 0. +
                          &N Recobro . . . . :   Incorpore una fecha +
                          nueva en el formato de MMDDAA.') SEV(30)
             ENDDO

/*  PIR1009 Date must be > today.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1009')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          fecha debe ser mayor que hoy.') +
                          SECLVL('Causa . . . . . :   La fecha +
                          incorporada no es mayor que hoy. &N +
                          Recobro . . . . :   Incorpore una fecha +
                          nueva en el formato de MMDDAA.') SEV(30)
             ENDDO

/*  PIR1010 Date must be < today.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1010')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          fecha debe ser menos que o igual a hoy.') +
                          SECLVL('Causa . . . . . :  La fecha +
                          incorporado no es menor que o igual a hoy. +
                          &N Recobro  . . . :   Incorpore una fecha +
                          nueva en el formato de MMDDAA.') SEV(30)
             ENDDO

/*  PIR1011 Value for update label must be Y if slot merge out = N */

             CHGVAR     VAR(&MSGID) VALUE('PIR1011')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Valor de campo &1 debe ser ''Y'' ') +
                          SECLVL('Causa . . . . . :   El valor +
                          marcado en Slot de campo es  ''N''. &N +
                          Recobro  . . . :   Incorpore ''Y'' +
                          en campo &1.') SEV(30) FMT((*CHAR 50))

             ENDDO

/*  PIR1012 Value for field must be 1, 2, OR 3 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1012')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Valor de campo &1 debe ser ''1, 2, +
                          or 3''') SECLVL('Causa . . . . . :   El +
                          valor incorporado por &1 no es valido. &N +
                          Recobro  . . . :   Incorpore ''1'' +
                          o  ''2'' o  ''3''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1013 Value for field must be 0, 1, OR 2 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1013')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Valor de campo &1 debe ser ''0, 1, +
                          or 2''') SECLVL('Causa . . . . . :   El +
                          valor incorporado por &1 no es valido. &N +
                          Recobro  . . . :   Incorpore ''0'' +
                          o ''1'' o ''2''.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR1014 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1014')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion &1 no es valido.') +
                          SECLVL('Causa . . . . . :   Reprint Tags +
                          solo es valido con productos que tienen un +
                          Category Code de CLAMS. &N Recobro  . . +
                          . :   Intente opcion con producto diferente +
                          que tiene un Category code de CLAMS.') +
                          SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1015 Truck Compartment must be blank. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1015')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser blanco.') SECLVL('Causa . . . . . +
                          :   Tote es seleccionado. &N Recobro  . . . +
                          :   Borre &1 .') SEV(30) FMT((*CHAR 40))
             ENDDO

/*  PIR1016 Field 1 must be less than or equal to field 2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1016')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          debe ser menos que o igual a &2.') +
                          SECLVL('Causa . . . . . :   El valor +
                          incorporado por &1 (&3) debe ser menos que o +
                          igual al valor incorporado por &2 (&4). +
                          &N Recobro  . . . :   Incorpore un valor +
                          menos que &2.') SEV(30) FMT((*CHAR 20) +
                          (*CHAR 20) (*DEC 4) (*DEC 4))
             ENDDO

/*  PIR1017 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1017')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion &1 no es disponible por +
                          Templates.') SECLVL('Causa . . . . . :   +
                          La opcion incorporada no es valido por +
                          codiogos de template. &N Recobro  . . . :   +
                          Intente otra opcion valida que no es 6 or +
                          12 por esta record.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1018 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1018')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion &1 no es disponible por +
                          camiones.') SECLVL('Causa . . . . . :   +
                          La opcion incorporada no es valida por +
                          camiones. &N Recobro  . . . :   Intente +
                          otra opcion valida que no es 2, 3, or 4 +
                          por esta anotacion.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1019 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1019')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Se prohibe copiar un template a un +
                          camion.') SECLVL('Causa . . . . . :   +
                          No puede crear un camion de un template. +
                           &N Recobro  . . . :   Incorpore +
                          otro template.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1020 Invalid option. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1020')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion &1 solo es disponible por +
                          Totes.') SECLVL('Causa . . . . . :   La +
                          opcion incorporada solo es por totes. &N +
                          Recobro  . . . :   Intente otra opcion +
                          valida que no es 12 por esta anotacion.') +
                          SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PIR1021 Invalid designation type entered. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El tipo de designacion incorporado es +
                          invalido.') SECLVL('Causa . . . . . :  El +
                          tipo de designacion debe ser una ''H'' o +
                          ''S''. &N Recobro . . . :  Incorpore ''H'' +
                          por la designacion dura o ''S'' por la +
                          designacion suave.') SEV(30)
             ENDDO

/*  PIR1022 Invalid template code             */

             CHGVAR     VAR(&MSGID) VALUE('PIR1022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Codigo de template es invalido.') +
                          SECLVL('Causa . . . . . :   Codigo de +
                          template incorporado no existe. &N Recobro  +
                          . . . :   Incorpore un codigo de template +
                          que fue incorporado antes.') SEV(30)
             ENDDO

/*  PIR1023 Template Required for Trucks      */

             CHGVAR     VAR(&MSGID) VALUE('PIR1023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Requiere codigo de template.') +
                          SECLVL('Causa . . . . . :   Requiere codigo +
                          de template cuando incorpora/mantiene +
                          camiones. &N Recobro  . . . :   Incorpore +
                          codigo de template que es valido.') SEV(30)
             ENDDO

/*  PIR1051 Inactive slot unavailable for replenishment */

             CHGVAR     VAR(&MSGID) VALUE('PIR1051')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El slot inactivo &1 no es disponible +
                          por reaprovisionamiento.') SECLVL('Causa . +
                          . . . . :   El slot seleccionado &1 no es +
                          disponible por reaprovisionamiento porque +
                          el slot no esta de estado activo. &N +
                          Recobro . . . . :  Seleccione un slot +
                          que tiene un estado de "A" e intente +
                          otra vez.') SEV(40) FMT((*CHAR 12))
             ENDDO

/*  PIR1052 New pallet for each aisle not avail. when Build method not 2=Loc */

             CHGVAR     VAR(&MSGID) VALUE('PIR1052')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Una +
                          paleta nueva por cada pasillo = Y no es +
                          permitida a menos que el metodo de +
                          construir = 2.') SECLVL('Causa . . . . . +
                          :   Una paleta nueva de cada pasillo es +
                          permitido solamente cuando el Metodo de +
                          construir es 2=ubicacion. &N Recobro . . . +
                          :   Cambie el Metodo de construir a 2= +
                          ubicacion o cambie la paleta nueva por +
                          cada pasillo a N=No e intente otra +
                          vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1053 Dock door selected is inactive. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1053')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          puerta de muelle &1 es inactiva. Seleccione +
                          la puerta nueva.') SECLVL('Causa . . . . . +
                          :   La puerta de muelle seleccionada &1 no +
                          es disponible porque la puerta de muelle +
                          es inactiva. &N Recobro . . . :   Incorpore +
                          una puerta de muelle que si es activo u +
                          oprime F4=Inicitar para seleccionar una +
                          puerta de muelle disponible e intente +
                          otra vez.') SEV(30) FMT((*DEC 3))
             ENDDO

/*  PIR1054 Not all dock door(s) assigned. Pick & print halted for route. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1054')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('+
                          Todas las puertas de muelle no son +
                          asignadas. Escoger e imprimir parado por +
                          la ruta &1.') SECLVL('Causa . . . . . :   +
                          Todos los compartimentos de los camiones +
                          por la ruta &1 tienen una puerta de muelle +
                          asignado para cargar. &N Recobro . . . :   +
                          Incorpore la opcion 11=Trabajar con las +
                          puertas de muelle por la ruta &1 para +
                          encontrar los compartimientos faltando una +
                          puerta de muelle. Incorpore las puertas +
                          validas por los compartimientos afectados. +
                          Entonces tome la opcion 1=escoger e +
                          imprimir por la ruta &1 e intente otra +
                          vez.') SEV(30) +
                          FMT((*CHAR 5))
             ENDDO

/*  PIR1055 Option not allowed on dock door. No route assigned to door. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1055')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion &1 no es permitida en la +
                          puerta de muelle &2. Ningunas de las rutas +
                          asignadas a la puerta.') SECLVL('Causa . . +
                          . . . :   Esta opcion no es disponible por +
                          la puerta de muelle seleccionada porque +
                          ningunas de las rutas han sido asignadas a +
                          la puerte de muelle. &N Recobro . . . :   +
                          Incorpore la opcion &1 a lado de una puerta +
                          de muelle que tiene una ruta asignado a si +
                          e intente otra vez.') SEV(30) +
                          FMT((*CHAR 10) (*DEC 3))
             ENDDO

/*  PIR1056 Option not allowed on dock door. Option x available. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1056')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion &1 no es permitida en la +
                          puerta de muelle &2. La opcion &3 es +
                          disponible.') SECLVL('Causa . . . . . :   +
                          Esta opcion no es disponible por uno de +
                          las razones siguientes: 1.) Esta` en el +
                          modo de Ver solamente. 2.) La ruta +
                          asignada a la puerta ser cambiada no esta +
                          al estado de contruccion. Cambiando las +
                          puertas de muelle asignadas no es permitido +
                          despues de la ruta no esta al estado de +
                          construccion. &N Recobro . . . . :   Cambie +
                          el requisito a la opcion &3 o seleccione +
                          una puerta con una ruta que todavia esta al +
                          estado de construccion e intente otra +
                          vez.') SEV(30) FMT((*CHAR 10) +
                          (*DEC 3) (*CHAR 10))
             ENDDO

/*  PIR1057 License Plate Tracking = No. All options must be No. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1057')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('A permitir la supervision de los +
                          platos de licencia es N=No. Todas las otras +
                          opciones deben ser N=No.') SECLVL('Causa +
                          . . . . . :   Algunas de las opciones +
                          siguientes han sido fijas a Y=Si: +
                          Supervisar todos los productos, Supervisar +
                          todos los productos de fecha sensitiva, +
                          Supervisar todos los productos de codigo de +
                          lote, o Supervisar todos los productos de +
                          catch weight. &N Recobro . . . :   Cambie +
                          todas las opciones de la supervision de +
                          los platos de licencia a Y=si. Entonces +
                          intente otra vez.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PIR1058 License Plate Tracking Yes, At least one option must be Yes. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1058')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Por +
                          lo menos una opcion de supervision debe +
                          ser fija a Y=Si.') SECLVL('Causa . . . . . +
                          :   Todas las opciones de supervision de +
                          los platos de licencia son fija a N=No. &N +
                          Recobro . . . :   Cambie por lo menos una +
                          opcion de supervision de los platos de +
                          licencia a Y=Si o cambie A permitir la +
                          supervision de los platos de licencia a +
                          N=NO. Entonces intente otra +
                          vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1059 Date Sensitive,Lot Tracking and Catchweight items must be Yes. */

             CHGVAR     VAR(&MSGID) VALUE('PIR1059')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Los +
                          productos de fecha sensativa, codigo de +
                          lote y catch weight debe ser Y=Si.') +
                          SECLVL('Causa . . . . . :   La opcion de +
                          Supervisar todos los productos ha sido fija +
                          a Y=Si. &N Recobro . . . . :   Cambie todas +
                          opciones de Supervision de los platos de +
                          licencia a Y=Si o cambie Supervisar todos +
                          los productos a N=No y fije uno o mas del +
                          siguiente a Y=Si: Supervisar los productos +
                          de fecha sensativa, productos de codigo de +
                          lote o productos de catch weight. Entonces +
                          intente otra vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1060 Quantity change not allowed when runner flag = 'F'.            */

             CHGVAR     VAR(&MSGID) VALUE('PIR1060')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Se prohibe cambiar la cantidad cuando +
                          runner flag = "F".') SECLVL('Causa . . . +
                          . . :   Creo Runner flag para cantidad de +
                          corto/afuera.  Hasta que el flag haya +
                          sido aclarado por el programa de Clear Flag +
                          Entries, no puede cambiar la cantidad. +
                          &N Recobro  . . . :   Vaya al menu PIRFLG +
                          tome la opcion de Select Flag Task List. +
                          Entonces pongase al departamento y marque +
                          el numero incorrecto. Oprima F11=View +
                          hasta que vea el numero de transaccion +
                          asignado al producto. Luego vaya al +
                          programa de Clear Flag Entries para +
                          aclarar el flag. Entonces intente +
                          otra vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1061 Runner flag not closed. F7=Clear flag not available.           */

             CHGVAR     VAR(&MSGID) VALUE('PIR1061')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No cerro Runner Flag. El flag de +
                          F7=Clear no es disponible.') SECLVL('Causa +
                          . . . . . :   Runner Flag ha sido creado por +
                          cantidad de corto/afuera. Hasta que el +
                          flag haya sido aclarado por el programa +
                          de Runner Flag, no puede aclararlo. &N +
                          Recobro  . . . :   Vaya al menu PIRFLG +
                          tome la opcion de Select Flag +
                          Task List. Entonces, pongase al departamento +
                          y marque el numero incorrecto. Oprima +
                          F11=View hasta que vea el numero de +
                          transaccion asignado al producto. Luego +
                          vaya al programa de Clear Flag Entries +
                          para aclarar el flag, e intente +
                          otra vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1062 New pallet for each order only when Build method is 1/3 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1062')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' Se+
                          permite paleta nueva por cada pedida cuando +
                          Build Method = 1 o 3.') SECLVL('Causa . +
                          . . . .  :   Solo se permite paleta nueva +
                          por cada pedida cuando Build Method es 1=Stop +
                          o 3=Desc by Stop. &N Recobro  . . . :   +
                          Cambie Build Method a 1=Stop o 3=Desc +
                          by Stop o cambie paleta nueva por cada +
                          pedida a N=No e intente otra +
                          vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1063 New pallet if stop doesn't fit, only when Build method is 1/3  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1063')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Solo se +
                          permite paleta nueva si la parada no conviene +
                          por Build method = 1 o 3.') +
                          SECLVL('Causa . . . . .  :   Solo se permite +
                          paleta nueva si la parada no conviene por +
                          Build Method es 1=Stop o 3=Desc by Stop. +
                          &N Recobro  . . . :   Cambie Build +
                          Method a 1=Stop o 3=Desc by Stop o +
                          cambie paleta nueva si la parada no conviene +
                          a N=No e intente otra vez.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1064 Stop must be 1 when new pallet for order = Y  */

             CHGVAR     VAR(&MSGID) VALUE('PIR1064')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          parada debe ser 1 cuando la paleta de pedido +
                          =Y.') SECLVL('Causa . . . . .  :   Parada es +
                          mas que 1 y la paleta nueva de pedido es puesta +
                          a Y. &N Recobro  . . . :   Cambie las +
                          paradas a 1 o cambie la paleta nueva de pedidos +
                          a Y=Yes e intente otra +
                          vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR1393 User Profile &1 re-enabled by User Profile &2 */

             CHGVAR     VAR(&MSGID) VALUE('PIR1393')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('User +
                          profile &1 has been re-enabled by user +
                          &2.') SECLVL('Cause . . . . .  :   User +
                          &1 disabled their user profile after too +
                          many invalid login attempts. &N Recovery  +
                          . . . :   User profile &1 has been +
                          re-enabled by user &2 using cmd ENABLE. +
                          If user disables their profile a 2nd +
                          time, change password to temporary value +
                          so that they can enter a new password.') +
                          SEV(10) FMT((*CHAR 10) (*CHAR 10))
             ENDDO

/*  PIR2007 Invalid slot, slot inactive. */

             CHGVAR     VAR(&MSGID) VALUE('PIR2007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot invalido, slot inactivo.') +
                          SECLVL('Causa . . . . . :   El slot +
                          escandido es inactivo. No puede transferir +
                          el producto de/a un slot inactivo. &N +
                          Recobro . . . :   Escanda una ubicacion +
                          nueva e intente otra +
                          vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR2101 Invalid value for field 1 based on value for field 2.*/

             CHGVAR     VAR(&MSGID) VALUE('PIR2101')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Valor invalido por &1.') +
                          SECLVL('Causa . . . . . :   El valor +
                          incorporado por &1 no puede ser &3 cuando +
                          el valor por &2 es &4. +
                          &N Recobro  . . . :   Incorpore un valor +
                          nuevo por &1 o &3.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  PIR4001 Notify supervisor of condition, Warning. */

             CHGVAR     VAR(&MSGID) VALUE('PIR4001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Avise al supervisor de la condicion.') +
                          SECLVL('Causa . . . . . :   Una respuesta +
                          inesperada fue incorporada. Avise al +
                          supervisor antes de continuar. &N Recobro +
                          . . :   Cambie la resupest u oprime el paso +
                          sobre.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR4002 Invalid value for field 1 based on value for field 2.*/

             CHGVAR     VAR(&MSGID) VALUE('PIR4002')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Producto se expiro.') +
                          SECLVL('Causa . . . . . :   La fecha de +
                          fabricante incorporada muestra el producto +
                          ya expirado. &N Recobro  . . . :  +
                          Incorpore una fecha nueva o cambie el +
                          guardar a N.') SEV(30) FMT(*NONE)
             ENDDO

/*  PIR7871 Subfile record could not be added to file. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7871')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          no fue anadido al archivo.') SECLVL('Causa +
                          . . . . . :   Un error ocurrio cuando +
                          trataba de anadir &1. &N Recobro . . . :   +
                          Oprima ENTER para intentar otra vez o +
                          establezca contacto con el director de DP +
                          para recibir mas instrucciones.') +
                          SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7872 Subfile record could not be updated in file. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7872')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          no fue puesto al dia en el archivo.') +
                          SECLVL('Causa . . . . . :   Un error +
                          ocurrio cuando trataba de poner al dia &1. +
                          &N Recobro . . . :   Oprima ENTER para +
                          intentar otra vez, o establezca contacto +
                          con el director de DP para recibir mas +
                          instrucciones.') SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7971 Record not added to file.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7971')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La anotacion no fue anadida al +
                          archivo.') SECLVL('Causa . . . . . :   Un +
                          error ocurrio cuando trataba de anadir la +
                          anotacion incorporada. &N Recobro . . . :   +
                          Establezca contacto con el director de DP +
                          para recibir mas instrucciones.') SEV(40)
             ENDDO

/*  PIR7972 Record not updated in file.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7972')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La anotacion no fue puesta al dia en +
                          el archivo.') SECLVL('Causa . . . . . :   +
                          Un error ocurio cuando trataba de poner al +
                          dia la anotaction actual. &N Recobro . . . +
                          :   Establezca contacto con el director de +
                          DP para recibir mas instrucciones.') SEV(40)
             ENDDO

/*  PIR7973 Record selected does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7973')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          anotacion seleccionada no existe.') +
                          SECLVL('Causa . . . . . :   La anotacion +
                          seleccionada no pudo ser encontrado. La +
                          causa mas frecuente es que alguien borro +
                          la anotacion entre la hora que fue mostrada +
                          en la pantalla y el tiempo que fue +
                          seleccionada. &N Recobro  . . . :   Oprima +
                          F5 para refrescar la pantalla. La anotacion +
                          sera eliminada si fue borrada. Si todavia +
                          esta mostrada, trate de seleccionarla otra +
                          vez. Si todavia ocurre este error, +
                          establezca contacto con el director +
                          de DP.') SEV(40) +
                          FMT((*DEC 9 0))
             ENDDO

/*  PIR7974 Record selected is locked.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7974')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          anotacion seleccionad esta cerrada por otro +
                          usuario.') SECLVL('Causa . . . . . :   Otro +
                          usuario ya esta usando la anotacion +
                          seleccionada y no puede ser compartida. &N +
                          Recobro  . . . :   Seleccione otra +
                          anotacion o espere hasta el otro usuario +
                          termine e intente otra vez. Si no hay otro +
                          usuario usando la anotacion y todavia +
                          recibe este mensaje, entonces  establezca +
                          contacto con el director de DP.') +
                          SEV(40)
             ENDDO

/*  PIR7975 Record not deleted.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR7975')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Anotacion no fue borrada.') +
                          SECLVL('Causa . . . . . :   No hay mas +
                          informacion. &N Recobro . . . :  Establezca +
                          contacto con el director de DP.') SEV(40)
             ENDDO

/*  PIR7978  Record in use. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7978')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Se +
                          esta usando ya la anotacion &1.') +
                          SECLVL('Causa . . . . . :   Otro usuario +
                          esta usando la anotacion &1. &N Recobro +
                          . . . :   Espere hasta el otro usuario +
                          termina e intente otra +
                          vez.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR7979 record does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7979')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          anotacion &1 no existe.') SECLVL('Causa . +
                          . . . . :   La anotacion &1 es necesario +
                          por este puesto al dia pero no existe. &N +
                          Recobro  . . . :   Cree la anotacion &1 e +
                          intente otra vez.') SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7980  Item quantity record in use. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7980')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad del producto &1 no pudo +
                          ser ajusteda.') SECLVL('Causa . . . . . :   +
                          La cantidad del producto &1 no pudo ser +
                          ajustada porque otro usuario esta usando la +
                          anotacion de la cantidad del producto. &N +
                          Recobro  . . . :   Intente otra vez. Si +
                          recibe este mensaje otra vez, establezca +
                          contacto con el director +
                          de DP.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR7981 Item quantity record does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PIR7981')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad del producto &1 no pudo +
                          ser ajustada.') SECLVL('Causa . . . . . :   +
                          La cantidad del producto &1 no pudo ser +
                          ajustada porque la anotacion de la cantidad +
                          del producto para este puesto al dia no +
                          existe. &N Recobro . . . :   El director de +
                          DP necesita crear la anotacion de cantidad +
                          del producto por &1 en el archivo ITEMQTY +
                          e intente otra vez.') +
                          SEV(40) FMT((*CHAR 50))
             ENDDO

/*  PIR7982 Record changed by another user.      */

             CHGVAR     VAR(&MSGID) VALUE('PIR7982')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aviso: Otro usuario cambio` la +
                          anotacion antes de un puesto al dia pudo +
                          ser hecho.') SECLVL('Causa . . . . . :   +
                          La informacion actual de la anotacion +
                          cambio antes de oprimio` ENTER para hacer +
                          el puesto al dia. &N Recobro  . . . :   +
                          Oprima F20 para aceptar el aviso y hacer +
                          el ajustamiento u oprima F12 a cancelar.') +
                          SEV(10)
             ENDDO

/*  PIR7983 Record changed by another user.      */   /* 415 A */

             CHGVAR     VAR(&MSGID) VALUE('PIR7983')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aviso: Otro usuario cambio` la +
                          anotacion antes de un puesto al dia pudo +
                          ser hecho.') SECLVL('Causa . . . . . :   +
                          La informacion actual de la anotacion +
                          cambio` antes de oprimio` ENTER para hacer +
                          el puesto al dia. &N Recobro  . . . :   +
                          Oprima F5 para refrescar la pantalla con +
                          los valores actuales. Haga los cambios. +
                          Oprima ENTER para salvar los +
                          cambios.') SEV(10)
             ENDDO


/*  PIR9801 Program canceled at your request.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9801')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          fue cancelado a peticion del usuario.') +
                          SECLVL('No hay mas informacion de este +
                          mensaje.') SEV(0) FMT((*CHAR 50))
             ENDDO

/*  PIR9802 Program ended in error.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9802')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          termino como un error.') SECLVL('No hay mas +
                          informacion de este mensaje.') SEV(40) +
                          FMT((*CHAR 50))
             ENDDO

/*  PIR9803 Delete completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9803')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          borrado con exito.') SECLVL('No hay mas +
                          informacion de este mensaje.') +
                          SEV(00) FMT((*CHAR 50))
             ENDDO

/*  PIR9804 Invalid option sent to program. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9804')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion (&1) fue enviada al programa +
                          &2') SECLVL('Establezca contacto con el +
                          director de DP para recibir mas +
                          asistencia.''') SEV(40) FMT((*CHAR +
                          8) (*CHAR 10))
             ENDDO

/*  PIR9805 No records found for subfile display. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9805')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Ningunas anotaciones encontradas por el +
                          archivo &1.') SECLVL('Corrija los +
                          parametros e intente otra +
                          vez.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR9806 No records found for entered criteria. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9806')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Ningunas anotaciones encontradas por el +
                          criterio incorporado.') SECLVL('Corrija +
                          los parametros e intente otra +
                          vez.') SEV(30) FMT((*CHAR 50))
             ENDDO

/*  PIR9901 FROM date must be < or = to the TO date.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9901')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La fecha a partir debe ser menos que +
                          o igual a la fecha a destinar.') +
                          SECLVL('Causa . . . . . :   Se ha +
                          incorporado una fecha a partir que es mas +
                          grande que la fecha a destinar. &N Recobro +
                          . . . :   Incorpore una fecha nueva que es +
                          menos que o igual a la fecha a +
                          destinar.') SEV(40)
             ENDDO

/*  PIR9902 FROM time must be < or = to the TO time. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9902')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hora a partir debe ser menos que o +
                          igual a la hora  a destinar.') +
                          SECLVL('Causa . . . . . :   Se ha +
                          incorporado una hora a partir que es mas +
                          grande que la hora a destinar. &N Recobro +
                          . . . :   Incorpore una hora nueva que es +
                          menos que o igual a la hora a destinar.') +
                          SEV(40)
             ENDDO

/*  PIR9903 Select one option.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9903')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Seleccione una opcion.') SECLVL('Causa +
                          . . . . . :   No se ha seleccionado ninguna +
                          opcion. &N Recobro  . . . :   Seleccione +
                          una opcion para continuar u oprima F12 para +
                          cancelar.') SEV(40)
             ENDDO


/*  PIR9904 Select only one option.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9904')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Seleccione solamente una opcion.') +
                          SECLVL('Causa . . . . . :   Se ha +
                          incorporado mas que una opcion. &N +
                          Recobro  . . . :   Seleccione solamente una +
                          de las opciones mostradas para +
                          continuar.') SEV(40)
             ENDDO

/*  PIR9905 Cursor position not allowed. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9905')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La posicion de cursor no es permitida +
                          por la peticion de lista.') SECLVL('Causa +
                          . . . . . :   La tecla F4 fue oprimida pero +
                          el cursor no estuvo en una linea dentro del +
                          campo que permite una peticion de lista. &N +
                          Recobro . . . :   Ponga el cursor en el +
                          campo que permite una peticion de lista +
                          antes de oprimir F4 otra vez.') SEV(40)
             ENDDO

/*  PIR9906 Invalid date entered.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9906')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La fecha incorporada es invalida.') +
                          SECLVL('Causa . . . . . :   ''''&1'''' no +
                          es una fecha valida. &N Recobro . . . :   +
                          Incorpore una fecha nueva en el formato de +
                          MMDDYY e intente otra +
                          vez.') SEV(30) FMT((*CHAR 6))
             ENDDO

/*  PIR9907 &1 No longer at status of &2. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9907')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          no esta al estado de &2 nada mas.') +
                          SECLVL('Causa . . . . . :  Alguien ya ha +
                          seleccionado &1 para procesar mas y no es +
                          disponible ahora. &N Recobro . . . :    +
                          Oprima F5=Refrescar para mostrar la lista +
                          actual de &3 disponible para procesar mas. +
                          Entonces intente otra +
                          vez.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9908 &1 currently inuse. &2 in progress. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9908')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Se +
                          esta usando &1 actualmente. &2 esta en +
                          progreso.') SECLVL('Causa . . . . . :   +
                          Alguien ya ha seleccionado &1 para procesar +
                          mas y no es disponible ahora. &N Recobro : +
                          . . . :   Oprima F5=Refrescar para mostrar +
                          la lista actual de &3 disponible para +
                          procesar mas. Entonces intente otra +
                          vez.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9909 &1 Has started transactions.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9909')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          ha empezado transacciones.') +
                          SECLVL('Causa . . . . . :  Alguien ya ha +
                          empezado las transacciones de  &1 +
                          &N Recobro  . . . :   Oprima F5=Refresh +
                          para mostrar la lista actual de &3 +
                          disponible para utilizar mas.  Entonces +
                          intente otra vez.') SEV(30) +
                          FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9910 &1 Has started transactions.  */

             CHGVAR     VAR(&MSGID) VALUE('PIR9910')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('For +
                          catch-weight items, use full-screen +
                          adjustment program.') SECLVL('Cause . . . +
                          . . :  You may not adjust the inventory +
                          from the RF screen.  Adjustments must be +
                          made in the full-screen program.') +
                          SEV(30) FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))

             ENDDO

/*  PIR9911 Warehouse/department does not exist                 */

             CHGVAR     VAR(&MSGID) VALUE('PIR9911')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warehouse/Department does not +
                          exist.') SECLVL('Cause . . . . . :  +
                          Please enter a valid warehouse/department +
                          combination.') SEV(30) FMT((*CHAR 20) +
                          (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9912 Warehouse/department/item does not exist             */

             CHGVAR     VAR(&MSGID) VALUE('PIR9912')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warehouse/Department/Item does not +
                          exist.') SECLVL('Cause . . . . . :  +
                          Please enter a valid +
                          warehouse/department/item combination.') +
                          SEV(30) FMT((*CHAR 20) (*CHAR 20) (*CHAR 10))
             ENDDO

/*  PIR9999 Generic msgd to display error from program. */

             CHGVAR     VAR(&MSGID) VALUE('PIR9999')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1') +
                          SEV(30) FMT((*CHAR 78))
             ENDDO

             RETURN
             ENDPGM
